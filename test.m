s = Stimulus(1e4, 2200, 'triangular', 20e-3, 2e-3);
[stim, times, trigs] = s.generateStimulus(1.0, 10, 5);
excitatory_synapse = Synapse(1e-9, 0.03);
excitation = excitatory_synapse.call(trigs, s.fs, 'summation', 0.01);
inhibitory_synapse = Synapse(1e-9, 0.02);
inhibition = inhibitory_synapse.call(trigs, s.fs, 'maxima', 0.08);
neuron = Neuron(14e-12, 0.5e9, -65e-3, -30e-3, -100e-3, -32e-3, 10e-3);
response = neuron.call(0e-9, excitation, inhibition, 1e4);
tiledlayout(3, 1)
nexttile;
plot(times, response, 'k');
nexttile;
plot(times, excitation, 'r', times, -1.*inhibition, 'b');
nexttile;
plot(times, stim);
