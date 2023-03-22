% steady-state discharge rate = C/2
% then, the current at steady-state = 80 / 2 = 40 A
% Now we can find that R = 12 / 40 = 0.3 ¥Ø
L = 90 / 1000;
R = 12 / 40;
V = 12;

syms I(t)  t;
dI(t) = diff(I(t), t);
% L * di/dt + R * i(t) = V(t) = 12
eqn = L * dI(t) + R * I(t) == 12;
% Initial condition (The current is zero at start)
cond = I(0) == 0;
% Solve differential equation
I = dsolve(eqn, cond)

% Plot
fig1 = figure;
ezplot(I, [0, 2], fig1);


% SOD(t) = Integral 0 to t {I(t) dt}
SOD(t) = int(I, t)

% Plot
fig2 = figure;
ezplot(SOD, [0, 2], fig2);

% SOC(t) = Q_T - SOD(t) = 80 - SOD(t);
SOC(t) = 80 - SOD(t)

% Plot
fig2 = figure;
ezplot(SOC, [0, 2], fig2);

% DoD = (Q_T - SOC(t)) / Q_T * 100 = (80-SOC(t)) / 80 * 100
DoD(t) = (80 - SOD(t)) / 80 * 100
eqn = DoD(t) == 80;
ans = vpa(solve(eqn, t))