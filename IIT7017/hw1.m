% Q4

% A = [-1 -1; 6.5 0];
% B = [1 1; 1 0];
% C = [1 0; 0 1];
% D = [0 0; 0 0];
% 
% sys = ss(A,B,C,D)
% 
% step(sys)

% Q5

C = [10 4];
R1 = [1 4 4];
sys1 = tf(C, R1)
subplot(1, 2, 1)
step(sys1)
title('Unit Step Response')

R2 = [1 4 4 0];
sys2 = tf(C, R2)
subplot(1, 2, 2)
step(sys2)
title('Unit Ramp Response')
