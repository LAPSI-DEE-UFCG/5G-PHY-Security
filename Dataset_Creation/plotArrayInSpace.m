function plotArrayInSpace(array, sv, pos, fc)
    [pat,aZRange,eLRange] = pattern(array, fc, 'Weights', sv);
        
    beam = db2mag(pat);
    beam = (beam/max(beam(:)))*5;
    [x1,y1,z1] = sph2cart(deg2rad(aZRange),deg2rad(eLRange'),beam);

    handle = surf(x1+pos(1),...
                        y1+pos(2), ...
                        z1+pos(3));
    handle.EdgeColor = 'none';
    handle.FaceAlpha = 0.9;
end