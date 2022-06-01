s = Stimulus(1e4, 2200, 'triangular', 20e-3, 2e-3);
[stim, times, trigs] = s.generateStimulus(1.0, 10, 5);
excitatory_synapse = Synapse(0.03, 1);
excitatory_synapse = excitatory_synapse.set(find(trigs)./1e4);
response = excitatory_synapse.get(times, 'summation', -0.05, 1e4);
plot(times, response);