syms t td tau gmax;
exps = (t-td)/tau;
alpha = gmax*exps*exp(-1*exps + 1);