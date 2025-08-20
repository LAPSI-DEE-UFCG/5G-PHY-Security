function dbM = getMeasures(gnbSV, carrier, rxGrid, csirs, N)
    freqRange = 'FR2';
    % Steering vector 
    wR = gnbSV;
    nRx = N^2;
    % Receiving beamforming
    temp = rxGrid;
    if strcmpi(freqRange,'FR1')
        % Beamforming without combining
        rbfGrid = reshape(reshape(temp,[],nRx).*wR',size(temp,1),size(temp,2),[]);
    else % 'FR2'
        % Beamforming with combining
        rbfGrid = reshape(reshape(temp,[],nRx)*conj(wR),size(temp,1),size(temp,2),[]);
    end
    
    % MEasurments 
    
    % Perform RSRP measurements
    meas = nrCSIRSMeasurements(carrier,csirs,rbfGrid);
    % Display the measurement quantities for all CSI-RS resources in dBm
    RSRPdBm = max(meas.RSRPPerAntenna,[],1);
    measurements = RSRPdBm;

    dbM = measurements;
    % Plot Scenarios (MY PC WILL DIE HERE MAN)

    %sceneParams.TxArray = txArray;
    %sceneParams.RxArray = rxArray;
    %sceneParams.TxArrayPos = txArrayPos;
    %sceneParams.RxArrayPos = rxArrayPos;
    %sceneParams.Lambda = lambda;
    %sceneParams.ArrayScaling = 10;
    %sceneParams.MaxTxBeamLength = 4;
    %sceneParams.MaxRxBeamLength = 2;
    
    %killPC(sceneParams, wT, wR);
    %axis tight;
    %view([74 29]);
end