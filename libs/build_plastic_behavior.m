function scaler = build_plastic_behavior(spike_times, plsty)
    % This code currently focuses on simple plastic behavior. It is
    % not optimized for other kinds of plastic behaviors.
    % This function is not part of the Synapse class method due to avoid object
    % copy overhead in parallel processing.

    if strcmp(plsty.type, "quadratic")
        scaler = normalize(spike_times.^2, 'range');
        scaler = scaler + plsty.tau;
    elseif strcmp(plsty.type, "simple")
        % Find the distance between temporal inputs (spikes).
        diff_spike_times = [0, diff(spike_times)];

        % If the temporal inputs are close enough, i.e. within the
        % interval range for plastic/non-linear behavior, then
        % summation(or facilitation) or depression occurs.
        scaler = cumsum((diff_spike_times < plsty.interval) * plsty.tau * plsty.sweep);

        % The amount of plasticity depends on number of inputs.
        % Although it might plateau after a certain number of
        % spikes, its not currently modeled into the system.
        scaler = normalize(scaler, 'range', [1, numel(spike_times)]);
    elseif strcmp(plsty.type, "exponential")
        scaler = 1-exp(-plsty.tau .* spike_times);
    end
end