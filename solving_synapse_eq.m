clear; clc;
syms time td tau gmax;
exps = (time-td)/tau;
alpha = gmax*exps*exp(-1*((time-td)/tau) + 1);
dalpha_by_dt = diff(alpha, time);
disp(dalpha_by_dt);
d2alpha_by_dt2 = diff(dalpha_by_dt, time);
disp(d2alpha_by_dt2);