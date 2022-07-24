s = Stimulus(1e4, 2200, 'triangular', 20e-3, 2e-3);
[stim, times, trigs] = s.generateStimulus(1.0, 80, 5);

disp("Afferent");
afferent = {};
afferent.neuron = Neuron(14e-12, 0.5e9, -65e-3, -30e-3, -100e-3, -55e-3, -20e-3, 0.02);
afferent.excitatorySynapse = Synapse(1e-9, 0.01);
afferent.excitation = afferent.excitatorySynapse.call(trigs, s.fs, 0, 0, 0.01);
afferent.inhibitorySynapse = Synapse(0e-9, 0.01);
afferent.inhibition = afferent.inhibitorySynapse.call(trigs, s.fs, 0, 0, 0.01);
[afferent.response, afferent.spkTrigs] = afferent.neuron.call(0e-9, afferent.excitation, afferent.inhibition, s.fs);

disp("Relay");
relayNeuron = {};
relayNeuron.neuron = Neuron(14e-12, 0.5e9, -65e-3, -30e-3, -100e-3, -55e-3, -20e-3, 0.02);
relayNeuron.excitatorySynapse = Synapse(1e-9, 0.01);
relayNeuron.excitation = relayNeuron.excitatorySynapse.call(afferent.spkTrigs, s.fs, 0, 0, 0.01);
relayNeuron.inhibitorySynapse = Synapse(0e-9, 0.01);
relayNeuron.inhibition = relayNeuron.inhibitorySynapse.call(afferent.spkTrigs, s.fs, 0, 0, 0.01);
[relayNeuron.response, relayNeuron.spkTrigs] = relayNeuron.neuron.call(0e-9, relayNeuron.excitation, relayNeuron.inhibition, s.fs);

disp("LIN");
lin = {};
lin.neuron = Neuron(14e-12, 0.5e9, -65e-3, -30e-3, -100e-3, -57e-3, -20e-3, 0.03);
lin.excitatorySynapse = Synapse(1e-9, 0.03);
lin.excitation = lin.excitatorySynapse.call(trigs, s.fs, 1/30, 0.03, 0.035);
lin.inhibitorySynapse = Synapse(0.8e-9, 0.01);
lin.inhibition = lin.inhibitorySynapse.call(relayNeuron.spkTrigs, s.fs, 1/30, 0.08, 0.01);
[lin.response, lin.spkTrigs] = lin.neuron.call(0e-9, lin.excitation, lin.inhibition, s.fs);

disp("ICN");
icn = {};
icn.neuron = Neuron(14e-12, 0.5e9, -65e-3, -30e-3, -100e-3, -57e-3, -20e-3, 0.03);
icn.excitatorySynapse = Synapse(0.6e-9, 0.02);
icn.excitation = icn.excitatorySynapse.call(trigs, s.fs, 1/30, 0.1, 0.055);
icn.inhibitorySynapse = Synapse(1e-9, 0.015);
icn.inhibition = icn.inhibitorySynapse.call(lin.spkTrigs, s.fs, 1/30, -0.05, 0.01);
[icn.response, icn.spkTrigs] = icn.neuron.call(0e-9, icn.excitation, icn.inhibition, s.fs);

figure();
tiledlayout(5, 1);
ax(1) = nexttile;
plot(times, icn.spkTrigs, 'k');
ylabel('ICN');
ax(2) = nexttile;
plot(times, lin.spkTrigs, 'k');
ylabel('LIN');
ax(3) = nexttile;
plot(times, relayNeuron.spkTrigs, 'k');
ylabel('Relay neuron');
ax(4) = nexttile;
plot(times, afferent.spkTrigs, 'k');
ylabel('Afferent neuron');
ax(5) = nexttile;
plot(times, stim, 'k');
ylabel('stimulus');
xlabel('time(sec)');
linkaxes(ax, 'x');