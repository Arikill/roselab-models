clear; clc;
tau = 0.02;
td = 0.01;
gmax = 1;
fs = 1e2;
tstart = 0;
tend = 1;
timesteps = floor(fs*(tend - tstart));
times = linspace(tstart, tend, timesteps);
alpha = zeros(size(times));

for t = 2: 1: timesteps
%     alpha(:, t) = alpha(:, t-1) + (1/fs)*(times(:, t-1)>td)*(gmax*exp(1 - (times(:, t-1) - td)/tau)/tau)*(1 - (times(:, t-1) - td)/tau);
    alpha(:, t) = alpha(:, t-1) + (1/fs)*(times(:, t-1)>td)*((gmax*exp(1 - (times(:, t-1) - td)/tau)/tau)*(1 - (times(:, t-1) - td)/tau) + (1/fs)*(1/2)*(((gmax*exp((td - times(:, t-1))/tau + 1))/tau + (gmax*exp((td - times(:, t-1))/tau + 1)*(td - times(:, t-1)))/tau^2 - (2*gmax*exp((td - times(:, t-1))/tau + 1))/tau^2 - (gmax*exp((td - times(:, t-1))/tau + 1)*(td - times(:, t-1)))/tau^3)));
end

plot(times, alpha);