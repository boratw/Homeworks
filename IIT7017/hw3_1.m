% Q1

syms s
A = [-1 0 1;
    1 -2 0;
    0 0 -3];
B = [0; 0; 1];
C = [1 1 0];
si = [ s 0 0;
    0 s 0;
    0 0 s];
G = C * inv(si - A) * B
simplify(G)

% Q2
A = [0 1 0 0; 0 0 1 0; 0 0 0 1; 1 0 0 0];
eig(A)