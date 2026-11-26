% ALL Params
poly = [1 0 0 0 1 1 1 1]; % lab5: x^7 + x^3 + x^2 + x + 1
M = length(poly)-1;       % lab5: CRC len 7 bit
G = 31;                   % lab4: Gold's Seq len
N = 2;                    % sampels per bit
fs = 1000;                % sampling freq

% FIO + ASCII
FIO_str = input('Type Your name and surname: ', 's');
data = ascii_encode(FIO_str);
L = length(data);
fprintf('ascii code len: %d bit\n', L);

figure; grid on;
stairs(data);
ylim([-0.2 1.2]);
title('ASCII bitstream');
xlabel('Bit'); ylabel('Value');

% CRC representation
crc = calc_crc([data, zeros(1, M)], poly);
fprintf('CRC (len %d bit): %s\n', M, num2str(crc, '%d'));

% Gold's code generation(for synchra) && frame construction [Gold + Data + CRC]
gold = gen_gold();
frame = [gold, data, crc];

figure;
xlabel('Bit'); ylabel('Value');
stairs(frame); title('Constructed Frame');
grid on;
ylim([-0.2 1.2]);

tx = repelem(frame, N); % Bits -> Samples, N bit per frame

figure;
plot(tx); title('TX signal SAMPLES');
grid on;
ylim([-0.2 1.2]);
xlabel('Sample'); ylabel('A');

Signal = zeros(1, 2 * length(tx)); % SIG forming with 2*N*(L+M+G) lenght
shift = input(sprintf('Type an offset (from 0 to %d): ', length(tx)));
Signal(shift+1 : shift+length(tx)) = tx;

figure;
plot(Signal); title('Offset Signal');
grid on;
ylim([-0.2 1.2]);
xlabel('Sample'); ylabel('A');

% AWGN overlaying
sigma = input('Here type sigma:');
noise = sigma * randn(1,length(Signal));
rx = Signal + noise;

figure;
plot(rx); title(sprintf('RECV Signal (sigma %.2f)', sigma));
grid on;
xlabel('Sample'); ylabel('A');

% Synchra
[start_ind, ~] = find_sync(rx, gold, N);
fprintf('Synchra start: sample %d\n', start_ind);
rx_sync = rx(start_ind:end);

% Bits recv
rx_bits = demod_bits(rx_sync, N, L + M + G);

% Decapsulation
rx_no_gold = rx_bits(G+1 : end);

% CheckSum
r = calc_crc(rx_no_gold, poly);
fprintf('rx remainder: %s\n', num2str(r, '%d'));

if any(r)
    disp('WARNING SMTH WENT WRONG(');
else
    disp('Data restored successfully');
    rx_data = rx_no_gold(1 : end-M);
    decoded = ascii_decode(rx_data);
    fprintf('restored FIO: %s\n', decoded);
end

% TX vs RX SPECTRUM
f1 = linspace(-fs/2, fs/2, length(Signal));

figure;

subplot(2,1,1);
grid on;
plot(f1, abs(fftshift(fft(Signal))) / length(Signal));
title('TX spectrum');
xlabel('F'); ylabel('A');

subplot(2,1,2);
plot(f1, abs(fftshift(fft(rx))) / length(rx)); grid on;
title('RX spectrum');
xlabel('F'); ylabel('A');

s_short = repelem(frame, N/2);
s_mid = tx;
s_long = repelem(frame, N*2);

figure;
hold on;
plot(linspace(-fs/2,fs/2, length(s_short)), abs(fftshift(fft(s_short))) / length(s_short));
plot(linspace(-fs/2,fs/2, length(s_mid)),   abs(fftshift(fft(s_mid))) / length(s_mid));
plot(linspace(-fs/2,fs/2, length(s_long)),  abs(fftshift(fft(s_long))) / length(s_long));
title('Spectrum comparison');
legend(sprintf('Lo (N=%d)',N/2), sprintf('Mid (N=%d)',N), sprintf('Hi (N=%d)',N*2));
xlabel('F'); ylabel('A');
grid on;

% Monte Carlo loop: BLER, BER and sync correlation peak vs sigma (parfored)
sigmas = 0:0.02:1;
runs = 5000;
BLER = zeros(1, length(sigmas));
BER = zeros(1, length(sigmas));
corrPeak = zeros(1, length(sigmas));
need_len = N*(L+M+G);
sig_len = length(Signal);

parfor s = 1:length(sigmas)
    rng(s);
    sg = sigmas(s);
    blk_err = 0;
    bit_err = 0;
    pk_sum = 0;


    for i = 1:runs
        rx_mc = Signal + sg * randn(1, sig_len);
        [st, pk] = find_sync(rx_mc, gold, N);
        pk_sum = pk_sum+pk;

        rx_s = rx_mc(st:end);
        if length(rx_s) < need_len
            rx_s(end+1 : need_len) = 0;
        end

        rb = demod_bits(rx_s, N, L+M+G);
        r_no_g = rb(G+1 : end);
        rem_mc = calc_crc(r_no_g, poly);
        r_data = r_no_g(1 : end-M);

        bit_err = bit_err + sum(r_data ~= data);
        if any(rem_mc) || any(r_data ~= data)
            blk_err = blk_err + 1;
        end
        
    end

    BLER(s) = blk_err/runs;
    BER(s) = bit_err/ (runs*L);
    corrPeak(s) = pk_sum / runs;
    
    
end

figure;
hold on; grid on;
plot(sigmas, BLER, 'r');
plot(sigmas, BER, 'b');
plot(sigmas, corrPeak, 'g');
legend('BLER', 'BER', 'Corr peak (norm)');
xlabel('sigma'); ylabel('Value');
title(sprintf('BLER, BER and Sync Peak vs sigma (over %d runs)', runs));

% ------------------------------------------------------ FUNCTIONS --------------------------------------------------------------------

function bits = ascii_encode(str)
    bits = zeros(1, length(str) * 8);
    for i = 1:length(str)
        code = double(str(i));
        bits((i-1)*8 + 1 : i*8) = bitget(code, 8:-1:1);
    end
end

function str = ascii_decode(bits)
    w = [128 64 32 16 8 4 2 1];
    n_chars = floor(length(bits)/8);
    str = '';
    for i = 1:n_chars
        b = bits((i-1)*8 + 1 : i*8);
        str(i) = char(sum(b .* w));
    end
end

% lab5
function r = calc_crc(bits, poly)
    n = length(poly);
    for i = 1 : length(bits) - n+1
        if bits(i) == 1
            bits(i : i+n-1) = xor(bits(i : i+n-1), poly);
        end
    end
    r = bits(end-n+2 : end);
end

% Gold seq gen (x=25, y=1)
function seq = gen_gold()
    x = [1 1 0 0 1];
    y = [0 0 0 0 1];
    seq = zeros(1, 31);
    for i = 1:31
        seq(i) = xor(x(5), y(5));
        bx = xor(x(4), x(5));
        by = xor(y(2), y(5));
        x = [bx, x(1:4)];
        y = [by, y(1:4)];
    end
end

% Synchra finder (returns index and normalized correlation peak)
function [ind, peak] = find_sync(rx, gold, N)
    ref = repelem(gold, N);
    ref = ref - mean(ref);
    len = length(ref);
    c = conv(rx, fliplr(ref), 'valid');
    [~, ind] = max(c);
    seg = rx(ind : ind+len-1);
    seg = seg - mean(seg);
    peak = sum(seg .* ref) / (norm(seg) * norm(ref) + eps);
end

% Demod
function bits = demod_bits(sig, N, count)
    P = N/2;
    bits = zeros(1, count);
    for i = 1:count
        acc = sum(sig((i-1)*N +1 : i*N));
        bits(i) = acc >= P;
    end
end
