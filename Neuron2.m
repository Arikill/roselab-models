classdef Neuron2
   properties
       Cm
       Rin
       Er
       Eth
       Emax
       Tr
       Vm
       syne
       syni
   end
   
   methods
       function obj = Neuron2(props)
           if nargin ~= 0
              [m, n] = size(props.Cm);
              obj(m, n) = obj;
              for i = 1: m
                  for j = 1: n
                      obj(i, j).Cm = props.Cm(i, j);
                      obj(i, j).Rin = props.Rin(i, j);
                      obj(i, j).Er = props.Er(i, j);
                      obj(i, j).Eth = props.Eth(i, j);
                      obj(i, j).Emax = props.Emax(i, j);
                      obj(i, j).Tr = props.Tr(i, j);
                  end
              end
           end
       end
       
       function obj = call(obj, Iinj, syns, fs)
           [m, n] = size(obj);
           [ms, ~] = size(syns);
           nsyns_per_cell = floor(ms/m);
           for i = 1: m
               for j = 1: n
                   timesteps = size(syns(i+1, j+1).response, 2);
                   for t = 2: 1: timesteps
                       
                   end
               end
           end
       end
       
   end
   
end