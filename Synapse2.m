classdef Synapse2
   properties
       tau
       gain
       Erev
       delay
       dt_nonlin
       tau_nonlin
       conductance
       current
   end
   
   methods
       function obj = Synapse(tau, gain, Erev, delay, dt_nonlin, tau_nonlin)
           if nargin ~= 0
              [m, n] = size(tau);
              obj(m, n) = obj;
              for i = 1: m
                  for j = 1: n
                    obj(i, j).tau = tau(i, j);
                    obj(i, j).gain = gain(i, j);
                    obj(i, j).Erev = Erev(i, j);
                    obj(i, j).delay = delay(i, j);
                    obj(i, j).dt_nonlin = dt_nonlin(i, j);
                    obj(i, j).tau_nonlin = tau_nonlin(i, j);
                  end
              end
           end
       end
       
       function obj = compute_conductances(obj, spikes, times, fs)
           [m, n] = size(obj);
           spike_times = find(spikes, 1)./fs;
           if isempty(spike_times)
               for i = 1: m
                   for j = 1: n
                       obj(i, j).responses = spikes;
                   end
               end
           else
               for i = 1: m
                   for j = 1: n
                       response = zeros(size(spike_times, 2), size(spikes, 2));
                       a = obj(i, j).gain;
                       for t = 1: 1: size(spike_times, 2)
                           exponent = (times > spike_times(:, t)).*(times - spike_times(:, t))./obj(i, j).tau;
                           response(t, :) = a.*exponent.*exp(-1.*exponent + 1);
                           if t > 1
                               a = a + obj(i, j).tau_nonlin*((spike_times(:, t) - spike_times(:, t-1)) < obj(i, j).dt_nonlin)*a;
                           end
                       end
                       obj(i, j).conductance = temporalShift(max(response, [], 1), obj(i, j).delay, fs);
                   end
               end    
           end
       end
   end
end