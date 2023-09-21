function scaler = build_plastic_behavior(spike_times, plsty)
    % This code currently focuses on simple plastic behavior. It is
    % not optimized for other kinds of plastic behaviors.
    % This function is not part of the Synapse class method due to avoid object
    % copy overhead in parallel processing.
    mean_spike_interval = mean(diff(spike_times));
    increment = plsty.tau * (mean_spike_interval < plsty.interval);
    scaler = cumsum([1, increment * ones(1, numel(spike_times)-1)]);
end