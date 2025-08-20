function measurementsArray = gen_dataset()

    fprintf("This script will generate the datasets for all the antennas, " + ...
        "varying it positions and the angle of measurement\n");
    
    numberOfDevices = 4;
    numberOfDistances = 1;
    numberOfUeBeams = 256;
    numberOfGnbBeams = 1000;
    c = physconst('LightSpeed');
    fc = 28e9;
        
    numberOfMeasurements = numberOfDistances*numberOfGnbBeams*numberOfUeBeams;

    measurementsArray = zeros([numberOfDevices, numberOfMeasurements]);
    fprintf("Total of measurements that will be made for each device: %d\n", length(measurementsArray));
    minDistance = 5; %m
    maxDistance = 15; %m
    gnbPos = [maxDistance;maxDistance;maxDistance];
    uePos = generatePointWithinRadius(minDistance, maxDistance);

    % [ueAz, ueEl, gnbAz, gnbEl] = azAndEl(uePos, gnbPos, false);
       
    % minAz = max(-180, gnbAz-15);
    % maxAz = min(180, gnbAz+15);
    % minEl = max(-90, gnbEl-15);
    % maxEl = min(90, gnbEl+15);

    % gnbBeams = spacementAngles(numberOfGnbBeams, minAz, maxAz, minEl, maxEl);
    % gnbBeams = reshape(gnbBeams, [numberOfGnbBeams, 1]);
    

    deviceSizes = [6 6 6 6];
    for i=1:numberOfDevices
        measurementsIndex = 1;
        fprintf("Current on device %d\n", i);
        % Configuring the antennas
        % gnB (Transmitter)
        gnbArray = generate_phased_array(false, 16);
        gnbArray.ElementNormal = [0; 90];
        gnbSteeringVector = phased.SteeringVector('SensorArray', gnbArray, ...
            'PropagationSpeed', c);
    
        % ue (Receiver)
        filename = "antennas/cra_" + i + ".mat";
        load(filename, "cra");
        
        ueSteeringVector = phased.SteeringVector('SensorArray', cra, ...
            'PropagationSpeed', c);
        % uePos = generatePointWithinRadius(minDistance, maxDistance);
        for j=1:numberOfDistances
            % Extract the data from different measurements
            % uePos = generatePointWithinRadius(minDistance, maxDistance);

            [ueAz, ueEl, gnbAz, gnbEl] = azAndEl(uePos, gnbPos, false);
               
            minAz = max(-180, ueAz-30);
            maxAz = min(180, ueAz+30);
            minEl = max(-90, ueEl-30);
            maxEl = min(90, ueEl+30);
        
            ueBeams = spacementAngles(numberOfUeBeams, minAz, maxAz, minEl, maxEl);
            ueBeams = reshape(ueBeams, [numberOfUeBeams, 1]);

            [d, ~] = rangeangle(gnbPos, uePos);
            fprintf("Measuring now to distance %f\n - index = %d\n", d, j);
            %[ueAz, ueEl, gnbAz, gnbEl] = azAndEl(uePos, gnbPos, false);
               
            gnbSV = gnbSteeringVector(fc, [gnbAz; gnbEl]);

            for k=1:numberOfGnbBeams
                % Change the angle a little bit inside the sweep
                [carrier, rxGrid, csirs] = gen_waveform(gnbArray, cra, gnbSV, gnbPos, uePos, deviceSizes(i));
                fprintf("Angles of TX = %f Az and %f El - Index = %d\n", ueAz, ueEl, k);
                    
                for l=1:numberOfUeBeams
                    % Sweep for azimuth and elevation inside the GNB range
                    % gnbAng = [gnbAz; gnbEl];
                    ueAng = cell2mat(ueBeams(l));
                    ueAzSweep = ueAng(1);
                    ueElSweep = ueAng(2);
    
                    % fprintf("Angles of RX = %f Az and %f El - Index = %d\n", gnbAzSweep, gnbElSweep, l);
    
                    ueSV = ueSteeringVector(fc, [ueAzSweep; ueElSweep]);
    
                   
                    % Simulate the channel and get measures
                    dbM = getMeasures(ueSV, carrier, rxGrid, csirs, deviceSizes(i));
                    measurementsArray(i, measurementsIndex,: ) = dbM;
                    measurementsIndex = measurementsIndex + 1;
                end
            fprintf("- Percentage = %f %%" + ...
                    "Device = %d \n", measurementsIndex/numberOfMeasurements*100, i);
            end
        end
    end

    plotArrayInSpace(cra, ueSV, uePos, fc);
    hold on;
    plotArrayInSpace(gnbArray, gnbSV, gnbPos, fc);

end