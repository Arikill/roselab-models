classdef Synapse2
   properties(Access=public)
       tau
       gain
       Erev
       delay
       dt_nonlin
       tau_nonlin
   end
   
   methods(Access=public)
       function obj = Synapse(tau, gain, Erev, delay, dt_nonlin, tau_nonlin)
           obj.tau = tau;
           obj.gain = gain;
           obj.Erev = Erev;
           obj.delay = delay;
           obj.dt_nonlin = dt_nonlin;
           obj.tau_nonlin = tau_nonlin;
       end
       
       function obj = compute_conductances(obj, input_spikes, times, fs)
           input_spike_times = find(spikes)/fs;
           
       end
   end
end