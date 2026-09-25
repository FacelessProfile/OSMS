%% LAB 01: NYQUIST-SHANNON SAMPLING, FOURIER ANALYSIS & ADC QUANTIZATION
% Course: Foundations of Modeling and Communication Systems (OSMS)
%
% Objectives:
%   1. Synthesize multi-harmonic continuous-time signal and determine critical Nyquist rate
%   2. Implement explicit Discrete Fourier Transform (DFT) and Inverse DFT (IDFT) algorithms
%   3. Reconstruct analog signals under critical sampling (Fd = 42 Hz) and 4x oversampling
%   4. Investigate acoustic decimation (downsampling) and spectral aliasing
%   5. Evaluate ADC uniform quantization error and spectral distortion across 3..16 bits
%   6. Implement vocal formant filter and tone synthesis
%
% Author: Student Implementation
% Environment: MATLAB R2019b+ (Self-contained single-file execution)

clear; close all; clc;

%% =========================================================================
%% 1. CONTINUOUS-TIME SIGNAL SYNTHESIS & NYQUIST FREQUENCY
%% =========================================================================
% Theoretical parameters:
% y(t) = cos(4*pi*f*t) + cos(6*pi*f*t) with base f = 7 Hz
% Harmonics: f1 = 2*f = 14 Hz, f2 = 3*f = 21 Hz
% Maximum spectral frequency: Fmax = 3*f = 21 Hz
% Nyquist-Shannon critical sampling boundary: Fs_critical >= 2 * Fmax = 42 Hz

f_base = 7;
y_analog = @(t) cos(4 * pi * f_base * t) + cos(6 * pi * f_base * t);

f_max = 3 * f_base;        % 21 Hz
f_nyquist = 2 * f_max;     % 42 Hz

% Continuous-time representation
t_cont = 0 : 0.001 : 1.0;
y_cont = y_analog(t_cont);

figure('Name', 'Continuous Base Signal', 'NumberTitle', 'off');
plot(t_cont, y_cont, 'LineWidth', 1.5);
grid on;
title('Continuous Signal: y(t) = cos(28\pi t) + cos(42\pi t)');
xlabel('Time (s)'); ylabel('Amplitude');

%% =========================================================================
%% 2. CRITICAL SAMPLING (Fd = 42 Hz) & CUSTOM DFT EVALUATION
%% =========================================================================
Fd = f_nyquist;
dt = 1 / Fd;
t_samp = 0 : dt : (1.0 - dt); % Exactly 42 samples on [0, 1)
y_samp = y_analog(t_samp);
N_samp = length(y_samp);

% Discrete Fourier Transform via custom algorithm
X_dft = local_dft(y_samp);

% Single-sided amplitude spectrum
P_dft = abs(X_dft / N_samp);
half_len = floor(N_samp / 2) + 1;
P_half = P_dft(1 : half_len);
P_half(2 : end - 1) = 2 * P_half(2 : end - 1);
freq_axis = (0 : half_len - 1) * (Fd / N_samp);

figure('Name', 'Critical Sampling Spectrum', 'NumberTitle', 'off');
stem(freq_axis, P_half, 'filled', 'LineWidth', 1.2);
grid on;
title(sprintf('Single-Sided DFT Spectrum at Critical Sampling Rate (Fd = %d Hz)', Fd));
xlabel('Frequency (Hz)'); ylabel('Amplitude');
xlim([0, 50]); ylim([0, 1.2]);

% Memory footprint estimation for N_samp = 42 samples
fprintf('--- Memory Footprint Evaluation (N = %d samples) ---\n', N_samp);
fprintf('Double precision (8 bytes/sample): %d bytes\n', N_samp * 8);
fprintf('Single precision (4 bytes/sample): %d bytes\n', N_samp * 4);
fprintf('Int16 resolution (2 bytes/sample): %d bytes\n\n', N_samp * 2);

%% =========================================================================
%% 3. SIGNAL RECONSTRUCTION: CRITICAL SAMPLING VS. 4X OVERSAMPLING
%% =========================================================================
% Reconstruction via custom Inverse DFT (IDFT)
y_rec_crit = local_idft(X_dft);

% 4x Oversampling: Fd_over = 4 * 42 = 168 Hz
Fd_over = 4 * Fd;
dt_over = 1 / Fd_over;
t_over = 0 : dt_over : (1.0 - dt_over);
y_over = y_analog(t_over);

X_over = local_dft(y_over);
y_rec_over = local_idft(X_over);

figure('Name', 'Bandlimited Reconstruction', 'NumberTitle', 'off');
plot(t_cont, y_cont, 'k--', 'LineWidth', 1.2, 'DisplayName', 'Original continuous');
hold on;
plot(t_samp, y_rec_crit, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 12, 'DisplayName', 'Critical (Fd = 42 Hz)');
plot(t_over, y_rec_over, 'r.-', 'LineWidth', 1.0, 'MarkerSize', 8, 'DisplayName', 'Oversampled (Fd = 168 Hz)');
hold off;
grid on;
title('Signal Reconstruction: Critical Boundary vs. 4x Oversampling');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Location', 'northeast');

%% =========================================================================
%% 4. ACOUSTIC SIGNAL ANALYSIS, DECIMATION & ALIASING
%% =========================================================================
audio_file = 'voice.wav';
if exist(audio_file, 'file')
    [audio_data, Fs] = audioread(audio_file);
    audio_data = audio_data(:, 1);
else
    % Fallback: deterministic multi-harmonic acoustic signal
    [audio_data, Fs] = local_synthetic_audio(1.5, 44100);
end

% 10x Decimation (Downsampling)
decim_factor = 10;
audio_decim = downsample(audio_data, decim_factor);
Fs_decim = round(Fs / decim_factor);

y_orig_1s = audio_data(1 : min(Fs, length(audio_data))).';
N_orig = length(y_orig_1s);
y_decim_1s = audio_decim(1 : min(Fs_decim, length(audio_decim))).';
N_decim = length(y_decim_1s);

% Original spectrum analysis up to 4000 Hz
k_max_orig = min(4000, N_orig - 1);
X_orig = local_fast_dft(y_orig_1s, k_max_orig);
P_orig = abs(X_orig / N_orig);
P_orig(2 : end) = 2 * P_orig(2 : end);
f_orig = 0 : k_max_orig;

% 95% cumulative energy bandwidth
cum_energy = cumsum(P_orig.^2);
idx_95 = find(cum_energy >= 0.95 * cum_energy(end), 1);
bw_95 = f_orig(idx_95);
fprintf('Acoustic Spectrum: 95%% Energy Bandwidth = %d Hz\n\n', bw_95);

% Decimated spectrum across Nyquist range
k_max_decim = N_decim - 1;
X_decim = local_fast_dft(y_decim_1s, k_max_decim);
P_decim = abs(X_decim / N_decim);
f_decim = (0 : k_max_decim) * (Fs_decim / N_decim);

figure('Name', 'Decimation & Aliasing', 'Color', 'w', 'NumberTitle', 'off');
plot(f_orig, P_orig, 'b', 'LineWidth', 1.2, 'DisplayName', sprintf('Original (Fs = %d Hz)', Fs));
hold on;
plot(f_decim, P_decim, 'r', 'LineWidth', 0.9, 'DisplayName', sprintf('Decimated / Aliased (Fs = %d Hz)', Fs_decim));
hold off;
grid on;
xlim([0, Fs_decim]);
ylim([0, max([P_orig, P_decim]) * 1.15]);
title('Spectral Comparison: Original vs. Decimated Audio (Aliasing)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
legend('Location', 'northeast');

%% =========================================================================
%% 5. ADC BIT-DEPTH QUANTIZATION ERROR & HARMONIC DISTORTION
%% =========================================================================
bits_tested = [3, 4, 5, 6, 16];
quantized_signals = cell(length(bits_tested), 1);
errors = zeros(length(bits_tested), 1);

SR = 100;
T = 1 / f_base;
SS = T / SR;
Fs_adc = 1 / SS;
t_adc = 0 : SS : 1.0;
y_adc_orig = y_analog(t_adc);
N_adc = length(t_adc);
freqs_adc = (0 : floor(N_adc / 2)) * (Fs_adc / N_adc);

fprintf('--- ADC Quantization Evaluation ---\n');
for i = 1 : length(bits_tested)
    b = bits_tested(i);
    [y_q, err] = local_adc_quantize(y_adc_orig, b);
    quantized_signals{i} = y_q;
    errors(i) = err;
    fprintf('Resolution %2d bits (%5d levels) | Mean Absolute Error = %.6f\n', b, 2^b, err);
end

% Quantized spectra grid
figure('Name', 'ADC Quantization Spectra', 'NumberTitle', 'off');
for i = 1 : length(bits_tested)
    b = bits_tested(i);
    F_q = fft(quantized_signals{i});
    P_q = abs(F_q / N_adc);
    P_q_half = P_q(1 : floor(N_adc / 2) + 1);
    P_q_half(2 : end - 1) = 2 * P_q_half(2 : end - 1);

    subplot(2, 3, i);
    stem(freqs_adc, P_q_half, 'LineWidth', 1.0, 'MarkerSize', 3);
    grid on;
    title(sprintf('%d-bit (%d levels)\nErr = %.5f', b, 2^b, errors(i)));
    xlabel('Frequency (Hz)'); ylabel('Amplitude');
    xlim([0, 50]); ylim([0, 1.2]);
end

subplot(2, 3, 6);
axis off;
info_box = sprintf('Quantization Law:\n------------------\nSQNR ≈ 6.02*B + 1.76 dB\nEach bit doubles levels\nand halves error.');
text(0.1, 0.5, info_box, 'FontSize', 10, 'FontName', 'monospace');

% Time-domain stairs comparison
figure('Name', 'ADC Waveforms', 'NumberTitle', 'off');
plot(t_adc, y_adc_orig, 'b', 'LineWidth', 1.5, 'DisplayName', 'Original');
hold on;
stairs(t_adc, quantized_signals{1}, 'r', 'LineWidth', 1.1, 'DisplayName', sprintf('3-bit (Err = %.4f)', errors(1)));
stairs(t_adc, quantized_signals{2}, 'Color', [0.1, 0.7, 0.2], 'LineWidth', 1.1, 'DisplayName', sprintf('4-bit (Err = %.4f)', errors(2)));
stairs(t_adc, quantized_signals{3}, 'Color', [0.9, 0.5, 0.1], 'LineWidth', 1.0, 'DisplayName', sprintf('5-bit (Err = %.4f)', errors(3)));
stairs(t_adc, quantized_signals{4}, 'Color', [0.6, 0.2, 0.8], 'LineWidth', 1.0, 'DisplayName', sprintf('6-bit (Err = %.4f)', errors(4)));
stairs(t_adc, quantized_signals{5}, 'k--', 'LineWidth', 0.8, 'DisplayName', sprintf('16-bit (Err = %.6f)', errors(5)));
hold off;
grid on;
title('ADC Quantization: Time-Domain Comparison');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Location', 'southwest');

%% =========================================================================
%% 6. VOCAL VOCODER FILTER (FORMANT SHIFT & DELAY RESONANCE)
%% =========================================================================
vader_file = 'vader_pre.wav';
if exist(vader_file, 'file')
    [y_vocal, fs_vocal] = audioread(vader_file);
    y_vocal = y_vocal(:, 1);
else
    fs_vocal = 44100;
    t_vocal = (0 : fs_vocal * 2 - 1)' / fs_vocal;
    y_vocal = (0.5 * sin(2 * pi * 130 * t_vocal) + 0.3 * sin(2 * pi * 260 * t_vocal)) .* (0.5 + 0.5 * sin(2 * pi * 2 * t_vocal));
end

y_vocal_out = local_vader_voice_filter(y_vocal, fs_vocal);

figure('Name', 'Robotic Vocoder Output', 'NumberTitle', 'off');
subplot(2, 1, 1);
plot((0 : length(y_vocal) - 1) / fs_vocal, y_vocal, 'b');
grid on; title('Original Vocal Input'); xlabel('Time (s)'); ylabel('Amplitude');
subplot(2, 1, 2);
plot((0 : length(y_vocal_out) - 1) / fs_vocal, y_vocal_out, 'r');
grid on; title('Processed Robotic Output (Pitch-Shifted & Filtered)'); xlabel('Time (s)'); ylabel('Amplitude');

fprintf('Lab 01 simulation routines executed successfully.\n');

%% =========================================================================
%% LOCAL HELPER FUNCTIONS
%% =========================================================================

function X = local_dft(x)
    % Direct Discrete Fourier Transform
    N = length(x);
    X = zeros(1, N);
    for k = 0 : N - 1
        for n = 0 : N - 1
            X(k + 1) = X(k + 1) + x(n + 1) * exp(-1i * 2 * pi * k * n / N);
        end
    end
end

function x_rec = local_idft(X)
    % Direct Inverse Discrete Fourier Transform
    N = length(X);
    x_rec = zeros(1, N);
    for n = 0 : N - 1
        for k = 0 : N - 1
            x_rec(n + 1) = x_rec(n + 1) + X(k + 1) * exp(1i * 2 * pi * k * n / N);
        end
        x_rec(n + 1) = real(x_rec(n + 1) / N);
    end
end

function X = local_fast_dft(x, k_max)
    % Vectorized direct DFT calculation up to k_max harmonics
    x = x(:).';
    N = length(x);
    n = 0 : N - 1;
    if nargin < 2
        k_max = N - 1;
    end
    k_max = min(k_max, N - 1);
    X = zeros(1, k_max + 1);
    for k = 0 : k_max
        X(k + 1) = sum(x .* exp(-1i * 2 * pi * k * n / N));
    end
end

function x_rec = local_fast_idft(X)
    % Vectorized direct IDFT calculation
    X = X(:).';
    N = length(X);
    k = 0 : N - 1;
    x_rec = zeros(1, N);
    for n = 0 : N - 1
        x_rec(n + 1) = sum(X .* exp(1i * 2 * pi * k * n / N));
    end
    x_rec = real(x_rec / N);
end

function [y_q, err] = local_adc_quantize(x, bits)
    % Uniform ADC quantization model
    levels = 2^bits - 1;
    x_min = min(x(:));
    x_max = max(x(:));
    if x_max == x_min
        y_q = x;
        err = 0;
        return;
    end
    x_scaled = (x - x_min) / (x_max - x_min) * levels;
    x_int = round(x_scaled);
    x_int = max(0, min(levels, x_int));
    y_q = (x_int / levels) * (x_max - x_min) + x_min;
    err = mean(abs(x - y_q));
end

function y_out = local_vader_voice_filter(y, fs)
    % Robotic helmet voice filter (pitch-shift + formant bandpass + delay)
    y = y(:);
    N = length(y);
    L = round(0.04 * fs);
    tau = mod((0 : N - 1)' * 0.16, L);
    w = tau / L;
    y_pitch = (1 - w) .* y(max(1, (1:N)' - round(tau))) + ...
                  w  .* y(max(1, (1:N)' - round(mod(tau + L/2, L))));

    f = (0 : 511) * (fs / 512);
    mask = (f >= 100 & f <= 3500) | (f >= fs - 3500 & f <= fs - 100);
    mask = mask + 0.6 * ((f >= 120 & f <= 250) | (f >= fs - 250 & f <= fs - 120));
    win = sin(pi * (0 : 511)' / 512);

    y_filt = zeros(N, 1);
    num_blocks = floor((N - 512) / 256);
    for m = 0 : num_blocks - 1
        idx = m * 256 + (1 : 512);
        Xb = local_fast_dft(y_pitch(idx) .* win);
        yb = local_fast_idft(Xb .* mask);
        y_filt(idx) = y_filt(idx) + yb(:);
    end

    d = round(0.012 * fs);
    y_out = y_filt + 0.35 * [zeros(d, 1); y_filt(1 : end - d)];
    max_val = max(abs(y_out));
    if max_val > 0
        y_out = 0.95 * (y_out / max_val);
    end
end

function [signal, fs] = local_synthetic_audio(duration, fs)
    % Deterministic multi-harmonic acoustic signal
    total_samples = round(duration * fs);
    t = (0 : total_samples - 1) / fs;
    f0 = 220;
    signal = zeros(size(t));
    for h = 1 : 18
        fh = h * f0;
        if fh >= fs / 2
            break;
        end
        amp = (1.0 / (h^1.15)) * (1.0 + 0.08 * sin(2 * pi * 4 * t));
        signal = signal + amp .* sin(2 * pi * fh * t + (h * 0.4));
    end
    attack = min(round(0.04 * fs), floor(total_samples / 4));
    decay = min(round(0.12 * fs), floor(total_samples / 4));
    release = min(round(0.18 * fs), floor(total_samples / 4));
    sustain_len = total_samples - attack - decay - release;

    env = [linspace(0, 1, attack), ...
           linspace(1, 0.75, decay), ...
           repmat(0.75, 1, max(0, sustain_len)), ...
           linspace(0.75, 0, release)];
    env = env(1 : total_samples);
    signal = signal .* env;
    max_peak = max(abs(signal));
    if max_peak > 0
        signal = signal / max_peak;
    end
    signal = signal(:);
end
