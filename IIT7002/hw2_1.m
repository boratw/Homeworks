% Constants
m = 692;
C_d = 0.2;
A_f = 2;
C_0 = 0.009;
C_1 = 1.75e-6;
rho = 1.16;
g = 9.81;


% 2.3.(a).(i)
% -----------------------------
% Zero Rolling Resistance -> F_TR = F_gxT
% F_gxT = m*g*sin(beta)
beta = atan(0.15); % grade = 15%
F_gxT = m * g * sin(beta);
% answer
F_TR = F_gxT 


% 2.3.(a).(ii)
% -----------------------------
% Maximum force of F_roll = (+-) C_0 * m * g * cos(beta)
% For keeping from rolling, net F must be zero
% F_TR - F_roll - F_gxT = 0
% so F_TR = F_roll + F_gxT
% Minimum force of F_TR = m * g * sin(beta) - C_0 * m * g * cos(beta)
F_TR = m * g * sin(beta) - C_0 * m * g * cos(beta)


% 2.3.(b).(i)
% -----------------------------
beta = atan(-0.12); % grade = -12%
v = 0:0.1:80.5; % x parameter)
F_gxT =  m * g * sin(beta) ...% constant
    + 0 * v; % dummy zero for data size
F_AD = 0.5 * rho * C_d * A_f * v.^2;
F_roll = m * g * cos(beta) * (C_0 + C_1 * v.^2);
figure;
hold on;
plot(v, F_gxT, 'DisplayName', 'F_{gxT}');
plot(v, F_AD, 'DisplayName', 'F_{AD}');
plot(v, F_roll, 'DisplayName', 'F_{roll}');
hold off;

% 2.3.(b).(ii)
% -----------------------------
% For constant velocity, net F must be zero
F_TR = - F_roll - F_gxT - F_AD;
figure;
plot(v, F_TR, 'DisplayName', 'F_{TR}');
