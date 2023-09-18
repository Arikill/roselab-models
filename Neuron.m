classdef Neuron
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
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
        function obj = Neuron(parameters)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
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
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if size(espikes) ~= size(ispikes)
                error("excitatory and inhibitory input dimensions must agree.");
            end
            [nbatches, ntimesteps] = size(espikes);
            ge = obj.syne.propagate(fs, sim_times, espikes);
            gi = obj.syni.propagate(fs, sim_times, ispikes);
            Vm = ones(nbatches, ntimesteps).*obj.Er;
            Sr = floor(fs*obj.Tr);
            for t = 2: 1: ntimesteps
                Vm(:, t) = Vm(:, t-1) + (1/fs).*(1/obj.Cm).*...
                    (i_inj - (1/obj.Rin).*(Vm(:, t-1) - obj.Er) ...
                    - ge(:, t-1).*(Vm(:, t-1) - obj.syne.Erev) - gi(:, t-1).*(Vm(:, t-1) - obj.syni.Erev));
            end
        end
    end
end