classdef Neuron
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Cm
        Rin
        Er
        Ee
        Ei
        Eth
        exeSynapse
        inhSynapse
    end

    methods
        function obj = Neuron(Cm, Rin, Er, Ee, Ei, Eth)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Cm = Cm;
            obj.Rin = Rin;
            obj.Er = Er;
            obj.Ee = Ee;
            obj.Ei = Ei;
            obj.Eth = Eth;
        end

        function obj = setExeSynapse(synapse)
            obj.exeSynapse = synapse;
        end

        function obj = setInhSynapse(synapse)
            obj.inhSynapse = synapse;
        end

        function outputArg = call(obj, trigs, ge, gi)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            trigTimes = find(trigs);
            obj.exeSynapse
            
        end
    end
end