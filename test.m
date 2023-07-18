% Time parameters
t_start = 0;            % Start time
t_end = 10;             % End time
sampling_rate = 1e4;    % Sampling rate
dt = 1/sampling_rate;   % Time step

% Growth parameters
growth_rate = 0.01;     % Growth rate
initial_value = 1;      % Initial value

% Time vector
t = [0.0051    0.0217    0.0383    0.0549    0.071];

% Calculate the exponential growth
y = initial_value * exp(growth_rate * t);

% Plotting the results
plot(t, y)
xlabel('Time')
ylabel('Value')
title('Time-Dependent Slow Exponential Growth')