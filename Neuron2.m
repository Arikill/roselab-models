classdef Neuron2
   properties
       fs % Sampling rate of the simulation (Hz).
       Cm % Membrane capacitance of the neuron (F).
       Rin % Input resistance of the neuron (ohms).
       Er % Resting potential of the neuron (V).
       Eth % Threshold potential of the neuron (V).
       Emax % Maximum value for Vm or maximum spike height (V).
       Tr % Refractory period (sec).
       Vm % Membrane potential of the neuron (V).
       syne % Excitatory synapse object.
       syni % Inhibitory synapse object.
       trigs % Triggers for spikes. (0 or 1).
       delay % Delay Vm and trigs (response of the neuron) (sec).
   end

   methods
       function obj = Neuron2(fs, parameters)
           % parameters: must contain fs, Cm, Rin, Er, Eth, Emax, Tr,
           % delay, syne, syni.
           obj.fs = fs;
           obj.Cm = parameters.Cm;
           obj.Rin = parameters.Rin;
           obj.Er = parameters.Er;
           obj.Eth = parameters.Eth;
           obj.Emax = parameters.Emax;
           obj.Tr = parameters.Tr;
           obj.delay = parameters.delay;
           obj.syne = Synapse2(parameters.syne);
           obj.syni = Synapse2(parameters.syni);
       end

       function obj = propagate(obj, times, excitatory_input_spikes, inhibitory_input_spikes, Iinj)
            % times: times array of simulation of the network.
            % input_spikes: a train of 0 & 1s the length of times array.
            % spikes are indicated with 1 and no spike with 0.
            % fs: sampling rate of simulation.
            if isempty(inhibitory_input_spikes)
                ge = zeros(size(excitatory_input_spikes));
                gi = zeros(size(excitatory_input_spikes));
                for i = 1: size(excitatory_input_spikes, 1)
                    obj.syne = obj.syne.propagate(times, excitatory_input_spikes(i, :), obj.fs);
                    ge(i, :) = obj.syne.g;
                end
                for i = 1: size(excitatory_input_spikes, 1)
                    obj.syni = obj.syni.propagate(times, excitatory_input_spikes(i, :), obj.fs);
                    gi(i, :) = obj.syni.g;
                end
            elseif isempty(excitatory_input_spikes)
                ge = zeros(size(inhibitory_input_spikes));
                gi = zeros(size(inhibitory_input_spikes));
                for i = 1: size(inhibitory_input_spikes, 1)
                    obj.syne = obj.syne.propagate(times, inhibitory_input_spikes(i, :), obj.fs);
                    ge(i, :) = obj.syne.g;
                end
                for i = 1: size(inhibitory_input_spikes, 1)
                    obj.syni = obj.syni.propagate(times, inhibitory_input_spikes(i, :), obj.fs);
                    gi(i, :) = obj.syni.g;
                end
            else
                ge = zeros(size(excitatory_input_spikes));
                gi = zeros(size(inhibitory_input_spikes));
                for i = 1: size(excitatory_input_spikes, 1)
                    obj.syne = obj.syne.propagate(times, excitatory_input_spikes(i, :), obj.fs);
                    ge(i, :) = obj.syne.g;
                end
                for i = 1: size(inhibitory_input_spikes, 1)
                    obj.syni = obj.syni.propagate(times, inhibitory_input_spikes(i, :), obj.fs);
                    gi(i, :) = obj.syni.g;
                end
            end
            obj.syne.g = max(ge, [], 1);
            obj.syni.g = max(gi, [], 1);            
            obj.Vm = times*0.0 + obj.Er;
            for i = 2: size(times, 2)
                obj.Vm(:, i) = obj.Vm(:, i-1) + (1/obj.fs)*(1/obj.Cm)*(Iinj - (1/obj.Rin)*(obj.Vm(:, i-1) - obj.Er) - obj.syne.g(:, i-1)*(obj.Vm(:, i-1)-obj.syne.Erev) - obj.syni.g(:, i-1)*(obj.Vm(:, i-1) - obj.syni.Erev));
            end
            obj = obj.generateSpikes();
       end

       function obj = generateSpikes(obj)
            refraction_samples = floor(obj.Tr*obj.fs);
            spike_indices = obj.Vm > obj.Eth;
            nindices = size(spike_indices, 2);
            next_index = find(spike_indices, 1, "first");
            while next_index
                obj.Vm(:, next_index) = obj.Emax;
                if next_index+refraction_samples > nindices
                    break;
                end
                spike_indices(:, next_index:next_index+refraction_samples) = 0;
                next_index = find(spike_indices, 1, "first");
            end
            obj.trigs = obj.Vm >= obj.Emax;
            obj = obj.delayResponse();
       end

       function obj = delayResponse(obj)
            delay_samples = floor(abs(obj.delay)*obj.fs);
            append_samples = zeros(size(obj.Vm, 1), delay_samples);
            if obj.delay > 0
                append_samples = append_samples + obj.Vm(:, 1);
                obj.Vm = cat(2, append_samples, obj.Vm(:, 1:end-delay_samples));
                obj.trigs = cat(2, append_samples*0, obj.trigs(:, 1:end-delay_samples));
            elseif obj.delay < 0
                append_samples = append_samples + obj.Vm(:, end);
                obj.Vm = cat(2, obj.Vm(:, 1:end-delay_samples), append_samples);
                obj.trigs = cat(2, obj.trigs(:, 1:end-delay_samples), append_samples*0);
            end
       end

       function obj = setTrigs(obj, trigs)
           obj.trigs = trigs;
           obj.Vm = trigs*0;
           obj = obj.delayResponse();
       end

       function train_vars = getVars(obj)
            train_vars = {};
            train_vars.syne = obj.syne.getVars();
            train_vars.syni = obj.syni.getVars();
       end

       function obj = obj.putVars(obj, vars)
            obj.syne = obj.syne.putVars(vars.syne);
            obj.syni = obj.syni.putVars(vars.syni);
       end

   end
end