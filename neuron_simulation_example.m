tic;
%% Build stimulus triggers:
fs = 1e4;
sim_times = (0:1/fs:1-(1/fs));
nbatches = 1;
ntimesteps = numel(sim_times);
espikes = zeros(nbatches, numel(sim_times));
ispikes = zeros(nbatches, numel(sim_times));
espikes(:, 1:40) = 1;
for i = 1: 1: nbatches
    espikes(i, :) = espikes(i, randperm(ntimesteps));
    ispikes(i, :) = espikes(i, randperm(ntimesteps));
end


%% Load parameters from template:
parameters = load("./settings/neuron_default_parameters.mat").parameters;
parameters.Eth = -50e-3;
parameters.syne.tau = 0.01;
parameters.syne.interval = 1/150;

%% Initialize parallel processing:
% if isempty(gcp('nocreate')) % Check if parallel pool exists
%     parpool('local'); % Start a new one if not
% end

%% Initialize neuron:
nrn = Neuron(parameters);
[Vm, spikes, ge, gi] = nrn.propagate(fs, sim_times, espikes, ispikes, 0);

%% Plot:
figure();
tiledlayout(4, 1);
ax = cell(4, 1);
ax{1} = nexttile;
plot(sim_times, spikes);
ax{2} = nexttile;
plot(sim_times, Vm);
ax{3} = nexttile;
plot(sim_times, ge);
ax{4} = nexttile;
plot(sim_times, gi);
linkaxes([ax{1}, ax{2}, ax{3}, ax{4}], 'x');
