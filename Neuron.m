classdef Neuron
    properties
       Cm % Membrane capacitance of the neuron (F).
       Rin % Input resistance of the neuron (ohms).
       Er % Resting potential of the neuron (V).
       Eth % Threshold potential of the neuron (V).
       Emax % Maximum value for Vm or maximum spike height (V).
       Tr % Refractory period (sec).
       syne % Excitatory synapse object.
       syni % Inhibitory synapse object.
    end

    methods
        function obj = Neuron(parameters)
            % parameters argument should contain the following:
            % parameters.Cm: Membrane capacitance of the neuron (F).
            % parameters.Rin: Input resistance of the neuron (ohms).
            % parameters.Er: Resting potential of the neuron (V).
            % parameters.Eth: Threshold potential of the neuron (V).
            % parameters.Emax: Maximum value for Vm or maximum spike height (V).
            % parameters.Tr: Refractory period, the period after a spike when no additional spikes can occur(sec).
            % parameters.syne: Excitatory synapse parameters. (Refer to
            % Synapse.m)
            % parameters.syni: Inhibitory synapse parameters. (Refer to
            % Synapse.m)
            obj.Cm = parameters.Cm;
            obj.Rin = parameters.Rin;
            obj.Er = parameters.Er;
            obj.Eth = parameters.Eth;
            obj.Emax = parameters.Emax;
            obj.Tr = parameters.Tr;
            obj.syne = Synapse(parameters.syne);
            obj.syni = Synapse(parameters.syni);
        end

        function [Vm, spikes, ge, gi] = propagate(obj, fs, sim_times, espikes, ispikes, i_inj)
            % fs: Sampling rate of simulation (Hz).
            % sim_times: array of times in the simulation (sec).
            % espikes: inputs to the excitatory synanapse.
            if size(espikes) ~= size(ispikes)
                error("excitatory and inhibitory input dimensions must agree.");
            end
            [nbatches, ntimesteps] = size(espikes);

            % Propagate the excitatory & inhibitory inputs through the
            % excitatory & inhibitory synapses, respectively. The resulting
            % synaptic responses are stored in ge & gi.
            ge = obj.syne.propagate(fs, sim_times, espikes);
            gi = obj.syni.propagate(fs, sim_times, ispikes);

            % Build an array to store membrane potential changes across
            % simulation time. Set the first timestep to resting potential
            % to ensure all changes start from rest.
            Vm = ones(nbatches, ntimesteps).*obj.Er;

            % Compute the refractory samples (Sr). After an event (spike)
            % occurs, the next Sr samples are set to zero.
            Sr = floor(fs*obj.Tr);

            % Track refraction across all batches of input.
            refract = zeros(nbatches, 1); % Refractory counter for each batch
    
            % Build an array to store spike responses when membrane
            % potential (Vm) crosses the threshold.
            spikes = false(nbatches, ntimesteps); % Initialize spikes as logical array
        
            % Update Vm at every timestep.
            % Using Explicit Euler, therefore sampling rate (fs) matter. Higher
            % the sampling rate, the more accurate the result.
            for t = 2:1:ntimesteps
                Vm(:, t) = Vm(:, t-1) + (1/fs).*(1/obj.Cm).*...
                    (i_inj - (1/obj.Rin).*(Vm(:, t-1) - obj.Er) ...
                    - ge(:, t-1).*(Vm(:, t-1) - obj.syne.Erev) - gi(:, t-1).*(Vm(:, t-1) - obj.syni.Erev));
                
                spike_idx = (Vm(:, t) > obj.Eth) & (refract == 0); % Spikes where refractory counter is 0
                spikes(spike_idx, t) = true; % Update spikes
                
                refract(spike_idx) = Sr; % Set refractory counter for batches that spiked
                refract(refract > 0) = refract(refract > 0) - 1; % Decrement refractory counter for non-zero batches
            end

        end
    end
end