% Constants
m = 692;
C_d = 0.2;
A_f = 2;
C_0 = 0.009;
C_1 = 1.75e-6;
rho = 1.16;
g = 9.81;

% Velocity profile
syms t;
V = 20 * log(0.282 * t + 1);

% F_tr = F_net - F_roll - F_AD
% F_net = m * dv/dt
F_net = m * diff(V);
F_roll = m * g * (C_0 + C_1 * V ^ 2);
F_AD = 0.5 * rho * C_d * A_f * V ^ 2;
F_tr = F_net + F_roll + F_AD;
% P_tr = F_tr * v(t)
P_tr = F_tr * V;

% Plot
fig1 = figure;
ezplot(F_tr, [0, 10], fig1);
fig2 = figure;
ezplot(P_tr, [0, 10], fig2);

% e_tr = integral 0 to 10 P_tr
e_tr = vpa(int(P_tr, [0, 10]))
% KE = 0/5 * m * v^2
v = matlabFunction(V);
KE = 0.5 * m * v(10) ^ 2
% ratio of e_tr / KE
ratio =  KE / e_tr
% Energy loss
loss = e_tr - KE
