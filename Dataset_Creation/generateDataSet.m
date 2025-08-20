nOfBeamsPerDevice = 500;
device_ID = 1;

% Configure RX fixed position
rxPos = [0; 0; 0];

% Configure the TX position for this iteration
minRadius = 10; % meters
maxRadius = 20; % meters
[txPos, txToRxAngle, txToRxDistance] = generatePointWithinRadius(rxPos, minRadius, maxRadius);

% Configuring the TX beam sweep intervals considering a direct PATH beam
% transmition

[rxToTxAz, rxToTxEl] = calculateAzimuthElevation(txPos, rxPos);


txAzSweep = [-rxToTxAz - 80 -rxToTxAz + 80];
txElSweep = [-rxToTxEl - 80 -rxToTxEl + 80];

txAng = [randomize(txAzSweep(1), txAzSweep(2)), randomize(txElSweep(1), txElSweep(2))];

% Configuring the RX beam sweep 
rxAng = zeros([2 nOfBeamsPerDevice]);

for i = 1:nOfBeamsPerDevice
    rxAng(:,i) = [randomize(-180, 180), randomize(-90, 90)];
end

fprintf('Generating dataset for following configurations:\n');
fprintf('Device: %d\n', device_ID);
fprintf('Tx array position: [%f, %f, %f]\n', txPos);
fprintf('Rx array position: [%f, %f, %f]\n', rxPos);
fprintf('Distance between Tx and Rx (meters): %f\n', txToRxDistance);
fprintf('*****************************************\n');
dbM = getMeasures(device_ID, txAng, rxAng, txPos, rxPos);
