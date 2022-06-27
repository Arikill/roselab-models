classdef Synapse
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        amp
        tau
    end

    methods
        function obj = Synapse(amp, tau)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.amp = amp;
            obj.tau = tau;
        end

        function response = call(obj, trigs, fs, min_integration_time, integration_tau, delay)
            trig_times = find(trigs)/fs;
            samples = size(trigs, 2);
            times = linspace(0, samples/fs, samples);
            response = zeros(1, size(trigs, 2));
            a = obj.amp;
            factor = mean(diff(trig_times));
            for t = 1: 1: size(trig_times, 2)
                exponent = (times > trig_times(t)).*(times - trig_times(t))./obj.tau;
                response = cat(1, response, a.*exponent.*exp(-1.*exponent + 1));
                a = a + integration_tau*(factor<min_integration_time)*a;
            end
            response = max(response, [], 1);
            response = temporalShift(response, delay, fs);
        end
    end
end