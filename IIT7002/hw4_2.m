% v_s = v_a + v_b б╨120вк + v_b б╨240вк
v_a = 240;
v_b = 50 * exp(2 * pi * j / 3);
v_c = -240 * exp(4 * pi * j / 3);
v_s = v_a + v_b + v_c;

v_s_mag = abs(v_s) % Magnitude
v_s_angle = angle(v_s) % Angle

figure
compass(v_s, 'k');
hold on
compass(v_a, 'r');
compass(v_b, 'g');
compass(v_c, 'b');
legend('v_s', 'v_a', 'v_b', 'v_c');
hold off