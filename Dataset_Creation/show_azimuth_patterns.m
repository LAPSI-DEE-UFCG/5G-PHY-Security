%%
% Show azimuth patterns for the L antennas generated

% L and the antennas must be generated before executing this script

for i = 1:L
    fprintf("Plotting array - %d\n", i);
    filename = "antennas\cra_" + i + ".mat";
    load(filename);
    patternAzimuth(cra, 28e09);
    hold on
end