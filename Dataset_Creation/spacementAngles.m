function m = spacementAngles(number, x_min, x_max, y_min, y_max)
    % Define the dimensions of the matrix
    rows = sqrt(number);
    cols = sqrt(number);
    
    % Initialize the matrix
    m = cell(rows, cols);
    
    % Define the ranges for X and Y coordinates
    % x_min = -150;
    % x_max = 150;
    % y_min = -60;
    % y_max = 60;
    
    % Calculate the step size for X and Y
    x_step = (x_max - x_min) / (cols - 1);
    y_step = (y_max - y_min) / (rows - 1);
    
    % Populate the matrix with (X, Y) coordinates
    for i = 1:rows
        for j = 1:cols
            x = x_min + (j - 1) * x_step;
            y = y_min + (i - 1) * y_step;
            m{i, j} = [x, y];
        end
    end
   
end