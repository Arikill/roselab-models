s = Stimulus(1e4, 2200, 'triangular', 20e-3, 2e-3);
[stim, times, trigs] = s.generateStimulus(1.0, 5, 5);

relayNeuron = {};
relayNeuron.neuron = Neuron(14e-11, 0.5e9, -65e-3, -30e-3, -100e-3, -61e-3, -20e-3, 0.02);
relayNeuron.excitatorySynapse = Synapse(1e-9, 0.01);
relayNeuron.excitation = relayNeuron.excitatorySynapse.call(trigs, s.fs, 'maxima', 0.01);
relayNeuron.inhibitorySynapse = Synapse(0e-9, 0.01);
relayNeuron.inhibition = relayNeuron.inhibitorySynapse.call(trigs, s.fs, 'maxima', 0.01);
[relayNeuron.response, relayNeuron.spkTrigs] = relayNeuron.neuron.call(0e-9, relayNeuron.excitation, relayNeuron.inhibition, s.fs);

lin = {};
lin.neuron = Neuron(14e-11, 0.5e9, -65e-3, -30e-3, -100e-3, -63.5e-3, -20e-3, 0.03);
lin.excitatorySynapse = Synapse(1e-9, 0.005);
lin.excitation = lin.excitatorySynapse.call(trigs, s.fs, 'depression', 0.025);
lin.inhibitorySynapse = Synapse(1e-9, 0.01);
lin.inhibition = lin.inhibitorySynapse.call(relayNeuron.spkTrigs, s.fs, 'depression', 0.01);
[lin.response, lin.spkTrigs] = lin.neuron.call(0e-9, lin.excitation, lin.inhibition, s.fs);

figure();
tiledlayout(5, 1);
nexttile;
plot(times, lin.response, 'k');
ylabel('LIN response');
nexttile;
plot(times, lin.excitation, 'r', times, lin.inhibition, 'b');
ylabel('LIN conductances');
nexttile;
plot(times, relayNeuron.response, 'k');
ylabel('Relay neuron response');
nexttile;
plot(times, relayNeuron.excitation, 'r', times, relayNeuron.inhibition, 'b');
ylabel('Relay neuron conductances');
nexttile;
plot(times, stim, 'k');
ylabel('stimulus');
xlabel('time(sec)')

% excitatory_synapse = Synapse(1e-9, 0.01);
% excitation = excitatory_synapse.call(trigs, s.fs, 'summation', 0.03);
% inhibitory_synapse = Synapse(0.5e-9, 0.02);
% inhibition = inhibitory_synapse.call(trigs, s.fs, 'maxima', 0.01);
% neuron = Neuron(14e-11, 0.5e9, -65e-3, -30e-3, -100e-3, -59e-3, 10e-3);
% [response, spkTrigs] = neuron.call(0e-9, excitation, inhibition, 1e4);
% figure();
% tiledlayout(4, 1)
% nexttile;
% plot(times, response, 'k');
% nexttile;
% plot(times, spkTrigs, 'k');
% nexttile;
% plot(times, excitation, 'r', times, inhibition, 'b');
% nexttile;
% plot(times, stim);