%% Build Stimulus
s = Stimulus(1e4, 2200, 'triangular', 20e-3, 2e-3, 0, 0);

%% Template Neuronal parameters
template_parameters = load('template_parameters.mat').template_parameters;
parameters = {};
%% Afferent neuronal parameters
parameters.afferent = template_parameters;

%% Relay neuronal parameters
parameters.relay = template_parameters;
parameters.relay.delay = 0.005;

%% ICN neuronal paramters
parameters.icn = template_parameters;
parameters.icn.syne.tau = 0.01;
parameters.icn.syne.delay = 0.03;
parameters.icn.syne.integration_tau = 10;
parameters.icn.syne.integration_type = "exponential";
parameters.icn.Eth = -56e-3;
parameters.icn.syni.tau = 0.04;
parameters.icn.syni.integration_tau = 0;

%% Build neural network:
afferent = Neuron2(s.fs, parameters.afferent);
relay = Neuron2(s.fs, parameters.relay);
icn = Neuron2(s.fs, parameters.icn);

%% Make Stimulus
pulses = [1, 3, 5];
pulseRate = [60, 60, 60];
stimDuration = 1.0;
nitems = size(pulses, 2);
figure("Name", "Network level realization of Edwards et. al., 2008 ICN");
nplots = 5;
tiles = tiledlayout(nplots, nitems, "TileIndexing","columnmajor");
ax = cell(nplots, nitems);

for i = 1: 1: nitems
    [stim, times, trigs] = s.generateStimulus(stimDuration, pulseRate(i), pulses(i));
    afferent = afferent.setTrigs(trigs);
    relay = relay.setTrigs(afferent.trigs);
    icn = icn.propagate(times, relay.trigs, afferent.trigs, 0);
    for j = 1: 1: nplots
        ax{j, i} = nexttile;
        if j == 1
            plot(ax{j, i}, times, icn.Vm, 'k');
            ax{j, i}.Subtitle.String = "ICN";
            if i == 1
                ax{j, i}.YLabel.String = "Vm (V)";
            end
        elseif j == 2
            plot(ax{j, i}, times, icn.syne.g, 'Color', [255 0 0]./255);
            hold on;
            plot(ax{j, i}, times, icn.syni.g, 'Color', [0 150 255]./255);
            hold off;
            if i == 1
                ax{j, i}.YLabel.String = "G (S)";
            end
        elseif j == 3
            plot(ax{j, i}, times, relay.trigs, 'k');
            ax{j, i}.Subtitle.String = "Relay";
            if i == 1
                ax{j, i}.YLabel.String = "Rep. Spikes";
            end
        elseif j == 4
            plot(ax{j, i}, times, afferent.trigs, 'k');
            ax{j, i}.Subtitle.String = "Afferent";
            if i == 1
                ax{j, i}.YLabel.String = "Rep. Spikes";
            end
        elseif j == 5
            plot(ax{j, i}, times, stim, 'k');
            ax{j, i}.Subtitle.String = "Stimulus";
            if i == 1
                ax{j, i}.YLabel.String = "V (V)";
            end
            ax{j, i}.XLabel.String = "time (sec)";
        end
        linkaxes([ax{j, :}], 'y');
    end
    ax{1, i}.Title.String = sprintf("%d pulses @ %d pps", pulses(i), pulseRate(i));
    linkaxes([ax{:, i}], 'x');
    xlim('tight');
end