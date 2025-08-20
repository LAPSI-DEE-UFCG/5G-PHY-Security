%%
% Generate Waveforms
 
%%
% The first step is to generate the carrier configurations to OFDM
% modulation

carrier = nrCarrierConfig;
carrier.NSizeGrid = 132;
carrier.SubcarrierSpacing = 60;
carrier.NSlot = 0;
carrier.NFrame = 0;

%%
% Then, let's configure the CSI-RS
numNZPRes = 12;
csirs = nrCSIRSConfig;
csirs.CSIRSType = repmat({'nzp'}, 1, numNZPRes);
csirs.CSIRSPeriod = 'on';
csirs.Density = repmat({'one'}, 1, numNZPRes);
csirs.RowNumber = repmat(2, 1, numNZPRes);
csirs.SymbolLocations = {0,1,2,3,4,5,6,7,8,9,10,11};
csirs.SubcarrierLocations = repmat({0}, 1, numNZPRes);
csirs.NumRB = 25;


%% Validate the ports.

numPorts = csirs.NumCSIRSPorts;
if any(numPorts > 1)
    error('nr5g:PortsGreaterThan1',['CSI-RS resources must be configured ' ...
        'for single-port for RSRP measurements'])
end

%% Getting the binary vector to represent the presence of the CSI-RS 
% resource in a specified slot


csirsTransmitted = getActiveCSIRSRes(carrier, csirs);
powerCSIRS = 0;

%% Generating CSI-RS symbols
csirsSym = nrCSIRS(carrier, csirs, 'OutputResourceFormat','cell');
csirsInd = nrCSIRSIndices(carrier, csirs, "OutputResourceFormat","cell");

%% Configure the antenna arrays and scatters

fc = 28e9;
freqRange = validateFc(fc);
c = physconst('LightSpeed');
lambda = c/fc;

txArraySize = [6 6];
rxArraySize = [16 16];

nTx = prod(txArraySize);
nRx = prod(rxArraySize);

txArrayPos = [0;0;0];
rxArrayPos = [10;5;0];

toRxRange = rangeangle(txArrayPos, rxArrayPos);
spLoss = fspl(toRxRange, lambda);


%% Configure TX Array
load('\Users\joaop\Documents\tcc\dataset_creation\antennas\cra_48.mat', 'cra');

txArray = cra;

%% Configure RX array

rxAntenna = design(patchMicrostrip, 28e9);
rxArray = generate_phased_array(false);
rxArray.ElementNormal = [0; 90];


%% Configuring Scatter
fixedScatMode = false;
rng(42);

if fixedScatMode
    numScat = 1;
    scatPos = [6;1;1.5];
else
    % Generate scatterers at random positions
    numScat = 1; %#ok<UNRCH> 
    azRange = -180:180;
    randAzOrder = randperm(length(azRange));
    elRange = -90:90;
    randElOrder = randperm(length(elRange));
    azAngInSph = deg2rad(azRange(randAzOrder(1:numScat)));
    elAngInSph = deg2rad(elRange(randElOrder(1:numScat)));
    r = 20;
    
    % Transform spherical coordinates to Cartesian coordinates
    [x,y,z] = sph2cart(azAngInSph,elAngInSph,r);
    scatPos = [x;y;z] + (txArrayPos + rxArrayPos)/2;
end



%% Calculating the Steering vectors

txArrayStv = phased.SteeringVector('SensorArray', txArray, 'PropagationSpeed', c);



%[~, scatAng] = rangeangle(scatPos(:,1), txArrayPos);

%azTxBeamWidth = 30;
%elTxBeamWidth = 30;

        
%ssbTxAng = getInitialBeamDir(scatAng, azTxBeamWidth, elTxBeamWidth);

%% Configuring the beams to transmit

numBeams = sum(csirsTransmitted);
azSweepRange = [-60 60];%[ssbTxAng(1) - azTxBeamWidth/2 ssbTxAng(1) + azTxBeamWidth/2];
elSweepRange = [0 90];%[ssbTxAng(2) - elTxBeamWidth/2 ssbTxAng(2) + elTxBeamWidth/2];

azBW = beamwidth(txArray, fc, 'Cut', 'Azimuth');
elBW = beamwidth(txArray, fc, 'Cut', 'Elevation');

csirsBeamAng = getBeamSweepAngles(numBeams, azSweepRange, elSweepRange, azBW, elBW);

%% Steering vectors for all Resources

wT = zeros(nTx, numBeams);
for beamIdx = 1:numBeams
    tempW = txArrayStv(fc, csirsBeamAng(:,beamIdx));
    wT(:,beamIdx) = tempW;
end

%% Digital beamforming

ports = csirs.NumCSIRSPorts(1);

bfGrid = nrResourceGrid(carrier, nTx);

activeRes = find(logical(csirsTransmitted));

for resIdx = 1:numNZPRes

    txSlotGrid = nrResourceGrid(carrier, ports);
    txSlotGrid(csirsInd{resIdx}) = db2mag(powerCSIRS)*csirsSym{resIdx};
    reshapedSymb = reshape(txSlotGrid, [], ports);

    beamIdx = find(activeRes == resIdx);

    if ~isempty(beamIdx)
        bfSymb = reshapedSymb * wT(:,beamIdx)';
        bfGrid = bfGrid + reshape(bfSymb, size(bfGrid));
    end
end

%% OFDM

[tbfWaveform, ofdmInfo] = nrOFDMModulate(carrier, bfGrid);

tbWaveform = tbfWaveform/sqrt(nTx);

%% Channel

chan = phased.ScatteringMIMOChannel;
chan.PropagationSpeed = c;
chan.CarrierFrequency = fc;
chan.Polarization = 'none';
chan.SpecifyAtmosphere = false;
chan.SampleRate = ofdmInfo.SampleRate;
chan.SimulateDirectPath = true;
chan.ChannelResponseOutputPort = true;

% Transmit
chan.TransmitArray = txArray;
chan.TransmitArrayMotionSource = 'property';
chan.TransmitArrayPosition = txArrayPos;

% Receive
chan.ReceiveArray = rxArray;
chan.ReceiveArrayMotionSource = 'property';
chan.ReceiveArrayPosition = rxArrayPos;

% scatters
%chan.ScattererSpecificationSource = 'property';
%chan.ScattererPosition = scatPos;
%chan.ScattererCoefficient = ones(1, numScat);

% Max channel delay
%[~, ~, tau] = chan(complex(randn(chan.SampleRate*1e-3, nTx), ...
%    randn(chan.SampleRate*1e-3, nTx)));

%maxChDelay = ceil(max(tau)*chan.SampleRate);


%% Send through the channel

%tbfWaveform = [tbfWaveform; zeros(maxChDelay, nTx)];
fadWave = chan(tbWaveform);


%% Apply AWGN

% Configure the receive gain
rxGain = 10.^((spLoss)/20); % Gain in linear scale
% Apply the gain
fadWaveG = fadWave*rxGain;

% Configure the SNR in dB
SNRdB = 20;
SNR = 10^(SNRdB/10); % SNR in linear scale
% Calculate the standard deviation for AWGN
N0 = 1/sqrt(2.0*nRx*double(ofdmInfo.Nfft)*SNR);

% Generate AWGN
noise = N0*complex(randn(size(fadWaveG)),randn(size(fadWaveG)));
% Apply AWGN to the waveform
rxWaveform = fadWaveG + noise;


%% Timing sync
% Generate reference symbols and indices
%refSym = nrCSIRS(carrier,csirs);
%refInd = nrCSIRSIndices(carrier,csirs);

% Estimate timing offset
%offset = nrTimingEstimate(carrier,rxWaveform,refInd,refSym);
%if offset > maxChDelay
%    offset = 0;
%end

% Correct timing offset
%syncTdWaveform = rxWaveform(1+offset:end,:);


%% OFDM demodulation

rxGrid = nrOFDMDemodulate(carrier, rxWaveform);

%% Steering vector 
rxArrayStv = phased.SteeringVector('SensorArray', rxArray, 'PropagationSpeed', c);
[~,scatRxAng] = rangeangle(scatPos(:,1),rxArrayPos);

azRxBeamWidth = 30; % In degrees
elRxBeamWidth = 30; % In degrees

rxAng = getInitialBeamDir(scatRxAng,azRxBeamWidth,elRxBeamWidth);
wR = rxArrayStv(fc,rxAng);


%% Receiving beamforming
temp = rxGrid;
if strcmpi(freqRange,'FR1')
    % Beamforming without combining
    rbfGrid = reshape(reshape(temp,[],nRx).*wR',size(temp,1),size(temp,2),[]);
else % 'FR2'
    % Beamforming with combining
    rbfGrid = reshape(reshape(temp,[],nRx)*conj(wR),size(temp,1),size(temp,2),[]);
end


%% Plot Scenarios (MY PC WILL DIE HERE MAN)

sceneParams.TxArray = txArray;
sceneParams.RxArray = rxArray;
sceneParams.TxArrayPos = txArrayPos;
sceneParams.RxArrayPos = rxArrayPos;
sceneParams.ScatterersPos = scatPos;
sceneParams.Lambda = lambda;
sceneParams.ArrayScaling = 10;
sceneParams.MaxTxBeamLength = 4;
sceneParams.MaxRxBeamLength = 2;

killPC(sceneParams, wT, wR);
axis tight;
view([74 29]);

%% MEasurments 

% Perform RSRP measurements
meas = nrCSIRSMeasurements(carrier,csirs,rbfGrid);

% Display the measurement quantities for all CSI-RS resources in dBm
RSRPdBm = max(meas.RSRPPerAntenna,[],1);
disp(['RSRP measurements of all CSI-RS resources (in dBm):' 13 num2str(RSRPdBm)]);
