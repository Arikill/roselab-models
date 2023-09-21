%% Build parameters
parameters = {};

% Membrane capacitance of the neuron (F).
parameters.Cm = 6e-11;

% Input resistance of the neuron (ohms).
parameters.Rin = 0.5e9;

% Resting potential of the neuron (V).
parameters.Er = -65e-3;

% Threshold potential of the neuron (V).
parameters.Eth = -20e-3;

% Maximum membrane potential, spike peak (V).
parameters.Emax = 0e-3;

% Refractory period. Minimum period between output spikes (sec).
parameters.Tr = 2e-3;

% Excitatory synapse parameters. Load from template.
parameters.syne = load("./settings/synapse_default_parameters.mat").parameters;

% Inhibitory synapse parameters. Load from template.
parameters.syni = load("./settings/synapse_default_parameters.mat").parameters;
% parameters.syni.gain = -1*parameters.syni.gain;
parameters.syni.Erev = -100e-3;

%% Save parameters
save("./settings/neuron_default_parameters.mat", "parameters");

