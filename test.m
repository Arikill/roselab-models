s = Stimulus(1e4, 2200, 'triangular', 10e-3, 2e-3, 40e-3, 3);
[stim, times, trigs] = s.generateStimulus(1.0, 50, 5);
figure();
ax = cell(2, 1);
tiledlayout(2, 1);
ax{1, 1} = nexttile;
plot(times, stim);
ax{2, 1} = nexttile;
plot(times, trigs);
