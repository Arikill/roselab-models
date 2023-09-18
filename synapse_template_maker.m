%% Build parameters:
parameters = {};

 % time constant of the synaptic response (sec).
parameters.tau = 0.01;

% gain or amplitude of the synaptic response conductance (S).
parameters.gain = 1e-9;

% delay in response after input event (sec).
parameters.delay = 0.01;

% Synaptic reversal potential (mV).
parameters.Erev = -30e-3;

% plasticity of the response.
parameters.plasticity = {};
% plasticity.interval: % the interval at which plasticity, like depression or summation, start (sec or 1/Hz).
parameters.plasticity.interval = 1/30;
% plasticity.tau: time constant factor that determines the strength of depression or summation over time (sec).
parameters.plasticity.tau = 0.01;
% plasticity.type: % type of depression or summation scaling (eg., quadratic or simple).
parameters.plasticity.type="simple";
% plasticity.sweep: % if sweep is positivie (+1) the synapse exhibits
% summation or facilitation; negative (-1) sweep results in depression.
parameters.plasticity.sweep = 1;

%% Save parameters:
save("synapse_template_parameters.mat", "parameters");