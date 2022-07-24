classdef Synapse2
   properties
       tau
       gain
       Erev
       dt_nonlin
       tau_nonlin
   end
   
   methods
       function obj = Synapse(tau, gain, Erev, dt_nonlin, tau_nonlin)
           if nargin ~= 0
              [m, n] = size(tau);
              obj(m, n) = obj;
              for i = 1: m
                  for j = 1: n
                    obj(i, j).tau = tau(i, j);
                    obj(i, j).gain = gain(i, j);
                    obj(i, j).Erev = Erev(i, j);
                    obj(i, j).dt_nonlin = dt_nonlin(i, j);
                    obj(i, j).tau_nonlin = tau_nonlin(i, j);
                  end
              end
           end
       end
       
       function responses = call(obj, spikes, times, fs)
           spike_times = find(spikes, 1)./fs;
           if isempty(spike_times)
               response = inputs.spikes;
               return;
           end
           
           response = zeros(size(spike_times, 2), size(spikes, 2));
           a = obj.amp;
           for t = 1: 1: size(spike_times, 2)
               exponent = (times > spike_times(:, t)).*(times - spike_times(:, t))./obj.
           end
       end
   end
   
end