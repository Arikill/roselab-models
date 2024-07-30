%% Build Stimulus
s = Stimulus(1e4, 2200, 'triangular', 20e-3, 2e-3, 0, 0);

%% Template Neuronal parameters
template_parameters = load('template_parameters.mat').template_parameters;
parameters = {};
%% Afferent neuronal parameters
parameters.afferent = template_parameters;

%% Short-pass duration neuronal parameters
parameters.short_pass = template_parameters;
parameters.short_pass.delay = 0;
parameters.short_pass.Eth = -57.8e-3;
parameters.short_pass.Tr = 0.03;
parameters.short_pass.syne.tau = 0.015;
parameters.short_pass.syne.delay = 0.02;
parameters.short_pass.syne.integration_tau = -0.045;
parameters.short_pass.syni.tau = 0.009;
parameters.short_pass.syni.integration_tau = -0.1;

%% Relay neuronal parameters
parameters.relay = template_parameters;
parameters.relay.delay = 0.005;

%% LIN neural parameters
parameters.lin = template_parameters;
parameters.lin.Eth = -59.8e-3;
parameters.lin.Tr = 0.02;
parameters.lin.syne.integration_tau = -0.065;
parameters.lin.syni.integration_tau = -0.1;
parameters.lin.syni.delay = 0.02;
parameters.lin.syni.gain = 0.7e-9;

%% ICN neuronal paramters
parameters.icn = template_parameters;
parameters.icn.Tr = 0.02;
parameters.icn.syne.delay = 0.05;
parameters.icn.syne.max_integration_interval = 1/40;
parameters.icn.syne.integration_tau = -0.025;
parameters.icn.syne.gain = 0.7e-9;
parameters.icn.Eth = -56.2e-3;
parameters.icn.syni.integration_tau = -0.1;
parameters.icn.syni.max_integration_interval = 1/25;
% parameters.icn.syni.tau = 0.02;
% parameters.icn.syne.delay = 0.02;

%% Build neural network:
afferent = Neuron2(s.fs, parameters.afferent);
relay = Neuron2(s.fs, parameters.relay);
spd = Neuron2(s.fs, parameters.short_pass);
lin = Neuron2(s.fs, parameters.lin);
icn = Neuron2(s.fs, parameters.icn);

%% Building stimulus:
pulse_rates = [10, 30, 50]; %pulses per second.
pulses = [10, 10, 10];
stimulus_duration = 1.25;
nconditions = numel(pulse_rates);
stimuli = cell(nconditions, 1);
times = cell(nconditions, 1);
triggers = cell(nconditions, 1);
for i = 1: nconditions
    [stimuli{i, 1}, times{i, 1}, triggers{i, 1}] = s.generateStimulus(stimulus_duration, pulse_rates(i), pulses(i));
end

%% Propagating inputs throught the neural network & plotting
nplots = 9;
figure_handle = figure(1);
figure_handle.Name = 'Rose-Lemmon NSF 2024 Ancestral';
tiledlayout(nplots, nconditions, "TileIndexing", "columnmajor");
axes = gobjects(nplots, nconditions);

for i = 1:nconditions
    if pulse_rates(i) == 50
        parameters.lin.syne.max_integration_interval = 1/40;
        parameters.lin.syne.integration_tau = -0.068;
        lin = Neuron2(s.fs, parameters.lin);
    end
    [afferent, relay, spd, lin, icn] = propagate(times{i, 1}, triggers{i, 1}, afferent, relay, spd, lin, icn);
    axes(1, i) = nexttile;
    plot(times{i, 1}, icn.Vm, 'k');
    ylabel(axes(1, i), 'Vm (V)');
    title(axes(1, i), 'ICN');

    axes(2, i) = nexttile;
    plot(times{i, 1}, icn.syne.g, 'r', times{i, 1}, icn.syni.g, 'b');
    ylabel(axes(2, i), 'G (S)');

    axes(3, i) = nexttile;
    plot(times{i, 1}, lin.Vm, 'k');
    ylabel(axes(3, i), 'Vm (V)');
    title(axes(3, i), 'LIN');

    axes(4, i) = nexttile;
    plot(times{i, 1}, lin.syne.g, 'r', times{i, 1}, lin.syni.g, 'b');
    ylabel(axes(4, i), 'G (S)');

    axes(5, i) = nexttile;
    plot(times{i, 1}, spd.Vm, 'k');
    ylabel(axes(5, i), 'Vm (V)');
    title(axes(5, i), 'SPD');

    axes(6, i) = nexttile;
    plot(times{i, 1}, spd.syne.g, 'r', times{i, 1}, spd.syni.g, 'b');
    ylabel(axes(6, i), 'G (S)');

    axes(7, i) = nexttile;
    plot(times{i, 1}, relay.trigs, 'k');
    ylabel(axes(7, i), "spikes");
    title(axes(7, i), 'Relay');
    
    axes(8, i) = nexttile;
    plot(times{i, 1}, afferent.trigs, 'k');
    ylabel(axes(8, i), 'spikes');
    title(axes(8, i), 'Afferent');
    
    axes(9, i) = nexttile;
    plot(times{i, 1}, stimuli{i, 1}, 'k');
    xlabel(axes(9, i), 'times (sec)');
    title(axes(9, i), 'Stimulus');

    linkaxes(axes(:, i), 'x');
    
end

for i = 1:nplots
    linkaxes(axes(i, :), 'y');
    % ylim(axes(i, :), 'tight');
end
xlim(axes, 'tight');

%% Functions
function [afferent, relay, spd, lin, icn] = propagate(times, triggers, afferent, relay, spd, lin, icn)
    afferent = afferent.setTrigs(triggers);
    relay = relay.setTrigs(afferent.trigs);
    spd = spd.propagate(times, afferent.trigs, [], 0);
    lin = lin.propagate(times, relay.trigs, [], 0);
    icn = icn.propagate(times, relay.trigs, [lin.trigs; spd.trigs], 0);
end