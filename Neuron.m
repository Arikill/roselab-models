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
        Emax
        Tr
    end

    methods
        function obj = Neuron(Cm, Rin, Er, Ee, Ei, Eth, Emax, Tr)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Cm = Cm;
            obj.Rin = Rin;
            obj.Er = Er;
            obj.Ee = Ee;
            obj.Ei = Ei;
            obj.Eth = Eth;
            obj.Emax = Emax;
            obj.Tr = Tr;
        end

        function [response, trigs] = call(obj, Iinj, ge, gi, fs)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            response = zeros(size(ge))+obj.Er;
            for i = 2: 1: size(ge, 2)
                response(:, i) = response(:, i-1) + (1/fs)*(1/obj.Cm)*(Iinj - (1/obj.Rin)*(response(:, i-1) - obj.Er) - ge(:, i)*(response(:, i-1)-obj.Ee) - gi(:, i)*(response(:, i-1) - obj.Ei));
            end
            spikeIndicies = response > obj.Eth;
            spkSamples = floor(obj.Tr*fs);
            index = find(spikeIndicies, 1, 'first');
            count = 1;
            while index
                response(:, index) = obj.Emax;
                count = count + 1;
%                 if count > 20
%                     break;
%                 end
                eSamples = index+spkSamples;
                if eSamples < size(response, 2)
                    spikeIndicies(:, index:index+spkSamples) = 0;
                end
                index = find(spikeIndicies, 1, 'first');
            end
            trigs = (response >= obj.Emax);
        end
    end
end