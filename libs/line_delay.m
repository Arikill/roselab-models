function y = line_delay(x, t, fs)
   % Calculate the number of samples to delay or advance
    shift_samples = round(t * fs);
    
    % Get the number of batches
    nbatches = size(x, 1);
    
    % Initialize the delayedSpikes array
    y = false(size(x));
    
    for i = 1:nbatches
        y(i, :) = processRow(x(i, :), shift_samples);
    end
end

function y = processRow(x, shift_samples)
    ntimesteps = length(x);
    
    if shift_samples >= ntimesteps
        error('The shift duration is longer than the duration of the data. Please provide a valid delay or advance time.');
    end
    
    if shift_samples > 0  % Delay
        y = [false(1, shift_samples), x(1:end-shift_samples)];
    else                  % Advance
        advance_samples = abs(shift_samples);
        y = [x(1+advance_samples:end), false(1, advance_samples)];
    end
end