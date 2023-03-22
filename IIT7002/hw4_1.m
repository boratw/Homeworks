% v_s = v_a + v_b б╨120вк + v_b б╨240вк
% (a)
v_s = 240 - 120 * exp(2 * pi * j / 3)  - 120 * exp(4 * pi * j / 3);

v_s_mag = abs(v_s) % Magnitude
v_s_angle = angle(v_s) % Angle

% (b)
v_s = 207.8 + 0 * exp(2 * pi * j / 3)  - 207.8 * exp(4 * pi * j / 3);

v_s_mag = abs(v_s) % Magnitude
v_s_angle = angle(v_s) % Angle