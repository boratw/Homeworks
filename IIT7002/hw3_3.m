% At each cycles, Q = integral 0 to 0.001ms {i(t)} = 100 * 0.5 / 1000 / 3600 (Ah)
% Q_T = 400 Ah (4 parallel set of 100 Ah battery)
% DoD(t) = SOD(t) / Q_T = 0.8 
% then SOD(t) = 0.8 Q_T
% SOD(t) = n * 100 * 0.5 / 1000 / 3600 at n = (number of cycle)
c = 100 * 0.5 / 1000 / 3600;
n = 400 * 0.8 / c
% take 1ms per every cycle
t = n * 0.001 % Second
th = t / 3600 % Hour

% Approximately, In this situation, Every 51 cycles battery discharges
% 50 * {100 * 0.5 / 1000 / 3600} (Ah) and regenarates
% 80 * 0.5 / 1000 / 3600 (Ah)
% So can assume that each cycle, battery discharges
% { 50 * {100 * 0.5 / 1000 / 3600} -  80 * 0.5 / 1000 / 3600 } / 51 (Ah)
c = ( 50 * (100 * 0.5 / 1000 / 3600) -  80 * 0.5 / 1000 / 3600 ) / 51;
n = 400 * 0.8 / c
% take 1ms per every cycle
t = n * 0.001 % Second
th = t / 3600 % Hour