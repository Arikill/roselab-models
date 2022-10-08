clear; clc;
syms times td tau gain;
exps = (times-td)/tau;
alpha = gain*exps*exp(-1*((times-td)/tau) + 1);
dalpha_by_dt = diff(alpha, times);
disp(dalpha_by_dt);
disp(dalpha_by_dt);
d2alpha_by_dt2 = diff(dalpha_by_dt, times);
disp(d2alpha_by_dt2);