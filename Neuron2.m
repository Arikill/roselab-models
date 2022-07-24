classdef Neuron2
   properties
       Cm
       Rin
       Er
       Ee
       Ei
       Eth
       Emax
       Tr
       synapses
   end
   
   methods
       function obj = Neuron2(props)
           obj.Cm = props.Cm;
           obj.Rin = props.Rin;
           obj.Er = props.Er;
           obj.Eth = props.Eth;
           obj.Emax = props.Emax;
           obj.Tr = props.Tr;
           for i = 1: 1: length(props.synapses)
              obj.synapses{i} = Synapse(props.synapses{i}.amp, props.synapses{i}.tau); 
           end
       end
       
       function [response, trigs] = call(obj, Iinj, fs)
       end
       
   end
   
end