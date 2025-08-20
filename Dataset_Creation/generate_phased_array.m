function cra = generate_phased_array(randomize, N)
    %%
    % Generate array positions
    
    d = 4e-3;
    positions_y = zeros([N]);
    positions_z = zeros([N]);
    positions = zeros([3 N^2]);
    
    % Tolerance for generate with variances
    
    
    if randomize == true
        epsilon = 0.1*d; % 10% of tolerance
    else
        epsilon = 0;
    end
    max_e = epsilon;
    min_e = -epsilon;
    range = 2*epsilon;
    
    for i = 1:N
        for j = 1:N
            if(rem(N, 2) == 0)
                positions_y(j,i) = -fix((N-1)/2)*d - d/2 + (i-1)*d + (range*rand(1) + min_e); 
                positions_z(j,i) = fix((N-1)/2)*d + d/2 - (j-1)*d + (range*rand(1) + min_e);
            else
                positions_y(j,i) = -fix((N-1)/2)*d + (i-1)*d + (range*rand(1) + min_e); 
                positions_z(j,i) = fix((N-1)/2)*d - (j-1)*d + (range*rand(1) + min_e);
            end
        end
    end
    
    y_reshape = reshape(positions_y, [N^2 1]);
    z_reshape = reshape(positions_z, [N^2 1]);
    for i = 1:size(positions, 1)
        for j = 1:size(positions, 2)
            if(i == 1) %x
                positions(i,j) = 0;
            elseif (i == 2) %y
                positions(i,j) = y_reshape(j);
            else %z
                positions(i,j) = z_reshape(j);
            end
        end
    end
    
    %%
    % Generate microPath element
    fc = 28e9;
    
    element = design(patchMicrostrip, fc);
    
    
    %%
    % Generate Conformal Array
    
    cra = phased.ConformalArray;
    cra.Element = element;
    cra.ElementPosition = positions;
    cra.ElementNormal = [0;-90];
end