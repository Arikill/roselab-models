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
                    disp(trig_times(t));
                    exponent = (times > trig_times(t)).*(times - trig_times(t))./obj.tau;
                    response = response + obj.amp.*exponent.*exp(-1.*exponent + 1);
                end
            elseif strcmp(integration_type, 'maxima')
                for t = 1: 1: size(trig_times, 2)
                    disp(trig_times(t));
                    exponent = (times > trig_times(t)).*(times - trig_times(t))./obj.tau;
                    response = cat(1, response, exponent.*exp(-1.*exponent + 1));
                end
                disp(size(response));
                response = obj.amp.*max(response, [], 1);
            end
            response = temporalShift(response, delay, fs);
        end

%         function obj = call(obj, t)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             [m, n] = size(obj);
%             for i = 1: m
%                 for j = 1: n
%                     exponent = (t > obj(i, j).delay).*(t - obj(i, j).delay)./obj(i, j).tau;
%                     obj(i, j).state = obj(i, j).amp.*exponent.*exp(-1.*exponent + 1);
%                 end
%             end
%         end
% 
%         function response = get(obj, t, type, delayedBy, fs)
%             [m, n] = size(obj);
%             fprintf('%d, %d', m, n);
%             for i = 1: m
%                 for j = 1: n
%                     obj(i, j) = obj(i, j).call(t);
%                 end
%             end
%             response = 0;
%             if strcmp(type, 'summation')
%                 for i = 1: m
%                     for j = 1: n
%                         response = response + obj(i, j).state;
%                     end
%                 end
%             end
%             response = temporalShift(response, delayedBy, fs);
%         end
    end
end