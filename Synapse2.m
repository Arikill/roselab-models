classdef Synapse2
   properties(Access=public)
       tau
       gain
       delay
       Erev
       integration_tau
       max_integration_interval
       g
   end
   
   methods(Access=public)
       function obj = Synapse2(parameters)
           obj.tau = parameters.tau;
           obj.gain = parameters.gain;
           obj.delay = parameters.delay;
           obj.Erev = parameters.Erev;
           obj.integration_tau = parameters.integration_tau;
           obj.max_integration_interval = parameters.max_integration_interval;
       end
       
       function obj = propagate(obj, times, input_spikes, fs)
            input_spike_times = find(input_spikes)/fs;
            if isempty(input_spike_times)
                obj.g = input_spikes;
                return;
            end
            nspikes = size(input_spike_times);
            ntimesteps = size(times);
            obj.g = times*0.0;
            modulation_factor = obj.gain;
            inter_spike_interval = mean(diff(input_spike_times));
            response_to_each_spike = zeros(nspikes(2),ntimesteps(2));
            for t = 1: 1: size(input_spike_times, 2)
                exponent = (times > input_spike_times(t)).*(times - input_spike_times(t))./obj.tau;
                response_to_each_spike(t, :) =  modulation_factor.*exponent.*exp(-1.*exponent + 1);
                modulation_factor = modulation_factor + obj.integration_tau*(inter_spike_interval < obj.max_integration_interval)*modulation_factor;
            end
            obj.g = max(response_to_each_spike, [], 1);
            obj = obj.delayResponse(fs);
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
            train_vars = {};
            train_vars.gain = obj.gain;
            train_vars.tau = obj.tau;
            train_vars.integration_tau = obj.integration_tau;
       end

       function obj = putVars(obj, vars)
            obj.gain = vars.gain;
            obj.tau = vars.tau;
            obj.integration_tau = vars.integration_tau;
       end
   end
end