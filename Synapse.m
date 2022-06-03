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

        function response = call(obj, trigs, fs, integration_type, delay)
            trig_times = find(trigs)/fs;
            samples = size(trigs, 2);
            times = linspace(0, samples/fs, samples);
            response = zeros(1, size(trigs, 2));
            if strcmp(integration_type, 'summation')
                for t = 1: 1: size(trig_times, 2)
                    exponent = (times > trig_times(t)).*(times - trig_times(t))./obj.tau;
                    response = response + obj.amp.*exponent.*exp(-1.*exponent + 1);
                end
            elseif strcmp(integration_type, 'maxima')
                for t = 1: 1: size(trig_times, 2)
                    exponent = (times > trig_times(t)).*(times - trig_times(t))./obj.tau;
                    response = cat(1, response, obj.amp.*exponent.*exp(-1.*exponent + 1));
                end
                response = max(response, [], 1);
            elseif strcmp(integration_type, 'depression')
                a = obj.amp;
                for t = 1: 1: size(trig_times, 2)
                    exponent = (times > trig_times(t)).*(times - trig_times(t))./obj.tau;
                    response = response + a.*exponent.*exp(-1.*exponent + 1);
                    a = a - 0.05*a;
                end
            end
            response = temporalShift(response, delay, fs);
        end
    end
end