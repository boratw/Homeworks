% Q3
syms s
invmat = inv( [ s, -1; 2, s+3 ] )
ans = ilaplace(invmat)

% Q4
A = [ 0 1 0; 0 0 1; -6 -11 -6 ];
B = [ 0; 0; 1 ];
C = [ 20 9 1 ];

U = [ B, A*B, A^2*B ]
V = [ C; C*A; C*A^2 ]

rank_U = rank(U)
rank_V = rank(V)

% Q5
A = [-1 0 1; 1 -2 0; 0 0 -3];
B = [0; 0; 1];
C = [1 1 0];
D = [0];
[num, den] = ss2tf(A, B, C, D)

% Q6
syms s k1 k2 k3;
A = [ s, -1, 0;
    k1, s+k2, k3-1;
    k1+1, k2+5, s+k3+6]
B = det(A)

[0 1 1; 1 7 -5; 7 0 -1]\[8;55;199]

% Q7
A = [ 0 1 0; 0 0 1; -1 -5 -6];
B = [ 0; 1; 1];
p = [ -2+4j, -2-4j, -10];
K = place(A, B, p)