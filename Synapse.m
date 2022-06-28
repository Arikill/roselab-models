classdef Synapse
    %Synapse -> Mathematically formulated as an alpha function.
    %   Formulating the synapse as an alpha functions has several
    %   advantages: 1) It is close to the synaptic input timecourses as
    %   seen by the soma of a neuron. 2) Only 3 parameters control the
    %   timecourse of alpha function, a) amplitude (amp) or gain, b)
    %   delay(td) or response start and c) timeconstant (tau) of the
    %   response.
    %   The alpha function is defined as follows:
    %   If t > td:
    %   alpha(t) = amp*((t - td)/tau)*exp(-1*((t - td)/tau) + 1)
    %   else if t < td:
    %   alpha(t) = 0
    %   The function defined as above has its peak at (td + tau)

    properties
        amp % amplitude (S)
        tau % timeconstant (secs)
    end

    methods
        function obj = Synapse(amp, tau)
            %Synapse Constructor accepts two parameters as input:
            %   amplitude (amp) and timeconstant (tau)
            %   This function or method creates an object called synapse
            %   defined by its amplitude and timeconstant.
            obj.amp = amp;
            obj.tau = tau;
        end

        function response = call(obj, input_spikes, fs, min_integration_time, integration_tau, delay)
            %call computes the output of the synapse when inputs
            %(input_spikes) temporally arrive at the synapse.
            % fs is the sampling rate at which the entire system or
            % simulation is sampled. This sampling rate allows us to
            % transform from temporal reality to simulation space i.e.,
            % time to samples.
            % min_integration_time is the minimum time between input_spikes
            % at which to temporal overlap proess like summation or
            % depression start to shape the response.
            % integration_tau defines the timeconstant of temporal overlap
            % processes (+ve for summation, -ve for depression and 0 for
            % neither)
            input_spike_times = find(input_spikes)/fs;
            samples = size(trigs, 2);
            times = linspace(0, samples/fs, samples);
            response = zeros(1, size(trigs, 2));
            a = obj.amp;
            factor = mean(diff(input_spike_times));
            for t = 1: 1: size(input_spike_times, 2)
                exponent = (times > input_spike_times(t)).*(times - input_spike_times(t))./obj.tau;
                response = cat(1, response, a.*exponent.*exp(-1.*exponent + 1));
                a = a + integration_tau*(factor<min_integration_time)*a;
            end
            response = max(response, [], 1);
            response = temporalShift(response, delay, fs);
        end
    end
end