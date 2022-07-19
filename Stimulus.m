classdef Stimulus
    %Stimulus Summary of this class goes here
    %   Detailed explanation goes here

    properties
        fs % Sampling frequency
        carrierFreq
        pulseRate
        npulses
        pulseOnTime
        riseTime
        envelope
    end

    methods
        function obj = Stimulus(fs, carrierFreq, envelope, pulseOnTime, riseTime)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.fs = fs;
            obj.carrierFreq = carrierFreq;
            obj.envelope = envelope;
            obj.pulseOnTime = pulseOnTime;
            obj.riseTime = riseTime;
        end

        function pulse = generatePulse(obj, pulseDuration, onTime, riseTime)
            times = 0: (1/obj.fs): pulseDuration-(1/obj.fs);
            carrier = sin(2*pi*obj.carrierFreq.*times);
            offTime = pulseDuration - onTime;
            if strcmp(obj.envelope, 'triangular')
                rise_times = 0: (1/obj.fs): riseTime-(1/obj.fs);
                rise_pulse = rise_times.*(1/riseTime);
                fall_times = riseTime: (1/obj.fs): onTime-(1/obj.fs);
                fall_pulse = ((-1/(onTime-riseTime)).*(fall_times-riseTime)) + 1;
                onPulse = cat(2, rise_pulse, fall_pulse);
                offPulse = zeros(size(onPulse, 1), floor(offTime*obj.fs));
                modulator = cat(2, onPulse, offPulse);
            end
            if size(carrier, 2) > size(modulator, 2)
                modulator = cat(2, modulator, zeros(size(modulator, 1), size(carrier, 2)-size(modulator, 2)));
            elseif size(carrier, 2) < size(modulator, 2)
                modulator = modulator(:, 1:size(carrier, 2));
            end
            pulse = carrier.*modulator;
        end
        
        function [stim, times, trigs] = generateStimulusAtSamples(obj, pulse_trig_samples, fs_in)
            obj.npulses = size(pulse_trig_samples, 2); % Compute the number of pulses from the input trigger samples.
            pulse_trig_times = pulse_trig_samples./fs_in; % Compute the trigger times from the sampling rate.
            pulseDurations = diff(pulse_trig_times);
            maxDuration = max(pulseDurations, [], 2);
            for i = 1: 1: size(pulseDurations, 2)
                if obj.pulseOnTime > pulseDurations(1, i)
                    obj.pulseOnTime = pulseDurations(1, i);
                end
            end
            stim_array = cell(obj.npulses, 1);
            trigs_array = cell(obj.npulses, 1);
            for i = 1: 1: obj.npulses-1
               stim_array{i, 1} = obj.generatePulse(pulseDurations(1, i), obj.pulseOnTime, obj.riseTime);
               trigs_array{i, 1} = stim_array{i, 1}.*0;
               trigs_array{i, 1}(1, 1) = 1;
            end
            stim_array{obj.npulses, 1} = obj.generatePulse(pulseDurations(1, i-1), obj.pulseOnTime, obj.riseTime);
            trigs_array{obj.npulses, 1} = stim_array{obj.npulses, 1}.*0;
            trigs_array{obj.npulses, 1}(1, 1) = 1;
            stim = [];
            trigs = [];
            for i = 1: 1: obj.npulses
               stim = cat(2, stim, stim_array{i, 1});
               trigs = cat(2, trigs, trigs_array{i, 1});
            end
            stim = cat(2, stim, zeros(size(stim, 1), floor(maxDuration*obj.fs)));
            trigs = cat(2, trigs, zeros(size(trigs, 1), floor(maxDuration*obj.fs)));
            times = (0: size(stim, 2)-1)/obj.fs;
        end

        function [stim, times, trigs] = generateStimulus(obj, stimDuration, pulseRate, npulses)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.pulseRate = pulseRate;
            obj.npulses = npulses;
            pulseDuration = 1/obj.pulseRate;
            if obj.pulseOnTime > pulseDuration
                obj.pulseOnTime = pulseDuration;
            end
            pulses = ones(obj.npulses, 1);
            pulse = obj.generatePulse(pulseDuration, obj.pulseOnTime, obj.riseTime);
            pulses = pulses*pulse;
            pulse_trigs = zeros(size(pulses));
            pulse_trigs(:, 1) = 1.0;
            stim = reshape(pulses', [], 1)';
            trigs = reshape(pulse_trigs', [], 1)';
            stimOnTime = (size(stim, 2)/obj.fs);
            stimOffTime = stimDuration - stimOnTime;
            if stimOffTime > 0
                append_samples = floor(stimOffTime*obj.fs);
                stim = cat(2, stim, zeros(1, append_samples));
                trigs = cat(2, trigs, zeros(1, append_samples));
            end
            times = 0: (1/obj.fs): stimDuration-(1/obj.fs);
        end
    end
end