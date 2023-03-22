% Q1

A = [0 1 0; 0 0 1; -6 -11 -6];
B = [0; 0; 1];
p = [-2 + 2j * sqrt(3), -2 - 2j * sqrt(3), -10];
K = place(A, B, p)

% Q2

A = [0 1 0; 0 0 1; -6 -11 -6];
B = [0; 0; 1];
C = [1 0 0];
p = [-1 + 1j, -1 - 1j, -5];
K = place(A, B, p)

pe = [-6 + 0.001j, -6 - 0.001j, -6];
Ke = place(A', C', pe).'
Ke = [12; 25; -72];

syms s;
TF = simplify(K * inv(s * eye(3) - A + Ke * C + B * K) * Ke)

% Q3
A = [0 1; 0 -1];
B = [0;1];
C = [1 0];
p = [-2 + 2j, -2 - 2j];
K = place(A, B, p)

pe = [-8 + 0.0001j, -8 - 0.0001j];
Ke = place(A', C', pe).'
Ke = [15; 49];

syms s;
TF = simplify(K * inv(s * eye(2) - A + Ke * C + B * K) * Ke)

sys1 = tf([0 0 0 267 512], [1 20 136 384 512])
sys2 = tf([0 0 1 19 117] * 512/117, [1 20 136 384 512])
hold on
step(sys1)
step(sys2)

% Q4
A = [0 1; 0 -2];
B = [0;4];
C = [1 0];
p = [-2 + 2j * sqrt(3), -2 - 2j * sqrt(3)];
K = place(A, B, p)

pe1 = [-8 + 0.0001j, -8 - 0.0001j];
Ke1 = place(A', C', pe).'
Ke1 = [14; 36];

pe2 = [-8];
Ke2 = place(A(2, 2), A(1, 2), pe2)

syms s;
An = [A - B * K, B * K; [0,0;0,0], A - Ke1 * C];
sys1 = ss(An, eye(4), eye(4), eye(4))
x0 = [1; 0; 1; 0];
initial(sys1, x0)

An2 = [A - B * K, B * K(1, 1); 0, A(2, :) - Ke2 * C];
sys2 = ss(An2, eye(3), eye(3), eye(3))
x0 = [1; 0; 1];
initial(sys2, x0)