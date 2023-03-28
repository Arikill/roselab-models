classdef Neuron2
   properties
       fs
       Cm
       Rin
       Er
       Eth
       Emax
       Tr
       Vm
       syne
       syni
       trigs
       delay
   end
   
   methods
       function obj = Neuron2(fs, parameters)
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

       function obj = propagate(obj, times, input_spikes, Iinj)
            obj.syne = obj.syne.propagate(times, input_spikes, obj.fs);
            obj.syni = obj.syni.propagate(times, input_spikes, obj.fs);
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
                obj.trigs = cat(2, append_samples, obj.trigs(:, 1:end-delay_samples));
            elseif obj.delay < 0
                append_samples = append_samples + obj.Vm(:, end);
                obj.Vm = cat(2, obj.Vm(:, 1:end-delay_samples), append_samples);
                obj.trigs = cat(2, obj.trigs(:, 1:end-delay_samples), append_samples);
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