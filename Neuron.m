classdef Neuron
    %Neuron -> Mathematically formulated as an RC circuit.
    %   A single compartmental model (SCM) represents the neuron as a single
    %   compartment or RC circuit with the excitatory and inhibitory
    %   conductances as synaptic inputs.
    %   Mathematically it is represented as follows:
    %   Cm*(dVm/dt) = Iinj - ge*(Vm - Ee) - gi*(Vm - Ei) - (1/Rin)*(Vm - Er)
    %   Cm : Membrane capacitance (F)
    %   Vm : Trans-membrane potential (V)
    %   t : time (sec)
    %   ge : Excitatory synpatic conductance (Response from an excitatory
    %   Synapse, see Synapse.m) (S)
    %   Ee : Excitatory reversal potential (V). The potential at which the
    %   excitatory current from the excitatory synapse is reversed.
    %   gi : Inhibitory synaptic conductance (Response from an inhibitory
    %   Synapse, see Synapse.m) (S)
    %   Ei : Inhibitory reversal potential (V). The potential at which the
    %   inhibitory current from the inhibitory synapse is reversed.
    %   Rin : Input resistance of the neuron. (1/Rin) = gleak is the
    %   leakage conductance (constant, S)
    %   
    %   The mathematical representation can be further expanded using
    %   truncated Taylor series expansion in temporal domain:
    %   dVm/dt = (Vm[t] - Vm[t-dt])/(t - t-dt))
    %   here dt = (1/fs) where fs is the sampling rate of the simulation or
    %   data acquisition system (in CED 1401 fs is 10kHz <=> dt is 0.0001).
    %   
    %   Expanding the single compartmental model will lead to the
    %   difference equation:
    %   Vm[t] = Vm[t - dt] + dt*(1/Cm)*(Iinj[t-dt] - ge[t-dt]*(Vm[t-dt] -
    %   Ee) - gi[t - dt]*(Vm[t - dt] - Ei) - (1/Rin)*(Vm[t-dt] - Er))
    %   This makes Vm causal i.e., dependent on previous (temporal) values of Vm and inputs.
    %   The above formulation sets up the system for explicit Euler
    %   updates.

    properties
        Cm
        Rin
        Er
        Ee
        Ei
        Eth % Neuronal Threshold.
        Emax % Maximum value of Vm or the max height of generate spikes.
        Tr % Refractory period, the minimum time between spikes.
    end

    methods
        function obj = Neuron(Cm, Rin, Er, Ee, Ei, Eth, Emax, Tr)
            %Neuron Constructor accepts neural properties listed in
            %   classdef.
            %   Tr is the refractory time (sec) and controls the number of
            %   spikes that could occur if Vm exceeds Eth
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
            %call computes the output of the neuron.
            %   Iinj is injected current via an electrode during the
            %   whole-cell recording to depolarize or hyperpolarize the
            %   neuron.
            %   ge is the output (changes in conductance) of the excitatory synapse.
            %   gi is the output (changes in conductance) of the inhibitory synapse.
            %   fs is the sampling rate for simulation and is the same rate
            %   used for computing the outputs of both excitatory and
            %   inhibitory neurons.
            response = zeros(size(ge))+obj.Er; % Response or Vm, have the same samples as ge and gi.
            for i = 2: 1: size(ge, 2) % Iteration through time to compute Vm at each time point.
                response(:, i) = response(:, i-1) + (1/fs)*(1/obj.Cm)*(Iinj - (1/obj.Rin)*(response(:, i-1) - obj.Er) - ge(:, i-1)*(response(:, i-1)-obj.Ee) - gi(:, i-1)*(response(:, i-1) - obj.Ei)); % Explicit Euler update
            end
            spikeIndicies = response > obj.Eth; % Vectorized computation of where Vm crosses the spike threshold, Eth.
            refracSamples = floor(obj.Tr*fs); % Number of samples (refractory samples) before another spike can occur.
            index = find(spikeIndicies, 1, 'first'); % Find the first spike.
            while index
                response(:, index) = obj.Emax; % Generate spikes.
                eSamples = index+refracSamples; % From spike until refractory period is finished, zero all spike indicies.
                if eSamples < size(response, 2)
                    spikeIndicies(:, index:index+refracSamples) = 0;
                end
                index = find(spikeIndicies, 1, 'first'); % When refractory period is done, compute where the next spike occurs.
            end
            trigs = (response >= obj.Emax); % Set triggers when the response is set to Emax, these will serve as spike triggers that serve as input to the next neuron or layer.
        end
    end
end