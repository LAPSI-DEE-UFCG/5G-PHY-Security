%%
% Script to generate and save in files L cras

% Generate cras (L must be defined in Workspace)
%j = 4;
for i = 1:L
    cra = generate_phased_array(true, 6);
    filename = "antennas\cra_" + i + ".mat";
    save(filename, "cra");
    %j = j + 2;
end