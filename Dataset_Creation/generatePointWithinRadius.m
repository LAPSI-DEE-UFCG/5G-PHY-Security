function point1 = generatePointWithinRadius(minDistance, maxDistance)
    % Generate random coordinates for point 1 within the maximum distance radius of point2
    
    minTheta = 45;
    maxTheta = 135;
    
    thetaDeg = randomize(minTheta, maxTheta);
    theta = deg2rad(thetaDeg);
    
    
    % Generate random phi within the range [0, pi]
    %phiDeg = acos(2 * rand - 1)
    phiDeg = randomize(minTheta, maxTheta);
    phi = deg2rad(phiDeg);
    % Generate random radius within the specified range
    r = randomize(minDistance, maxDistance);

    % Convert spherical coordinates to Cartesian coordinates
    [x, y, z] = sph2cart(phi, theta, r);
    
    point1 = [x; y; z];
end