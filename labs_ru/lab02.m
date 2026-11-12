clear; close all; clc;

%% Исходные данные
P_tx_BS = 46;       % Мощность передатчика БС, дБм
P_tx_UE = 24;       % Мощность передатчика абонента, дБм
G_BS = 21;          % КУ антенны БС, дБи
G_UE = 0;           % КУ антенны UE, дБи
MIMO_gain = 3;      % Выигрыш от MIMO 2x2, дБ

f_GHz = 1.8;        % Частота, ГГц
f_MHz = f_GHz * 1000;
BW_UL = 10e6;       % Полоса UL, Гц
BW_DL = 20e6;       % Полоса DL, Гц

NF_BS = 2.4;        % Коэффициент шума БС, дБ
NF_UE = 6.0;        % Коэффициент шума UE, дБ
SINR_UL = 4.0;      % Требуемый SINR для UL, дБ
SINR_DL = 2.0;      % Требуемый SINR для DL, дБ

L_feeder = 2.0 + 0.4 + 0.5; % Потери в АФТ (фидер + МШУ + джампер), дБ
M_pen = 15;                 % Запас на проникновение, дБ
M_int = 1;                  % Запас на интерференцию, дБ

h_BS = 30;          % Высота подвеса антенны БС, м
h_ms = 1.5;         % Высота антенны UE, м
h_roof = 20;        % Средняя высота крыш, м
w_street = 20;      % Ширина улиц, м
b_dist = 40;        % Расстояние между зданиями, м
phi = 90;           % Угол прихода луча, град.

S_macro = 100;      % Площадь макросети, кв. км
S_indoor = 4;       % Площадь помещений, кв. км

img_dir = "/home/rook/Desktop/UNI/OSMS/lab2";
if ~exist(img_dir, 'dir')
    img_dir = pwd; % сохраняем в текущую папку, если путь не найден
end

%% Расчет бюджета канала (MAPL)
% Восходящий канал (UL)
Noise_UL = -174 + 10*log10(BW_UL);
Sens_BS = NF_BS + Noise_UL + SINR_UL;
MAPL_UL = P_tx_UE - L_feeder + G_BS + MIMO_gain - M_int - M_pen - Sens_BS;

% Нисходящий канал (DL)
Noise_DL = -174 + 10*log10(BW_DL);
Sens_UE = NF_UE + Noise_DL + SINR_DL;
MAPL_DL = P_tx_BS - L_feeder + G_BS + MIMO_gain - M_int - M_pen - Sens_UE;

fprintf('--- Channel Budget ---\n');
fprintf('Тепловой шум (UL / DL): %.2f / %.2f дБм\n', Noise_UL, Noise_DL);
fprintf('Чувствительность (БС / UE): %.2f / %.2f дБм\n', Sens_BS, Sens_UE);
fprintf('MAPL UL: %.2f дБ\n', MAPL_UL);
fprintf('MAPL DL: %.2f дБ\n', MAPL_DL);
fprintf('Разница MAPL_DL - MAPL_UL: %.2f дБ\n\n', MAPL_DL - MAPL_UL);

%% Модели распространения
d_km = 0.01:0.001:10;
d_m = d_km * 1000;

% FSPM
PL_FSPM = 32.44 + 20*log10(f_MHz) + 20*log10(d_km);

% UMiNLOS
PL_UMiNLOS = 26*log10(f_GHz) + 22.7 + 36.7*log10(d_m);

% COST 231 Hata
A = 46.3; 
B = 33.9;
a_ms = 3.2 * (log10(11.75 * h_ms))^2 - 4.97;

s = zeros(size(d_km));
idx_far = d_km >= 1;
s(idx_far) = 44.9 - 6.55 * log10(f_MHz);
s(~idx_far) = (47.88 + 13.9*log10(f_MHz) - 13.9*log10(h_BS)) / log10(50);

PL_COST231 = A + B*log10(f_MHz) - 13.82*log10(h_BS) - a_ms + s .* log10(d_km);

% Walfish-Ikegami
PL_WI_LOS = 42.6 + 20*log10(f_MHz) + 26*log10(d_km);

L0 = 32.44 + 20*log10(f_MHz) + 20*log10(d_km);
if phi < 35
    L_ori = -10 + 0.354 * phi;
elseif phi < 55
    L_ori = 2.5 + 0.075 * (phi - 35);
else
    L_ori = 4.0 - 0.114 * (phi - 55);
end

L2 = -16.9 - 10*log10(w_street) + 10*log10(f_MHz) + 20*log10(h_roof - h_ms) + L_ori;

if h_BS > h_roof
    L11 = -18 * log10(1 + h_BS - h_roof);
    ka = 54;
    kd = 18;
else
    L11 = 0;
    ka = 54 - 0.8 * (h_BS - h_roof);
    kd = 18 - 15 * (h_BS - h_roof) / h_roof;
end
kf = -4 + 0.7 * (f_MHz / 925 - 1);

L1 = L11 + ka + kd*log10(d_km) + kf*log10(f_MHz) - 9*log10(b_dist);
PL_WI_NLOS = L0 + max(0, L1 + L2);

% График сравнения моделей
fig1 = figure(1);
semilogx(d_km, PL_FSPM, 'k--', 'LineWidth', 2); hold on;
semilogx(d_km, PL_UMiNLOS, 'm-.', 'LineWidth', 2);
semilogx(d_km, PL_COST231, 'b-', 'LineWidth', 2);
semilogx(d_km, PL_WI_NLOS, 'r-', 'LineWidth', 2);
semilogx(d_km, PL_WI_LOS, 'g:', 'LineWidth', 2);

yline(MAPL_DL, '--', 'MAPL DL', 'Color', [0.85 0.33 0.1], 'LineWidth', 2.1);
yline(MAPL_UL, '--', 'MAPL UL', 'Color', [0.49 0.18 0.56], 'LineWidth', 2.1);

grid on;
xlim([0.01, 10]);
ylim([40, 180]);
xlabel('Расстояние d, км');
ylabel('Потери сигнала PL, дБ');
title('Сравнение моделей затухания радиосигнала');
legend('FSPM', 'UMiNLOS', 'COST 231 Hata', 'Walfish-Ikegami NLOS', 'Walfish-Ikegami LOS', ...
       'Location', 'southeast');
saveas(fig1, fullfile(img_dir, 'fig1_models_comparison.png'));

%% Расчет покрытия макросети (Hata)
R_UL_macro = d_km(find(PL_COST231 >= MAPL_UL, 1));
R_DL_macro = d_km(find(PL_COST231 >= MAPL_DL, 1));
R_macro = min(R_UL_macro, R_DL_macro);

S_site_macro = 1.95 * R_macro^2;
N_macro = ceil(S_macro / S_site_macro);

fprintf('--- Макросеть (COST 231 Hata) ---\n');
fprintf('Радиус UL: %.3f км, Радиус DL: %.3f км\n', R_UL_macro, R_DL_macro);
fprintf('Выбранный радиус соты: %.3f км\n', R_macro);
fprintf('Площадь одной БС (3 сектора): %.3f кв. км\n', S_site_macro);
fprintf('Количество БС для покрытия 100 кв. км: %d шт.\n\n', N_macro);

fig2 = figure(2);
plot(d_km, PL_COST231, 'b-', 'LineWidth', 2); hold on;
yline(MAPL_DL, '--', 'Color', [0.85 0.33 0.1], 'LineWidth', 2);
yline(MAPL_UL, '--', 'Color', [0.49 0.18 0.56], 'LineWidth', 2);

plot(R_UL_macro, MAPL_UL, 'ro', 'MarkerFaceColor', 'r');
plot(R_DL_macro, MAPL_DL, 'go', 'MarkerFaceColor', 'g');

plot([R_UL_macro R_UL_macro], [60 MAPL_UL], 'r:');
plot([R_DL_macro R_DL_macro], [60 MAPL_DL], 'g:');

grid on;
xlim([0, 3]);
ylim([60, 160]);
xlabel('Расстояние d, км');
ylabel('Потери PL, дБ');
title('Определение радиуса соты для макросети (Hata)');
legend('COST 231 Hata', 'MAPL DL', 'MAPL UL', ...
       sprintf('R_{UL} = %.2f км', R_UL_macro), ...
       sprintf('R_{DL} = %.2f км', R_DL_macro), 'Location', 'southeast');
saveas(fig2, fullfile(img_dir, 'fig2_macro_cell_radius.png'));

%% Расчет покрытия в помещениях (UMiNLOS)
R_UL_ind = d_m(find(PL_UMiNLOS >= MAPL_UL, 1));
R_DL_ind = d_m(find(PL_UMiNLOS >= MAPL_DL, 1));
R_ind_m = min(R_UL_ind, R_DL_ind);
R_ind_km = R_ind_m / 1000;

S_site_ind_hex = 1.95 * R_ind_km^2;
N_ind_hex = ceil(S_indoor / S_site_ind_hex);

S_site_ind_omni = pi * R_ind_km^2;
N_ind_omni = ceil(S_indoor / S_site_ind_omni);

fprintf('--- Сеть indoor (UMiNLOS) ---\n');
fprintf('Радиус UL: %.1f м, Радиус DL: %.1f м\n', R_UL_ind, R_DL_ind);
fprintf('Выбранный радиус соты: %.1f м\n', R_ind_m);
fprintf('Количество 3-секторных сайтов: %d\n', N_ind_hex);
fprintf('Количество всенаправленных точек доступа: %d\n\n', N_ind_omni);

d_ind_plot = 1:1500;
PL_ind_plot = 26*log10(f_GHz) + 22.7 + 36.7*log10(d_ind_plot);

fig3 = figure(3);
plot(d_ind_plot, PL_ind_plot, 'm-', 'LineWidth', 2); hold on;
yline(MAPL_DL, '--', 'Color', [0.85 0.33 0.1], 'LineWidth', 2.1);
yline(MAPL_UL, '--', 'Color', [0.49 0.18 0.56], 'LineWidth', 2.1);

plot(R_UL_ind, MAPL_UL, 'ro', 'MarkerFaceColor', 'r');
plot(R_DL_ind, MAPL_DL, 'go', 'MarkerFaceColor', 'g');

plot([R_UL_ind R_UL_ind], [40 MAPL_UL], 'r:');
plot([R_DL_ind R_DL_ind], [40 MAPL_DL], 'g:');

grid on;
xlim([0, 1500]);
ylim([40, 160]);
xlabel('Расстояние d, м');
ylabel('Потери PL, дБ');
title('Определение радиуса соты в помещении (UMiNLOS)');
legend('UMiNLOS', 'MAPL DL', 'MAPL UL', ...
       sprintf('R_{UL} = %.1f м', R_UL_ind), ...
       sprintf('R_{DL} = %.1f м', R_DL_ind), 'Location', 'southeast');
saveas(fig3, fullfile(img_dir, 'fig3_indoor_cell_radius.png'));

%% Зависимость range соты от температуры и частоты несущей
k_B = 1.38e-23;             % Постоянная Больцмана, Дж/К
T_C = -40:2:60;             % Диапазон температур, °C
T_K = T_C + 273.15;         % Перевод в Кельвины

f_vec_MHz = 1500:25:2000;   % Диапазон частот Hata, МГц
[F_grid, T_grid] = meshgrid(f_vec_MHz, T_C);
T_grid_K = T_grid + 273.15;

% Пересчет теплового шума и бюджета с учетом реальной температуры: N = k*T*B
Noise_UL_T = 10*log10(k_B .* T_grid_K .* BW_UL) + 30; % перевод из дБВт в дБм (+30)
Sens_BS_T = NF_BS + Noise_UL_T + SINR_UL;
MAPL_UL_T = P_tx_UE - L_feeder + G_BS + MIMO_gain - M_int - M_pen - Sens_BS_T;

Noise_DL_T = 10*log10(k_B .* T_grid_K .* BW_DL) + 30;
Sens_UE_T = NF_UE + Noise_DL_T + SINR_DL;
MAPL_DL_T = P_tx_BS - L_feeder + G_BS + MIMO_gain - M_int - M_pen - Sens_UE_T;

% Лимитирующий бюджет (берем минимум из UL и DL)
MAPL_lim = min(MAPL_UL_T, MAPL_DL_T);

% Вычисление радиуса соты по модели Hata для каждой точки сетки
R_grid = zeros(size(F_grid));

for i = 1:size(F_grid, 1)
    for j = 1:size(F_grid, 2)
        f_cur = F_grid(i, j);
        mapl_cur = MAPL_lim(i, j);
        
        % Постоянная часть потерь на частоте f_cur
        PL_0 = A + B*log10(f_cur) - 13.82*log10(h_BS) - a_ms;
        
        % Пробуем формулу для d >= 1 км
        s_far = 44.9 - 6.55*log10(f_cur);
        d_val = 10^((mapl_cur - PL_0) / s_far);
        
        % Если радиус получился меньше 1 км, пересчитываем с коэффициентом для малых дистанций
        if d_val < 1
            s_near = (47.88 + 13.9*log10(f_cur) - 13.9*log10(h_BS)) / log10(50);
            d_val = 10^((mapl_cur - PL_0) / s_near);
        end
        
        R_grid(i, j) = d_val;
    end
end

fig4 = figure(4);
surf(F_grid, T_grid, R_grid, 'EdgeColor', 'none');
colormap(parula);
colorbar;
grid on;
xlabel('Частота несущей f, МГц');
ylabel('Температура T, °C');
zlabel('Радиус соты R, км');
title('Зависимость радиуса соты от частоты и температуры (по Hata)');
view(135, 30);
saveas(fig4, fullfile(img_dir, 'fig4_range_vs_temp_freq.png'));