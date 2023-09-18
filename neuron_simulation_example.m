%% Build stimulus triggers:
fs = 1e4;
sim_times = (0:1/fs:1-(1/fs));
nbatches = 200;
ntimesteps = numel(sim_times);
espikes = zeros(nbatches, numel(sim_times));
ispikes = zeros(nbatches, numel(sim_times));
espikes(:, 1:10) = 1;
for i = 1: 1: nbatches
    espikes(i, :) = espikes(i, randperm(ntimesteps));
    ispikes(i, :) = espikes(i, randperm(ntimesteps));
end

%% Load parameters from template:
parameters = load("neuron_template_parameters.mat").parameters;
parameters.Eth = -40e-3;

%% Initialize parallel processing:
if isempty(gcp('nocreate')) % Check if parallel pool exists
    parpool('local'); % Start a new one if not
end

%% Initialize neuron:

nrn = Neuron(parameters);
[Vm, spikes, ge, gi] = nrn.propagate(fs, sim_times, espikes, ispikes, 0);

%% Plot:
figure();
tiledlayout(4, 1);
nexttile;
plot(sim_times, spikes);
nexttile;
plot(sim_times, Vm);
nexttile;
plot(sim_times, ge);
nexttile;
plot(sim_times, gi);