% A very rough graph of P_loss in terms of i_F, T, w

% variables
syms i_F T w
% constants
syms R_A R_F f K

phi = f * i_F;
V_A = R_A * T / (K * phi) + K * phi * w
i_A = V_A / R_A;
P_loss =  i_A ^ 2 * R_A + i_F ^ 2 * R_F

% Assuming all constants to 1
P_loss_c = subs(P_loss, {R_A, R_F, f, K}, {1, 1, 1, 1});

% P_loss in terms of i_F (T = 1, w = 1)
figure
P_loss_1 = subs(P_loss_c, {T, w}, {1, 1});
ezplot(P_loss_1);
title('P_{loss} in term of i_F')

% P_loss in terms of T (i_F = 1, w = 1)
figure
P_loss_2 = subs(P_loss_c, {i_F, w}, {1, 1});
ezplot(P_loss_2);
title('P_{loss} in term of T')

% P_loss in terms of w (i_F = 1, T = 1)
figure
P_loss_3 = subs(P_loss_c, {i_F, T}, {1, 1});
ezplot(P_loss_3);
title('P_{loss} in term of w')