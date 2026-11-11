# Foundations of Mobile Network Systems (OSMS) - Practical Labs & Course Project

[🇬🇧 English](README.md) | [🇷🇺 Читать на русском](README.ru.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![MATLAB Compatibility](https://img.shields.io/badge/MATLAB-R2019b%2B-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![C++](https://img.shields.io/badge/C%2B%2B-11%2B-00599C.svg)](https://en.cppreference.com/)

A clean, engineering-grade repository containing computational coursework, simulations, and algorithms for the **Foundations of Mobile Network Systems (OSMS)** curriculum (SibSUTI).

The repository combines a **Dual-Track Structure** for early scripts and dedicated lab directories with detailed bilingual READMEs:
- **`labs_en/`** & **`labs_ru/`**: standalone MATLAB/Octave scripts for both English clean code and Russian grading tracks (`lab01_sampling_and_fourier.m` / `lab01.m`).
- **`lab1/`, `lab2/`, `lab4/`**: per-lab bilingual documentation (`README.md` / `README.ru.md`) and lab-specific MATLAB and C++ sources (`lab4/lab4.m`, `lab4/gold.cpp`).

---

## Curriculum: Practical Works & Course Project (RGR)

| No. | README | Code | Topics & Core Algorithms | Status |
| :-: | :--- | :--- | :--- | :-: |
| **01** | [lab1/README.md](lab1/README.md)<br>([RU](lab1/README.ru.md)) | [`lab01_sampling_and_fourier.m`](labs_en/lab01_sampling_and_fourier.m)<br>[`lab01.m`](labs_ru/lab01.m) | **Time & Frequency Signal Representations. Fourier Transform. Sampling.** *(Var. 26)*<br>• Synthesis of $y(t) = \cos(28\pi t) + \cos(42\pi t)$ & Nyquist boundary check ($F_d = 42$ Hz vs. $168$ Hz)<br>• Direct Discrete Fourier Transform (DFT) and IDFT vs. `fft` / `ifft`<br>• Audio decimation (10x), spectral aliasing analysis & linear reconstruction<br>• Uniform ADC quantization distortion analysis (3..16 bits) | `Completed` |
| **02** | [lab2/README.md](lab2/README.md)<br>([RU](lab2/README.ru.md)) | — *(results & steps in README)* | **Cellular Radio Coverage Design. Propagation Models. Link Budgets.** *(Var. 26)*<br>• LTE 1.8 GHz link budgets: $MAPL_{UL} = 126.70$ dB, $MAPL_{DL} = 144.09$ dB (UL-limited)<br>• Path loss modeling: FSPM, UMiNLOS, COST 231 Hata, Walfish-Ikegami (LOS/NLOS)<br>• Macrocell network dimensioning (100 km², Hata): $R = 0.599$ km, 143 BS sites<br>• Indoor network dimensioning (4 km², UMiNLOS): $R = 450$ m, 11 3-sector sites<br>• Thermal noise sensitivity sweep over $-40\dots+60^\circ\text{C}$ and $1500\dots2000$ MHz | `Completed` |
| **03** | — | — | **Correlation of Discrete Signals.**<br>• Unnormalized correlation $\sum x_n y_n$ and normalized correlation coefficient<br>• Shift-based similarity detection in C++ and MATLAB<br>• Role of correlation peaks in slot and frame synchronization | `Manual / Report` |
| **04** | [lab4/README.md](lab4/README.md)<br>([RU](lab4/README.ru.md)) | [`lab4.m`](lab4/lab4.m)<br>[`gold.cpp`](lab4/gold.cpp) | **Correlation Properties of Synchronization Sequences (Gold Codes).** *(Var. 25)*<br>• Odd-group LFSR Gold sequence generator ($N = 31$, scheme 4.5, $x_1 = 25$, $y_1 = 1$)<br>• Cyclic ACF table (sidelobes $\{-0.03,\ 0.10,\ 0.23\}$) and cross-correlation $R_{12} = -0.10$<br>• Automated Golomb 3-postulate verification (`autocheck`) with CLI input support<br>• MATLAB comparison of cyclic binary ACF vs. `xcorr(..., 'normalized')` and `autocorr()` | `Completed` |
| **05** | — | — | **Cyclic Redundancy Check (CRC).**<br>• Polynomial modulo-2 division for transport-block error detection<br>• Generator polynomials, remainder calculation, and syndrome verification | `Planned` |
| **RGR** | — | — | **Course Project: End-to-End Transceiver Simulation Under Noise and Interference.**<br>• Full digital communications link: pseudo-random bit generation & FEC coding<br>• Digital modulation (BPSK / QPSK / QAM) and pulse-shaping filters<br>• Discrete AWGN and multipath channel simulation<br>• Matched filtering, symbol detection, and empirical BER vs. $E_b/N_0$ curves | `Planned` |

> **Summary of Completed Labs:** **Lab 1** verifies critical vs. oversampled discretization, manual DFT, decimation aliasing, and 3–16 bit ADC quantization ([lab1/README.md](lab1/README.md)); **Lab 2** establishes LTE 1.8 GHz UL/DL budgets and sizes macro/indoor deployments with COST 231 Hata and UMiNLOS ([lab2/README.md](lab2/README.md)); **Lab 4** implements $N=31$ Gold sequences in C++ and MATLAB, validates Golomb postulates via `autocheck`, and explains cyclic vs. aperiodic ACF behavior ([lab4/README.md](lab4/README.md)).

---

## How to Run

Open MATLAB/Octave in the repository directory, or compile the C++ program for Lab 4:

```matlab
% Run Practical Work 1
run('labs_ru/lab01.m');
% Or
run('labs_en/lab01_sampling_and_fourier.m');

% Run Practical Work 4
run('lab4/lab4.m');
```

```bash
# Build and run Lab 4 Gold sequence analyzer (C++)
g++ -O2 lab4/gold.cpp -o gold
./gold
./gold 0001100001001100010010101000000
```

---

## Repository Design Principles

1. **Zero Binary Clutter (Code & Docs Only)**:
   - No audio binaries (`*.wav`, `*.ogg`, `*.mid`), compiled executables, or PDF reports are tracked in Git.
   - Strict [`.gitignore`](.gitignore) prevents temporary MATLAB and LaTeX build artifacts from entering version control.

2. **Standalone Execution**:
   - Lab scripts generate synthetic signals or sequences programmatically and run out of the box without external asset files.

---

## License

This project is licensed under the [MIT License](LICENSE).
