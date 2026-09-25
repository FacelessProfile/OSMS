%% =========================================================================
%% Лабораторная работа №1: Дискретизация, теорема Котельникова, ДПФ и АЦП
%% Курс: Основы систем моделирования и связи (ОСМС)
%% Вариант: 26
%% =========================================================================

clear; close all; clc;

%% TASK 1: Генерация и визуализация непрерывного сигнала
f = 7;
y = @(t) cos(4*pi*f*t) + cos(6*pi*f*t);

SR = 100;  % sampling points (число точек на период)
T = 1/f;   % период
SS = T/SR; % sampling step
Fs = 1/SS; % частота дискретизации (700 Гц)

t = 0:SS:1;
N = length(t);       % число отчетов

figure('Name', 'TASK 1: Исходный сигнал', 'NumberTitle', 'off');
plot(t, y(t), 'LineWidth', 1.2);
grid on;
title('TASK 1: Исходный непрерывный сигнал y(t) = cos(28\pi t) + cos(42\pi t)');
xlabel('Время (с)'); ylabel('Амплитуда');


%% TASK 2 - 3: Определение максимальной частоты и частоты дискретизации по Котельникову
% Согласно данным имеем два гармонических колебания:
% s1 = cos(4*pi*f*t) ; s2 = cos(6*pi*f*t)
% Из теоретических положений omega = 2*pi*f:
% omega1 = 4*pi*f => f1 = 2*f = 14 Гц
% omega2 = 6*pi*f => f2 = 3*f = 21 Гц
% Следовательно, максимальная частота в спектре сигнала:
%       Fmax = 3*f = 21 Гц
% По теореме Котельникова (Найквиста-Шеннона-Котельникова):
%       Fs >= 2 * Fmax
% Для нашего сигнала:
%       Fs_min = 2 * 21 = 42 Гц

freqs = (0 : floor(N/2)) * (Fs / N);
Ftransformed = fft(y(t));
Spectrum = Ftransformed / N;
HalfSpectrum = Spectrum(1 : floor(N/2) + 1);
HalfSpectrum(2:end-1) = 2 * HalfSpectrum(2:end-1);

figure('Name', 'TASK 2: Спектр FFT', 'NumberTitle', 'off');
stem(freqs, abs(HalfSpectrum), 'filled');
grid on;
title('TASK 2: Спектр сигнала (встроенное FFT)');
xlabel('Частота (Гц)'); ylabel('Амплитуда');
xlim([0, 50]);
ylim([0, 1.2]);


%% TASK 4: Оцифровка сигнала на 1 секунду с частотой дискретизации Fd = 42 Гц
% По теореме Котельникова граничная частота дискретизации Fd = 42 Гц
Fd = 42; 
dt = 1/Fd;
t4 = 0:dt:(1-dt); % ровно 42 отсчета на длительности 1 с
y4 = y(t4);       % массив временных отсчетов

figure('Name', 'TASK 4: Оцифрованный сигнал', 'NumberTitle', 'off');
stem(t4, y4, 'filled');
grid on;
title('TASK 4: Оцифрованный сигнал (граничная Fd = 42 Гц)');
xlabel('Время (с)'); ylabel('Амплитуда');


%% TASK 5: Самописное ДПФ (DFT), ширина спектра и расчёт объема памяти
% Вызываем самописную функцию ДПФ из шорткатов (my_dft)
X4 = my_dft(y4);
N4 = length(y4);

% Вычисление одностороннего амплитудного спектра
Spectr4 = abs(X4/N4);
Spectr4_half = Spectr4(1:floor(N4/2)+1);
Spectr4_half(2:end-1) = 2 * Spectr4_half(2:end-1);
f4 = (0 : floor(N4/2)) * (Fd/N4);

figure('Name', 'TASK 5: ДПФ', 'NumberTitle', 'off');
stem(f4, Spectr4_half, 'filled');
grid on;
title('TASK 5: Самописное ДПФ (Fd = 42 Гц)');
xlabel('Частота (Гц)'); ylabel('Амплитуда');
ylim([0, 1.2]);

% --- Оценка объема памяти ---
% Количество отчетов: N4 = 42
fprintf('--- TASK 5: Оценка объема памяти (N = %d отсчетов) ---\n', N4);
fprintf('  • double (8 байт): %d байт\n', N4 * 8);
fprintf('  • single/float (4 байта): %d байт\n', N4 * 4);
fprintf('  • int16 (2 байта): %d байт\n\n', N4 * 2);


%% TASK 6: Восстановление аналогового сигнала (ОДПФ) и оценка сходства
% Восстанавливаем сигнал через ИДПФ (my_idft) из шорткатов
y_rec = my_idft(X4);

% Сетка времени для непрерывного оригинала
t_analog = 0:0.001:1;

figure('Name', 'TASK 6: Восстановление Fd=42', 'NumberTitle', 'off');
plot(t_analog, y(t_analog), 'k--', 'LineWidth', 1.2);
hold on;
plot(t4, y_rec, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 10);
hold off;
grid on;
title('TASK 6: Восстановление сигнала при критической Fd = 42 Гц');
xlabel('Время (с)'); ylabel('Амплитуда');
legend('Оригинал непрерывный', 'Восстановленный (ОДПФ + линия)');


%% TASK 7: Увеличение частоты дискретизации в 4 раза (Fd7 = 168 Гц)
Fd7 = 4 * Fd; % 168 Гц
dt7 = 1/Fd7;
t7 = 0:dt7:(1-dt7); % 168 отсчетов на 1 с
y7 = y(t7);
N7 = length(y7);

X7 = my_dft(y7);
Spectr7 = abs(X7/N7);
Spectr7_half = Spectr7(1 : floor(N7/2) + 1);
Spectr7_half(2:end-1) = 2 * Spectr7_half(2:end-1);
f7 = (0 : floor(N7/2)) * (Fd7 / N7);

figure('Name', 'TASK 7: ДПФ 168 Гц', 'NumberTitle', 'off');
stem(f7, Spectr7_half, 'filled');
xlim([0, 50]);
grid on;
title('TASK 7: ДПФ при 4х оверсемплинге (Fd = 168 Гц)');
xlabel('Частота (Гц)'); ylabel('Амплитуда');
ylim([0, 1.2]);

% Восстановление сигнала при 168 Гц
y_rec7 = my_idft(X7);

figure('Name', 'TASK 7: Восстановление 168 Гц', 'NumberTitle', 'off');
plot(t_analog, y(t_analog), 'k--', 'LineWidth', 1.2);
hold on;
plot(t7, y_rec7, 'r.-', 'LineWidth', 1.0, 'MarkerSize', 8);
hold off;
grid on;
title('TASK 7: Восстановление при Fd = 168 Гц (сигнал плавный)');
xlabel('Время (с)'); ylabel('Амплитуда');
legend('Оригинал', 'Восстановленный (Fd = 168 Гц)');


%% TASK 8 - 10: Считывание и анализ параметров аудиозаписи (электрогитара)
audio_file = 'voice.wav';
if exist(audio_file, 'file')
    [GuitarArray, GuitarFD] = audioread(audio_file);
    Audioinfo = audioinfo(audio_file);
    duration = Audioinfo.Duration;
    num_samples = size(GuitarArray, 1);
    MyFD = num_samples / duration;
else
    % Fallback: генерируем синтетический сигнал гитары, если WAV не загружен в Git
    GuitarFD = 44100;
    duration = 1.5;
    num_samples = round(duration * GuitarFD);
    t_synth = (0:num_samples-1)' / GuitarFD;
    GuitarArray = zeros(size(t_synth));
    for h = 1:16
        GuitarArray = GuitarArray + (1/h^1.2) * sin(2*pi*220*h*t_synth);
    end
    GuitarArray = GuitarArray / max(abs(GuitarArray));
    MyFD = GuitarFD;
end

fprintf('--- TASK 8-10: Анализ аудиозаписи ---\n');
fprintf('Количество отсчетов: %d\n', num_samples);
fprintf('Длительность записи: %.2f с\n', duration);
fprintf('Вычисленная частота дискретизации (MyFD): %.0f Гц\n', MyFD);
fprintf('Частота из файла (GuitarFD): %d Гц\n\n', GuitarFD);


%% TASK 11: Прореживание аудиосигнала (децимация) и воспроизведение
% Прореживаем массив в 10 раз (даунсэмплинг)
DSArray = downsample(GuitarArray, 10); 
Fs_ds = round(MyFD / 10); % 4410 Гц
t_ds = (0:length(DSArray)-1)/Fs_ds;

figure('Name', 'TASK 11: Прореженный сигнал', 'NumberTitle', 'off');
plot(t_ds, DSArray);
grid on;
title('TASK 11: Прореженный аудиосигнал (Fs = 4410 Гц)');
xlabel('Время (с)'); ylabel('Амплитуда');


%% TASK 12: ДПФ оригинального и прореженного звука (алиасинг)
y_orig_1s = GuitarArray(1 : min(GuitarFD, length(GuitarArray)), 1)'; 
N_orig = length(y_orig_1s);

y_ds_1s = DSArray(1 : min(Fs_ds, length(DSArray)), 1)';        
N_ds = length(y_ds_1s);

% ДПФ для оригинала (основная полоса до 4000 Гц)
k_max_orig = min(4000, N_orig - 1); 
XOrig = my_dft_fast(y_orig_1s, k_max_orig);
P_orig = abs(XOrig/N_orig);
P_orig(2:end) = 2*P_orig(2:end);
f_orig = 0:k_max_orig;

% Определение ширины спектра (по уровню 95% энергии)
P_cum = cumsum(P_orig.^2);
idx_95 = find(P_cum >= 0.95 * P_cum(end), 1);
F_width = f_orig(idx_95);
fprintf('--- TASK 12: Спектральный анализ звука ---\n');
fprintf('Ширина спектра оригинального сигнала (95%% энергии): %.0f Гц\n\n', F_width);

% ДПФ для прореженного сигнала (алиасинг)
k_max_ds = N_ds - 1;
XDS = my_dft_fast(y_ds_1s, k_max_ds);
P_ds = abs(XDS/N_ds);
f_ds = (0 : k_max_ds) * (Fs_ds/N_ds);

figure('Name', 'TASK 12: Алиасинг', 'Color', 'w', 'NumberTitle', 'off');
plot(f_orig, P_orig, 'b', 'LineWidth', 1.2); 
hold on;
plot(f_ds, P_ds, 'r', 'LineWidth', 0.9);
hold off;
grid on;
xlim([0, Fs_ds]);
ylim([0, max([P_orig, P_ds]) * 1.15]);
title('TASK 12: Сравнение ДПФ оригинального и прореженного сигналов (алиасинг)');
xlabel('Частота (Гц)'); ylabel('Амплитуда');
legend('Оригинал (Fs = 44100 Гц)', 'Прореженный (Fs = 4410 Гц, алиасинг)');


%% TASK 13: Влияние разрядности АЦП на спектр сигнала
bits_list = [3, 4, 5, 6, 16];
y_orig_sig = y(t);

fprintf('--- TASK 13: Оценка влияния разрядности АЦП ---\n');
figure('Name', 'TASK 13: Спектры при квантовании', 'NumberTitle', 'off');
for i = 1:length(bits_list)
    b = bits_list(i);
    [y_quant, err_mean] = quantize_adc(y_orig_sig, b);
    if b == 16
        fprintf('Разрядность %d бит (%5d уровней): Средняя ошибка = %.6f (эталон Audio CD)\n', b, 2^b, err_mean);
    else
        fprintf('Разрядность %d бит (%2d уровней): Средняя ошибка = %.5f\n', b, 2^b, err_mean);
    end
 
    F_q = fft(y_quant);
    P_q = abs(F_q / N);
    P_q_half = P_q(1 : floor(N/2) + 1);
    P_q_half(2:end-1) = 2 * P_q_half(2:end-1);
    
    subplot(2, 3, i);
    stem(freqs, P_q_half, 'LineWidth', 1.0, 'MarkerSize', 3);
    grid on;
    title(sprintf('%d бит (%d ур.) | err=%.4f', b, 2^b, err_mean));
    xlabel('Частота (Гц)'); ylabel('Амплитуда');
    xlim([0, 50]); ylim([0, 1.2]);
end

[y_q3, err3] = quantize_adc(y_orig_sig, 3);
[y_q4, err4] = quantize_adc(y_orig_sig, 4);
[y_q5, err5] = quantize_adc(y_orig_sig, 5);
[y_q6, err6] = quantize_adc(y_orig_sig, 6);
[y_q16, err16] = quantize_adc(y_orig_sig, 16);

figure('Name', 'TASK 13: Квантование во времени', 'NumberTitle', 'off');
plot(t, y_orig_sig, 'b', 'LineWidth', 1.5);
hold on;
stairs(t, y_q3, 'r', 'LineWidth', 1.1);
stairs(t, y_q4, 'Color', [0.1, 0.7, 0.2], 'LineWidth', 1.1);
stairs(t, y_q5, 'Color', [0.9, 0.5, 0.1], 'LineWidth', 1.0);
stairs(t, y_q6, 'Color', [0.6, 0.2, 0.8], 'LineWidth', 1.0);
stairs(t, y_q16, 'Color', [0.3, 0.3, 0.3], 'LineStyle', '--', 'LineWidth', 0.8);
hold off;
grid on;
title('TASK 13: Сравнение квантования во времени (3..16 бит)');
xlabel('Время (с)'); ylabel('Амплитуда');
legend('Оригинал', ...
       sprintf('3 бита (err=%.4f)', err3), ...
       sprintf('4 бита (err=%.4f)', err4), ...
       sprintf('5 бит (err=%.4f)', err5), ...
       sprintf('6 бит (err=%.4f)', err6), ...
       sprintf('16 бит (err=%.6f, CD)', err16), ...
       'Location', 'southwest');


%% Дополнительное 1: Darth Vader Voice DSP Effect
vader_file = 'vader_pre.wav';
if exist(vader_file, 'file')
    [y_vader_in, fs_vader] = audioread(vader_file);
    y_vader_in = y_vader_in(:, 1);
else
    fs_vader = 44100;
    t_v = (0 : fs_vader * 1.5 - 1)' / fs_vader;
    y_vader_in = 0.5 * sin(2*pi*140*t_v) + 0.3 * sin(2*pi*280*t_v);
end

y_vader = vader_voice(y_vader_in, fs_vader);

figure('Name', 'Доп: Вокодер Дарт Вейдер', 'NumberTitle', 'off');
subplot(2, 1, 1);
plot((0:length(y_vader_in)-1)/fs_vader, y_vader_in, 'b');
grid on; title('Оригинальный голос'); xlabel('Время (с)');
subplot(2, 1, 2);
plot((0:length(y_vader)-1)/fs_vader, y_vader, 'r');
grid on; title('Обработанный голос Дарта Вейдера'); xlabel('Время (с)');


%% Дополнительное 2: Синтез мелодии "В траве сидел кузнечик"
Fs_kuz = 48000;
NOTE_C4  = 262; NOTE_E4  = 330; NOTE_F4  = 349; NOTE_G4  = 392; NOTE_GS4 = 415;

melodyes = [NOTE_E4, NOTE_C4, NOTE_E4, NOTE_C4, NOTE_E4, NOTE_F4, NOTE_F4, ...
            NOTE_F4, NOTE_C4, NOTE_F4, NOTE_C4, NOTE_F4, NOTE_E4, NOTE_E4];
durations = [250, 250, 250, 250, 250, 250, 500, ...
             250, 250, 250, 250, 250, 250, 500];

mels = [melodyes, melodyes, melodyes(1:7)];
durs = [durations, durations, durations(1:7)];

kuz_signal = [];
for i = 1:length(mels)
    dur = durs(i)/1000;
    N_total = round(dur*Fs_kuz);
    N_tone  = round(0.85*N_total);
    t_k = (0:N_tone-1)/Fs_kuz;
    tone = sin(2*pi*mels(i)*t_k);
    kuz_signal = [kuz_signal, tone, zeros(1, N_total - N_tone)]; %#ok<AGROW>
end

figure('Name', 'Доп: Кузнечик спектр', 'NumberTitle', 'off');
Fr_kuz = fft(kuz_signal);
Ns_kuz = length(kuz_signal);
f_kuz = (0:Ns_kuz-1) * (Fs_kuz / Ns_kuz);
amp_kuz = abs(Fr_kuz) / Ns_kuz;
half_kuz = 1:floor(Ns_kuz/2);

stem(f_kuz(half_kuz), 2*amp_kuz(half_kuz), 'Marker', 'none');
grid on;
title('Спектр синтезированной мелодии (Кузнечик)');
xlabel('Частота (Гц)'); ylabel('Амплитуда');
xlim([0, 1000]);

%% =========================================================================
%% ШОРТКАТЫ И ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
%% =========================================================================

% ДПФ
function X = my_dft(x)
    N = length(x);
    X = zeros(1, N);
    for k = 0 : N - 1
        for n = 0 : N - 1
            X(k+1) = X(k+1) + x(n+1) * exp(-1i * 2 * pi * k * n / N);
        end
    end
end

% ИДПФ (ОДПФ)
function x_rec = my_idft(X)
    N = length(X);
    x_rec = zeros(1, N);
    for n = 0 : N - 1
        for k = 0 : N - 1
            x_rec(n+1) = x_rec(n+1) + X(k+1) * exp(1i * 2 * pi * k * n / N);
        end
        x_rec(n+1) = real(x_rec(n+1) / N);
    end
end

% ДПФ с векторной суммой (быстрое прямое)
function X = my_dft_fast(x, k_max)
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

% ОДПФ с векторной суммой (быстрое инверсное)
function x_rec = my_idft_fast(X)
    X = X(:).';
    N = length(X);
    k = 0 : N - 1;
    x_rec = zeros(1, N);
    for n = 0 : N - 1
        x_rec(n + 1) = sum(X .* exp(1i * 2 * pi * k * n / N));
    end
    x_rec = real(x_rec / N);
end

% Квантование АЦП с вычислением средней ошибки
function [y_q, err] = quantize_adc(x, bits)
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

% Эффект голоса Дарта Вейдера
function y_out = vader_voice(y, fs)
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
        Xb = my_dft_fast(y_pitch(idx) .* win);
        yb = my_idft_fast(Xb .* mask);
        y_filt(idx) = y_filt(idx) + yb(:);
    end

    d = round(0.012 * fs);
    y_out = y_filt + 0.35 * [zeros(d, 1); y_filt(1 : end - d)];
    max_val = max(abs(y_out));
    if max_val > 0
        y_out = 0.95 * (y_out / max_val);
    end
end
