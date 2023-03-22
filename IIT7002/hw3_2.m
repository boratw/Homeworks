syms n l
% Solve the equation
eqns = [10^n * 67.5 == l, 110^n * 8 == l];
[soln, soll] = solve(eqns, [n, l])
% Show the approximate value of each variable
valuen = vpa(soln)
valuel = vpa(soll)

% SE = E/M = E / 15
% E = Q * V  so SE = Q * 12 / 15
Q = 67.5 * 15 / 12

