function beamDir = getInitialBeamDir(scatAng,azBeamWidth,elBeamWidth)
%   getInitialBeamDir returns the initial beam direction BEAMDIR, given the
%   angle of scatterer position with respect to transmit or receive antenna
%   array SCATANG, beamwidth of transmit or receive beam in azimuth plane
%   AZBEAMWIDTH, and beamwidth of transmit or receive beam in elevation
%   plane ELBEAMWIDTH.

    % Azimuth angle boundaries of all transmit/receive beams
    azSSBSweep = -180:azBeamWidth:180;
    % Elevation angle boundaries of all transmit/receive beams
    elSSBSweep = -90:elBeamWidth:90;
    
    % Get the azimuth angle of transmit/receive beam
    azIdx1 = find(azSSBSweep <= scatAng(1),1,'last');
    azIdx2 = find(azSSBSweep >= scatAng(1),1,'first');
    azAng = (azSSBSweep(azIdx1) + azSSBSweep(azIdx2))/2;
    
    % Get the elevation angle of transmit/receive beam
    elIdx1 = find(elSSBSweep <= scatAng(2),1,'last');
    elIdx2 = find(elSSBSweep >= scatAng(2),1,'first');
    elAng = (elSSBSweep(elIdx1) + elSSBSweep(elIdx2))/2;
    
    % Form the azimuth and elevation angle pair (in the form of [az;el])
    % for transmit/receive beam
    beamDir = [azAng;elAng];
end