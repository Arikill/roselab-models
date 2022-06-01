classdef Synapse
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        delay
        tau
        amp
        state
    end

    methods
        function obj = Synapse(tau, amp)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.tau = tau;
            obj.amp = amp;
            obj.state = 0.0;
        end

        function obj = call(obj, trigs, fs)
            trig_times = find(trigs);
            responses = zeros(size(trigs));
        end

        function obj = call(obj, t)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            [m, n] = size(obj);
            for i = 1: m
                for j = 1: n
                    exponent = (t > obj(i, j).delay).*(t - obj(i, j).delay)./obj(i, j).tau;
                    obj(i, j).state = obj(i, j).amp.*exponent.*exp(-1.*exponent + 1);
                end
            end
        end

        function response = get(obj, t, type, delayedBy, fs)
            [m, n] = size(obj);
            fprintf('%d, %d', m, n);
            for i = 1: m
                for j = 1: n
                    obj(i, j) = obj(i, j).call(t);
                end
            end
            response = 0;
            if strcmp(type, 'summation')
                for i = 1: m
                    for j = 1: n
                        response = response + obj(i, j).state;
                    end
                end
            end
            response = temporalShift(response, delayedBy, fs);
        end
    end
end