%Constants
m = 1723.8;
Iz = 4175;
SR = 15;
L = 2.7;
lf = 1.24;
lr = L - lf;
Cf = 67248;
Cr = 53248;

%Velocity (m/s)
Vx = 50 / 3600 * 1000;

%System
A = [0,1,0,0;
    0, -(2*Cf + 2*Cr) / (m*Vx), 0, -Vx - (2*Cf*lf - 2*Cr*lr)/(m*Vx);
    0, 0, 0, 1;
    0, -(2*lf*Cf - 2*lr*Cr) / (Iz*Vx), 0, -(2*lf^2*Cf + 2*lr^2*Cr) / (Iz*Vx)];
    
B = [0; Cf/m; 0; 2*lf*Cf/Iz];

C = [0, 0, 1, 0];

D = 0;
sys = ss(A, B, C, D);

%Input
t = 0:0.01:8;
input = zeros(size(t));
for i = 1:length(t)
    if t(i) < 2
        input(i) = 0;
    elseif t(i) < 2.1
        input(i) = (t(i)-2) * -800;
    elseif t(i) < 3
        input(i) = -80;
    elseif t(i) < 3.2
        input(i) = -80 + (t(i) - 3) * 800;
    elseif t(i) < 5
        input(i) = 80;
    elseif t(i) < 5.2
        input(i) = 80 + (t(i) - 5) * -800;
    elseif t(i) < 6
        input(i) = -80;
    elseif t(i) < 6.1
        input(i) = -80 + (t(i) - 6) * 800;
    else
        input(i) = 0;
    end
end
% convert delta_sw to delta and degree to radian
input = input / SR * pi / 180;
% get yaw
yaw = lsim(sys, input, t);
% calculate position
x2 = zeros(size(t));
y2 = zeros(size(t));
for i = 2:length(t)
    x2(i) = x2(i-1) + Vx*cos(yaw(i-1))*0.01;
    y2(i) = y2(i-1) + Vx*sin(yaw(i-1))*0.01;
end