function [azimuth, elevation] = calculateAzimuthElevation(point1, point2)
    % Calculate the vector from point2 to point1
    vector = point1 - point2;
    
    % Calculate the azimuth angle (angle in the XY plane)
    azimuth = atan2(vector(2), vector(1));
    
    % Calculate the elevation angle (angle in the XZ plane)
    elevation = atan2(vector(3), sqrt(vector(1)^2 + vector(2)^2));
    
    % Convert angles from radians to degrees
    azimuth = rad2deg(azimuth);
    elevation = rad2deg(elevation);
end