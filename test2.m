%% Build Stimulus
s = Stimulus(1e4, 2200, 'triangular', 20e-3, 2e-3, 0, 0);
[stim, times, trigs] = s.generateStimulus(1.0, 70, 5);

%% Template Neuronal parameters
template_parameters = load('template_parameters.mat').template_parameters;
parameters = {};
%% Afferent neuronal parameters
parameters.afferent = template_parameters;

%% Short-pass duration neuronal parameters
parameters.short_pass = template_parameters;
parameters.short_pass.delay = 0;
parameters.short_pass.Eth = -56.1e-3;
parameters.short_pass.syne.tau = 0.02;
parameters.short_pass.syne.delay = 0.02;
parameters.short_pass.syne.integration_tau = -0.045;
parameters.short_pass.syni.integration_tau = -0.1;

%% Relay neuronal parameters
parameters.relay = template_parameters;

%% LIN neural parameters
parameters.lin = template_parameters;

%% Build neural network:
afferent = Neuron2(s.fs, parameters.afferent);
relay = Neuron2(s.fs, parameters.relay);
short_pass_neuron = Neuron2(s.fs, parameters.short_pass);
lin = Neuron2(s.fs, parameters.lin);

%% Propagating inputs throught the neural network:
afferent = afferent.setTrigs(trigs);
relay = relay.setTrigs(afferent.trigs);
short_pass_neuron = short_pass_neuron.propagate(times, afferent.trigs, 0);
lin = lin.propagate(times, relay.trigs, 0);

%% Plotting
figure("Name", "Test 2 Stimulus and Neuronal response plots");
tiledlayout(7, 1);
ax = cell(7, 1);
ax{1, 1} = nexttile;
plot(times, lin.Vm, 'k');
ax{1, 1}.YLabel.String = "Vm (mV)";

ax{2, 1} = nexttile;
plot(times, lin.syne.g, 'r', times, lin.syni.g, 'b');
ax{2, 1}.YLabel.String = "G (S)";

ax{3, 1} = nexttile;
plot(times, short_pass_neuron.Vm, 'k');
ax{3, 1}.YLabel.String = "Vm (mV)";

ax{4, 1} = nexttile;
plot(times, short_pass_neuron.syne.g, 'r', times, short_pass_neuron.syni.g, 'b');
ax{4, 1}.YLabel.String = "G (S)";

ax{5, 1} = nexttile;
plot(times, relay.trigs, 'k');
ax{5, 1}.YLabel.String = "Relay response";

ax{6, 1} = nexttile;
plot(times, afferent.trigs, 'k');
ax{6, 1}.YLabel.String = "Afferent response";

ax{7, 1} = nexttile;
plot(times, stim, 'k');
ax{7, 1}.YLabel.String = "Stimulus";
ax{7, 1}.XLabel.String = "time (sec)";

linkaxes([ax{:, 1}], 'x');
xlim('tight');

