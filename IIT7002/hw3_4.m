% Before Solving the problem, There is unknown number (only shows 
% its ten's digit is 4) following 42 in both figures.
% I assume that it is 45.
% Also, The velocity at t=42 is missing, too
% I assume that it is 20


% Constants
m = 700;
Mb = 150;
C_D = 0.2;
A_F = 2;
rho = 1.16;
g = 9.81;
C_0 = 0.009;

% F_TR(t) + F_AD(t) + F_roll = m * d v(t) / dt       % (F = ma)
% F_AD(t) = - 0.5 * rho * C_D * A_F * v(t)^2
% F_roll(t) = - m * g * C_0

syms t V dV
F_AD(t) = 0.5 * rho * C_D * A_F * V ^ 2;
F_TR(t) = m * dV + F_AD(t) + m * g * C_0


% Plot
fig1 = figure;
hold on
% 0 <= t < 19
v(t) = 32/19 * t * (1000/3600);
F_TR_1(t) = subs(F_TR, {V, dV}, {v, diff(v, t)});
ezplot(F_TR_1, [0, 19], fig1);
% 19 <= t < 38
v(t) = 32 * (1000/3600);
F_TR_2(t) = subs(F_TR, {V, dV}, {v, diff(v, t)});
ezplot(F_TR_2, [19, 38], fig1);
% 38 <= t < 42
v(t) = ((32 + 3 * 38) - 3 * t) * (1000/3600);
F_TR_3(t) = subs(F_TR, {V, dV}, {v, diff(v, t)});
ezplot(F_TR_3, [38, 42], fig1);
% 42 <= t < 45
v(t) = ((20 + (20 / 3) * 42) - (20 / 3) * t) * (1000/3600);
F_TR_4(t) = subs(F_TR, {V, dV}, {v, diff(v, t)});
ezplot(F_TR_4, [42, 45], fig1);
title('F_{TR}(t)')
axis auto

%P_TR = F_TR * v
P_TR(t) = F_TR(t) * V;
% Plot
fig2 = figure;
hold on
% 0 <= t < 19
v(t) = 32/19 * t * (1000/3600);
P_TR_1(t) = subs(P_TR, {V, dV}, {v, diff(v, t)});
ezplot(P_TR_1, [0, 19], fig2);
% 19 <= t < 38
v(t) = 32 * (1000/3600);
P_TR_2(t) = subs(P_TR, {V, dV}, {v, diff(v, t)});
ezplot(P_TR_2, [19, 38], fig2);
% 38 <= t < 42
v(t) = ((32 + 3 * 38) - 3 * t) * (1000/3600);
P_TR_3(t) = subs(P_TR, {V, dV}, {v, diff(v, t)});
ezplot(P_TR_3, [38, 42], fig2);
% 42 <= t < 45
v(t) = ((20 + (20 / 3) * 42) - (20 / 3) * t) * (1000/3600);
P_TR_4(t) = subs(P_TR, {V, dV}, {v, diff(v, t)});
ezplot(P_TR_4, [42, 45], fig2);
title('P_{TR}(t)')
axis auto

%f_cycle = integral of I^n / lambda
syms I
I1 = (100 / 19 * I) ^ 0.9 / 216E4;
I2 = (35 + 0 * I) ^ 0.9 / 216E4; % dummy zero for assume this as symbolic function
f_cycle = vpa(int(I1, [0, 19]) + int(I2, [19, 38]));
% # of cycle required for 100% DoD
N = 1 / f_cycle

% How much EV goes at 1 cycle : integral of v(t)
lengthsum = 0;
% 0 <= t < 19
v(t) = 32/19 * t * (1000/3600);
lengthsum = lengthsum + vpa(int(v, [0, 19]));
% 19 <= t < 38
v(t) = 32 * (1000/3600) + 0 * t; % dummy zero for assume this as symbolic function
lengthsum = lengthsum + vpa(int(v, [19, 38]));
% 38 <= t < 42
v(t) = ((32 + 3 * 38) - 3 * t) * (1000/3600);
lengthsum = lengthsum + vpa(int(v, [38, 42]));
% 42 <= t < 45
v(t) = ((20 + (20 / 3) * 42) - (20 / 3) * t) * (1000/3600);
lengthsum = lengthsum + vpa(int(v, [42, 45]));
lengthsum

% EV range = N * (length at 1 cycle)
lm = N * lengthsum  % Meter
lmi = lm / 1609.344 % Mile