%% Build stimulus triggers:
fs = 1e4;
sim_times = (0:1/fs:1-(1/fs));
nbatches = 200;
ntimesteps = numel(sim_times);
spikes = zeros(nbatches, numel(sim_times));
spikes(:, 1:10) = 1;
for i = 1: 1: nbatches
    spikes(i, :) = spikes(i, randperm(ntimesteps));
end

%% Load parameters form template:
parameters = load('synapse_template_parameters.mat').parameters;

%% Initialize parallel processing:
if isempty(gcp('nocreate')) % Check if parallel pool exists
    parpool('local'); % Start a new one if not
end

%% Initialize synapse:
syn_e = Synapse(parameters);

%% Propagate inputs through the synapse:
output=syn_e.propagate(fs, sim_times, spikes);

%% Plot output:
figure();
plot(sim_times, output);