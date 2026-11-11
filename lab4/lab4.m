clear; clc; close all;

N = 31;

% variant 25(odd)
x1 = [1, 1, 0, 0, 1]; % 25_10
y1 = [0, 0, 0, 0, 1]; % 32 mod 31 = 1_10

% Gold's seq gen-n(by fig 4.5)
seq1 = zeros(1, N);
x = x1; y = y1;
for i = 1:N
    seq1(i) = xor(x(5), y(5));
    bx = xor(x(4), x(5)); by = xor(y(2), y(5));
    x = [bx, x(1:4)]; y = [by, y(1:4)];
end
disp('Gold sequence 1:'); disp(num2str(seq1, '%d'));

% Cyclic autocorrelation table for seq1
R_manual = zeros(1, N + 1);
fprintf('\nShift | ACF\n');
for tau = 0:N
    sh = circshift(seq1, [0, tau]);
    R_manual(tau + 1) = (sum(seq1 == sh) - sum(seq1 ~= sh)) / N;
    fprintf('%5d | %5.2f\n', tau, R_manual(tau + 1));
end

% modified polynoms second seq: x2 = 26, y2 = 27
x2 = [1, 1, 0, 1, 0]; y2 = [1, 1, 0, 1, 1];
seq2 = zeros(1, N);
x = x2; y = y2;
for i = 1:N
    seq2(i) = xor(x(5), y(5));
    bx = xor(x(4), x(5)); by = xor(y(2), y(5));
    x = [bx, x(1:4)]; y = [by, y(1:4)];
end
disp('Gold sequence 2:'); disp(num2str(seq2, '%d'));

% xcorr R12
r12_manual = (sum(seq1 == seq2) - sum(seq1 ~= seq2)) / N;
fprintf('\nCross-correlation R12 (manual): %.4f\n', r12_manual);

% Reference m sequence from y register 
mseq = zeros(1, N);
y = y1;
for i = 1:N
    mseq(i) = y(5);
    by = xor(y(2), y(5));
    y = [by, y(1:4)];
end

% ACF for seq2 && m sequence
R_seq2 = zeros(1, N);
R_mseq = zeros(1, N);
for tau = 0:(N - 1)
    sh2 = circshift(seq2, [0, tau]);
    R_seq2(tau + 1) = (sum(seq2 == sh2) - sum(seq2 ~= sh2)) / N;
    shm = circshift(mseq, [0, tau]);
    R_mseq(tau + 1) = (sum(mseq == shm) - sum(mseq ~= shm)) / N;
end

% autocorr and xcorr
[r_auto, lags_auto] = autocorr(seq1, 'NumLags', N - 1);
s1_bip = 1 - 2 * seq1; s2_bip = 1 - 2 * seq2;
[r_xc, lags_xc] = xcorr(s1_bip, s2_bip, 'normalized');
zero_idx = find(lags_xc == 0);
fprintf('Cross-correlation R12 (xcorr):  %.4f\n', r_xc(zero_idx));

figure('Position', [100, 100, 950, 360]);

subplot(1, 2, 1);
plot(0:(N - 1), R_manual(1:N), 'b-o', 'LineWidth', 1.2, 'MarkerSize', 4); hold on;
plot(0:(N - 1), R_seq2, 'g-s', 'LineWidth', 1.2, 'MarkerSize', 4);
plot(0:(N - 1), R_mseq, 'k--', 'LineWidth', 1.2);
grid on; xlim([0, N - 1]); ylim([-0.55, 1.1]);
xlabel('Задержка \tau'); ylabel('Автокорреляция R(\tau)');
title('а) АКФ для различных полиномов');
legend('seq1 (x_1=25, y_1=1)', 'seq2 (x_2=26, y_2=27)', 'М-последовательность (-1/N)', 'Location', 'northeast');

subplot(1, 2, 2);
plot(0:(N - 1), R_manual(1:N), 'b-o', 'LineWidth', 1.2, 'MarkerSize', 4); hold on;
plot(lags_auto, r_auto, 'r-d', 'LineWidth', 1.2, 'MarkerSize', 4);
grid on; xlim([0, N - 1]); ylim([-0.55, 1.1]);
xlabel('Задержка \tau'); ylabel('Автокорреляция R(\tau)');
title('б) Сравнение с функцией autocorr()');
legend('Ручной расчет (циклический)', 'Функция autocorr()', 'Location', 'northeast');

saveas(gcf, 'figures/fig_autocorr_comparison.png');

% Autocheck for seq1
autocheck(seq1);

function autocheck(s)
    n = length(s);
    fprintf('\n--- Check sequence (N = %d) ---\n', n);
    n1 = sum(s == 1); n0 = sum(s == 0); diff = abs(n1 - n0);
    p1 = 'FAIL'; if diff <= 1, p1 = 'PASS'; end
    fprintf('1. Balance: zeros = %d, ones = %d, diff = %d [%s]\n', n0, n1, diff, p1);
    
    runs = 1;
    for i = 2:n
        if s(i) ~= s(i - 1), runs = runs + 1; end
    end
    if s(1) == s(end) && runs > 1, runs = runs - 1; end
    p2 = 'FAIL'; if runs >= round(n / 2), p2 = 'PASS'; end
    fprintf('2. Cyclic runs: count = %d [%s]\n', runs, p2);
    
    ac = zeros(1, n - 1);
    for t = 1:(n - 1)
        sh = circshift(s, [0, t]);
        ac(t) = (sum(s == sh) - sum(s ~= sh)) / n;
    end
    u_vals = unique(round(ac, 3));
    fprintf('3. Correlation (tau != 0): %s\n', num2str(u_vals));
    if length(u_vals) == 1 && abs(u_vals - (-1/n)) < 0.01
        disp('   Two-level ACF (-1/N): YES [PASS]');
    else
        disp('   Two-level ACF (-1/N): NO [FAIL]');
    end
end
