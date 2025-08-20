function [carrier, rxGrid, csirs] = gen_waveform(ue, gnb, ueSV, uePos, gnbPos, N, ueAng)

    % The first step is to generate the carrier configurations to OFDM
    % modulation
    
    carrier = nrCarrierConfig;
    carrier.NSizeGrid = 132;
    carrier.SubcarrierSpacing = 60;
    carrier.NSlot = 0;
    carrier.NFrame = 0;
    
    %
    % Then, let's configure the CSI-RS
    numNZPRes = 1;
    csirs = nrCSIRSConfig;
    csirs.CSIRSType = repmat({'nzp'}, 1, numNZPRes);
    csirs.CSIRSPeriod = 'on';
    csirs.Density = repmat({'one'}, 1, numNZPRes);
    csirs.RowNumber = repmat(2, 1, numNZPRes);
    csirs.SymbolLocations = {0};
    csirs.SubcarrierLocations = repmat({0}, 1, numNZPRes);
    csirs.NumRB = 25;
    
    % Validate the ports.
    
    numPorts = csirs.NumCSIRSPorts;
    if any(numPorts > 1)
        error('nr5g:PortsGreaterThan1',['CSI-RS resources must be configured ' ...
            'for single-port for RSRP measurements'])
    end
    
    % Getting the binary vector to represent the presence of the CSI-RS 
    % resource in a specified slot
    
    
    csirsTransmitted = getActiveCSIRSRes(carrier, csirs);
    powerCSIRS = 0;
    
    % Generating CSI-RS symbols
    csirsSym = nrCSIRS(carrier, csirs, 'OutputResourceFormat','cell');
    csirsInd = nrCSIRSIndices(carrier, csirs, "OutputResourceFormat","cell");
    
    % Configure the antenna arrays and scatters
    
    fc = 28e9;
    c = physconst('LightSpeed');
    
    txArraySize = [16 16];
    
    nTx = prod(txArraySize);
    nRx = N;
    txArrayPos = uePos;
    rxArrayPos = gnbPos;
        
    % Configure TX Array
    txArray = ue;
    
    % Configure RX array
    
    rxArray = gnb;
    
    % Calculating the Steering vectors
           
    % MAIN LOOP
    
    numBeams = sum(csirsTransmitted);

    %azBW = beamwidth(txArray, fc, 'Cut', 'Azimuth');
    %elBW = beamwidth(txArray, fc, 'Cut', 'Elevation');
    
    %csirsBeamAng = getBeamSweepAngles(numBeams, ueAng(1), ueAng(2), azBW, elBW);

    wT = zeros(nTx, numBeams);
    for beamIdx = 1:numBeams
        %tempW = ueSV(fc, csirsBeamAng(:,beamIdx));
        wT(:,beamIdx) = ueSV;
    end
    
    % Digital beamforming
    
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
    % tbWaveform = gpuArray(complex(tbWaveform));
    
    % Channel
    
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

    txWave = chan(tbWaveform);
    
    toRxRange = rangeangle(uePos, gnbPos);
    spLoss = fspl(toRxRange,c/fc);
    
    
    
    rxGain = 10.^((spLoss)/20);
    rxWave = txWave * rxGain;

    % Configure the SNR in dB
    SNRdB = 20;
    SNR = 10^(SNRdB/10); % SNR in linear scale
    % Calculate the standard deviation for AWGN
    N0 = 1/sqrt(2.0*nRx*double(ofdmInfo.Nfft)*SNR);
    
    % Generate AWGN
    noise = N0*complex(randn(size(rxWave)),randn(size(rxWave)));
    % Apply AWGN to the waveform
    rxWave = rxWave + noise;

    % rxWave = awgn(rxWave, 30);

    % OFDM demodulation
    rxGrid = nrOFDMDemodulate(carrier, rxWave);

end