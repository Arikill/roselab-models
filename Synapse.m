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

        function response = call(obj, input_spikes, fs, max_integration_interval, integration_tau, delay)
            %call computes the output of the synapse when inputs
            %   (input_spikes) temporally arrive at the synapse.
            %   fs is the sampling rate at which the entire system or
            %   simulation is sampled. This sampling rate allows us to
            %   transform from temporal reality to simulation space i.e.,
            %   time to samples.
            %   max_integration_interval is the maximum interval between input_spikes
            %   required for temporal overlap proess like summation or
            %   depression to start shaping the response.
            %   integration_tau defines the timeconstant of temporal overlap
            %   processes (+ve for summation, -ve for depression and 0 for
            %   neither)
            %   delay is the response initiation delay of the synapse after
            %   the input spikes arrive.
            input_spike_times = find(input_spikes)/fs; % Array to hold the samples at which input spikes have occured; division by fs converts samples to times.
            samples = size(input_spikes, 2); % Total number of time samples needed. The input_spikes are of the shape [1, samples]
            times = linspace(0, samples/fs, samples); % An array of size [1, samples] of times starting from 0 to samples/fs i.e. end time.
            response = zeros(size(input_spike_times, 2), size(input_spikes, 2)); % An array (size of input_spikes or dim 2 or columns) to contain responses from each input_spike_time (dim 1 or rows).
            a = obj.amp; % Copy the amplitude of the synapse into a variable to implement integration processes.
            inter_spike_interval = mean(diff(input_spike_times)); % Differential, implemented internally as sample difference value(t) - values(t-1), provides the interval between spikes. Higher pulse rates = smaller interpulse interval for afferent.
            for t = 1: 1: size(input_spike_times, 2)
                exponent = (times > input_spike_times(t)).*(times - input_spike_times(t))./obj.tau; % At every input spike generate a synaptic response (using a vectorized computation formula).
                response(t, :) =  a.*exponent.*exp(-1.*exponent + 1); % Synaptic response at each input_spike_time is created individually (amplitude modified according to desired integration).
                a = a + integration_tau*(inter_spike_interval<max_integration_interval)*a; % Modify the amplitude of the next pulse using integration_tau only if the inter_spike_intervals are less than the max_integration_interval. 
            end
            response = max(response, [], 1); % Concatenating all responses from input spikes into a singular response. The responses are already modified to mimic depression or summation, picking the max value approximates the temporally integration at soma.
            response = temporalShift(response, delay, fs); % Delay the synaptic response by a desired amount.
        end
    end
end