%% Build stimulus triggers:
fs = 1e4;
sim_times = (0:1/fs:1-(1/fs));

% Example that builds 10 events at 30 pps.
events = build_events(sim_times, 10, 5);

% Extending for batch inputs:
nbatches = 15;
ntimesteps = numel(sim_times);
batch_events = zeros(nbatches, ntimesteps) + events;

% for z = 1: nbatches
%     batch_events(z, :) = batch_events(z, randperm(ntimesteps));
% end

%% Load parameters from template:
default_params = load("./settings/neuron_default_parameters.mat").parameters;

%% Set parameters:
% LIN
lin = {};
lin.parameters = default_params;
lin.parameters.Emax = -20e-3;
lin.parameters.Cm = 5e-11;
lin.parameters.Eth = -59.5e-3;
lin.parameters.syne.gain = 1.0e-9;
lin.parameters.syne.tau = 0.008;
lin.parameters.syne.plasticity.tau = 0;
lin.parameters.syne.plasticity.interval = 1/30;
lin.parameters.syni.gain = 1e-9;
lin.parameters.syni.tau = 0.005;
lin.parameters.syni.delay = 0.023;
lin.parameters.syni.plasticity.interval = 1/30;
lin.parameters.syni.plasticity.tau = -0.162;

% ICN
icn = {};
icn.parameters = default_params;
icn.parameters.Emax = -20e-3;
icn.parameters.Cm = 5e-11;
icn.parameters.Eth = -56.5e-3;
icn.parameters.syne.delay = 0.03;

%% Initialize circuit:
circuit = {};
circuit.lin = Neuron(lin.parameters);
circuit.icn = Neuron(icn.parameters);

%% Circuit propagation:
% Propagate inputs through afferent.
afferent.spikes = line_delay(batch_events, 0.01, fs);

% Propagate inputs through excitatory relay.
erelay.spikes = line_delay(afferent.spikes, 0.01, fs);

% Propagate inputs through inhibitory relay.
irelay.spikes = line_delay(afferent.spikes, lin.parameters.syni.delay, fs);

% Propagate inputs through lin.
[lin.Vm, lin.spikes, lin.ge, lin.gi] = circuit.lin.propagate(fs, sim_times, erelay.spikes, irelay.spikes, 0);
lin.Vm(lin.spikes > 0) = circuit.lin.Emax;

% Propagate inputs through icn.
delayed_lin_spikes = line_delay(lin.spikes, icn.parameters.syni.delay, fs);
delayed_erelay_spikes = line_delay(erelay.spikes, icn.parameters.syne.delay, fs);
[icn.Vm, icn.spikes, icn.ge, icn.gi] = circuit.icn.propagate(fs, sim_times, delayed_erelay_spikes, delayed_lin_spikes, 0);
icn.Vm(icn.spikes > 0) = circuit.icn.Emax;

%% Plotting
figure('Name', 'Naud 2015 Simulation');
tiledlayout(7, 1);
ax = cell(5, 1);
ax{1} = nexttile;
plot(sim_times, events);
ylabel('Inputs');
ax{2} = nexttile;
plot(sim_times, afferent.spikes);
ylabel('Afferent Spikes');
ax{3} = nexttile;
plot(sim_times, erelay.spikes, 'r', sim_times, irelay.spikes, 'b');
ylabel('Relays spike');
ax{4} = nexttile;
plot(sim_times, lin.ge, 'r', sim_times, lin.gi, 'b');
ylabel('LIN gs (S)');
ax{5} = nexttile;
plot(sim_times, lin.Vm);
ylabel('LIN Vm (V)');
ax{6} = nexttile;
plot(sim_times, icn.ge, 'r', sim_times, icn.gi, 'b');
ylabel('ICN gs (S)');
ax{7} = nexttile;
plot(sim_times, icn.Vm);
ylabel('ICN Vm (V)');

linkaxes([ax{1}, ax{2}, ax{3}, ax{4}, ax{5}, ax{6}, ax{7}], 'x');
linkaxes([ax{5}, ax{7}], 'y');
