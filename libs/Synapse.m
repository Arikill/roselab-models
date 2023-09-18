classdef Synapse

    properties
        tau % time constant of the synaptic response (sec).
        gain % amplitude of the synaptic response conductance (S).
        delay % delay in response after input event (sec).
        Erev % Synaptic reversal potential (mV).
        plasticity % plasticity of the response.
        % plasticity.tau: time constant factor that determines the strength of depression or summation over time (sec).
        % plasticity.type: % type of depression or summation scaling (eg., quadratic or simple).
        % plasticity.interval: % the interval at which plasticity, like depression or summation, start (sec or 1/Hz).
    end

    methods
        function obj = Synapse(parameters)
            % parameters must contain the following:
            % parameters.tau: time constant of the synaptic response (sec).
            % parameters.gain: amplitude of the synaptic response conductance (S).
            % parameters.delay: delay in response after input event (sec).
            % parameters.Erev: Synaptic reversal potential (mV).
            % parameters.plasticity: A nonlinear temporal process at the
            % synapse that integrates temporal inputs.
            % parameters.plasticity.tau: time constant factor that determines the strength of depression or summation over time (sec).
            % parameters.plasticity.type: type of depression or summation scaling (eg., quadratic or simple).
            % parameters.plasticity.interval: the interval at which plasticity, like depression or summation, start (sec or 1/Hz).
            obj.tau = parameters.tau;
            obj.gain = parameters.gain;
            obj.delay = parameters.delay;
            obj.Erev = parameters.Erev;
            obj.plasticity = parameters.plasticity; % A struct that contains (tau, type & interval).
        end

        function output = propagate(obj, fs, sim_times, spikes)
            % Input is a batch vector consisting of 0s & 1s.
            [nbatches, ntimesteps] = size(spikes);

            % Output is the response of the neuron for nbatches of the
            % input(spikes) at every timepoint. This cannot be an object
            % property when we propagate inputs parallely through the
            % synapse using parfor loop.
            output = zeros(nbatches, ntimesteps);

            % We create a new variables that copy object properties so that
            % we do not handover object properties to the parfor loop, this
            % will object copy overhead.
            plsty = obj.plasticity;
            syn_tau = obj.tau;
            syn_gain = obj.gain;

            % Parallel for loop across all batches of input (spikes or
            % triggers)
            parfor z = 1: nbatches
                % Find the times where the input is 1 and not 0, find
                % function gives us indices, these are then coverted into
                % time points using sampling rate.
                spike_times = find(spikes(z, :))./fs;

                % If no spikes are present in the input(spikes) there is no
                % point in executing the rest of the loop, so we move on to
                % the next batch.
                if isempty(spike_times)
                    continue;
                end

                % Build a scaler array that multiplies the synaptic alpha
                % response for each spike.
                scaler = build_plastic_behavior(spike_times, plsty);

                % Construct an alpha function for each spike. We are using
                % matlabs matrix operations by feeding spike_times array.
                exponent = ((sim_times' > spike_times).*(sim_times' - spike_times)./syn_tau)';
                spike_reponses = exponent.*exp(1-exponent);

                % To compute the output, just matrix multiply scaler with
                % spike_responses that contains the responses for each
                % spike. This multiplies scaling factor on consequtive
                % spike responses depending on how close the input spikes
                % are and then, adds (or computes maxima) the responses
                % together. Matrix multiplication is a cross product, so
                % combining each spike response doesn't need to be done
                % manually.
%                 output(z, :) = syn_gain.*max(scaler'.*spike_reponses, [], 1);
                output(z, :) = syn_gain.*scaler*spike_reponses;
            end
        end
    end
end