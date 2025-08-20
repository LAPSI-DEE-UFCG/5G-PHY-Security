function randomValue = randomize(MIN, MAX)
    % Check if the input values are valid
    if MIN >= MAX
        error('MIN must be less than MAX');
    end

    % Generate a random value between 0 and 1
    randomValue = rand;

    % Scale and shift the random value to fit between MIN and MAX
    randomValue = MIN + randomValue * (MAX - MIN);
end
