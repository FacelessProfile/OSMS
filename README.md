# Foundations of Mobile Network Systems (OSMS) - Practical Labs & Course Project

[🇬🇧 English](README.md) | [🇷🇺 Читать на русском](README.ru.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![MATLAB Compatibility](https://img.shields.io/badge/MATLAB-R2019b%2B-orange.svg)](https://www.mathworks.com/products/matlab.html)

A clean, engineering-grade repository containing computational coursework, simulations, and algorithms for the **Foundations of Mobile Network Systems (OSMS)** curriculum.

The repository features a **Dual-Track Structure**:
- **`labs_en/`**: - clean MATLAB scripts with descriptive identifiers, mathematical docstrings, and standard two-digit naming (`lab01_sampling_and_fourier.m`).
- **`labs_ru/`**: - tandalone scripts aligned with university guidelines, task numbering (`TASK 1..13`), and Russian comments for grading.

Every assignment is implemented as a **fully self-contained single-file MATLAB script** with embedded algorithms and zero external toolbox dependencies.

---

## Curriculum: Practical Works & Course Project (RGR)

| No. | English Track (`labs_en/`) | Russian Track (`labs_ru/`) | Topics & Core Algorithms | Status |
| :-: | :--- | :--- | :--- | :-: |
| **01** | [`lab01_sampling_and_fourier.m`](labs_en/lab01_sampling_and_fourier.m) | [`lab01.m`](labs_ru/lab01.m) | **Time & Frequency Signal Representations. Fourier Transform. Sampling.**<br>• Harmonic signal synthesis & Nyquist-Shannon critical sampling boundary ($F_d = 42$ Hz vs. 168 Hz)<br>• Direct Discrete Fourier Transform (DFT) and Inverse DFT (IDFT) algorithms<br>• Bandlimited analog signal reconstruction<br>• Acoustic decimation (10x) and spectral aliasing analysis<br>• Uniform ADC quantization error analysis (3..16 bits)<br>• Speech DSP vocoder and harmonic tone generation | `Completed` |
| **02** | `lab02_radio_coverage_and_link_budget.m` | `lab02.m` | **Cellular Radio Coverage Design. Propagation Models. Link Budget Calculations.**<br>• Empirical path loss modeling (Okumura-Hata, COST 231, 3GPP UMa/UMi)<br>• Cell radius and base station coverage area calculation<br>• Downlink (DL) and Uplink (UL) radio link budget estimation<br>• Shadow fading fade margin and building penetration loss compensation | `Planned` |
| **03** | `lab03_synchronization_and_random_access.m` | `lab03.m` | **Terminal & Base Station Synchronization. Random Access Procedure (RACH).**<br>• Primary and Secondary Synchronization Signals (PSS / SSS), Physical Cell ID (PCI) detection<br>• Random Access Channel (RACH) preamble transmission procedure<br>• Zadoff-Chu sequence generation and correlation detection<br>• Timing Advance (TA) estimation for round-trip propagation delay compensation | `Planned` |
| **04** | `lab04_system_information_and_power_control.m` | `lab04.m` | **System Information (SIBs). PLMN Networks. Uplink Power Control.**<br>• Master Information Block (MIB) and System Information Blocks (SIB1, SIB2) broadcast<br>• Cellular network identification: PLMN ID, MCC, MNC, Tracking Area Code (TAC)<br>• User Equipment (UE) transmit power control algorithms in the UL channel<br>• Open-loop and closed-loop path loss compensation models | `Planned` |
| **05** | `lab05_network_registration_and_handover.m` | `lab05.m` | **Network Registration. AAA. Call Setup. Paging. Mobility & Handover.**<br>• Initial Attach Procedure and network signaling flow<br>• Authentication, Authorization, and Accounting (AAA / AKA)<br>• Mobile-terminated paging and End-to-End Call Setup procedures<br>• RRC state transitions (IDLE vs. CONNECTED) and seamless Handover mechanisms | `Planned` |
| **RGR** | `rgr_noise_resilient_transceiver.m` | `rgr.m` | **Course Project: End-to-End Transceiver Simulation Under Noise and Interference.**<br>• Full digital communications link: pseudo-random information bit stream generation<br>• Forward Error Correction (FEC) channel coding and decoding<br>• Digital modulation (BPSK / QPSK / QAM) and pulse-shaping filters<br>• Discrete channel model with Additive White Gaussian Noise (AWGN) and multipath interference<br>• Optimal receiver design, matched filtering, symbol decisions, and empirical Bit Error Rate (BER vs. $E_b/N_0$) analysis | `Planned` |

---

## How to Run

Open MATLAB, navigate to the repository directory, and execute either track directly:

```matlab
% Run Practical Work 1
run('labs_ru/lab01.m');
% Or
run('labs_en/lab01_sampling_and_fourier.m');
```

---

## Repository Design Principles

1. **Zero Binary Clutter (Code Only)**:
   - No audio binaries (`*.wav`, `*.ogg`, `*.mid`) or compiled PDF reports are tracked in Git.
   - Algorithms generate synthetic acoustic multi-harmonic test signals dynamically if external audio assets are absent.
   - Strict [`.gitignore`](.gitignore) prevents temporary MATLAB files (`*.asv`, `*.bak`) from entering version control.

2. **Self-Contained Single-File Execution**:
   - Every script runs out of the box via single-click execution (`F5`).
   - Helper algorithms are localized at the bottom of each script.

---

## License

This project is licensed under the [MIT License](LICENSE).
