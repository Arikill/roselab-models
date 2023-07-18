classdef Synapse2
   properties(Access=public)
       tau % time constant of the synaptic response (sec).
       gain % amplitude of the synaptic response conductance (S).
       delay % delay in response after pre-synaptic neuron spikes (sec).
       Erev % Synaptic reversal potential (mV).
       integration_tau % time constant factor that determines the strength of depression or summation over time (sec).
       integration_type % type of depression or summation scaling (eg., quadratic or linear).
       max_integration_interval % the interval required for the integrative effects, like depression or summation, to start (sec or 1/Hz).
       g % synaptic response across time after receiving an input (S).
   end
   
   methods(Access=public)
       function obj = Synapse2(parameters)
           % parameters is a struct that contains tau, gain, delay, Erev,
           % integration_tau and max_integration_interval.
           obj.tau = parameters.tau;
           obj.gain = parameters.gain;
           obj.delay = parameters.delay;
           obj.Erev = parameters.Erev;
           obj.integration_tau = parameters.integration_tau;
           obj.integration_type = parameters.integration_type;
           obj.max_integration_interval = parameters.max_integration_interval;
       end
       
       function obj = propagate(obj, times, input_spikes, fs)
            % times: times array of simulation of the network.
            % input_spikes: a train of 0 & 1s the length of times array.
            % spikes are indicated with 1 and no spike with 0.
            % fs: sampling rate of simulation.

            % compute the spike times from the input_spikes array.
            input_spike_times = find(input_spikes)/fs;

            % if no spikes are present, then no propagation is required.
            % return an array of zeros.
            if isempty(input_spike_times)
                obj.g = input_spikes*0;
                return;
            end
            
            nspikes = size(input_spike_times, 2);
            ntimesteps = size(times, 2);
            scaler = obj.getScaler(input_spike_times);
            obj.g = times*0.0;
            
            % modulation_factor attenuates or amplifies the response to the
            % next pulse depending on integration_tau.
            modulation_factor = obj.gain;
            inter_spike_interval = mean(diff(input_spike_times));
            response_to_each_spike = zeros(nspikes,ntimesteps);
            
            % implement an alpha function on each spike input. And modulate
            % modulate the next input using modulation_factor.
            for t = 1: 1: nspikes
                exponent = (times > input_spike_times(t)).*(times - input_spike_times(t))./obj.tau;
                response_to_each_spike(t, :) =  modulation_factor.*exponent.*exp(-1.*exponent + 1);
                modulation_factor = modulation_factor + scaler(t)*(inter_spike_interval < obj.max_integration_interval)*modulation_factor;
            end
            % integrate all the inputs together.
            obj.g = max(response_to_each_spike, [], 1);
            % add temporal delay to the response.
            obj = obj.delayResponse(fs);
       end

       function scaler = getScaler(obj, input_spike_times)
           if strcmp(obj.integration_type, "quadratic")
               scaler = input_spike_times.^2;
               scaler = (scaler - min(scaler))./(max(scaler) - min(scaler));
               scaler = scaler + obj.integration_tau;
           elseif strcmp(obj.integration_type, "linear")
               scaler = zeros(size(input_spike_times));
               scaler = scaler + obj.integration_tau;
           elseif strcmp(obj.integration_type, "exponential")
               scaler = 1-exp(-obj.integration_tau.*input_spike_times);
           end
       end

       function obj = delayResponse(obj, fs)
            delay_samples = floor(abs(obj.delay)*fs);
            append_samples = zeros(size(obj.g, 1), delay_samples);
            if obj.delay > 0
                append_samples = append_samples + obj.g(:, 1);
                obj.g = cat(2, append_samples, obj.g(:, 1:end-delay_samples));
            elseif obj.delay < 0
                append_samples = append_samples + obj.g(:, end);
                obj.g = cat(2, obj.g(:, 1:end-delay_samples), append_samples);
            end
       end

       function train_vars = getVars(obj)
            % function to obtain trainable variables.
            train_vars = {};
            train_vars.gain = obj.gain;
            train_vars.tau = obj.tau;
            train_vars.integration_tau = obj.integration_tau;
       end

       function obj = putVars(obj, vars)
            % function to put back the trainable variables.
            obj.gain = vars.gain;
            obj.tau = vars.tau;
            obj.integration_tau = vars.integration_tau;
       end
   end
end