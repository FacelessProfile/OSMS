English | [Русский](README.ru.md)

# Lab 5. Cyclic Redundancy Check (CRC)

**Variant:** 25 (`G(x) = x^7 + x^3 + x^2 + x + 1`, `10001111`, CRC length `7` bits)

Modulo-2 polynomial division CRC encoder/verifier in C++, single-bit distortion test, AWGN channel error detection test, and direct C++ to MATLAB MEX benchmarking of CRC processing delay vs CRC length.

## Parameters

- Generator polynomial: `G = 10001111` (`n = 8` bits, CRC length `M = 7` bits)
- Short packet length: `N = 20 + 25 = 45` bits (`52` bits with CRC)
- Long packet length: `N = 250` bits (`257` bits with CRC)
- AWGN channel test: `sigma = 0.5`
- Processing delay benchmark (MATLAB + MEX): CRC sizes `1..32` bits, packet sizes `250 B` (`2000` bits) and `1000 B` (`8000` bits), `10000` runs per point (geometric mean)

## Results

- Error-free transmission for both `N = 45` and `N = 250` bits yields zero receiver remainder (`0000000`).
- Exhaustive single-bit distortion loop across all `257` bit positions: **257 / 257 detected, 0 missed** (100% single-bit error detection).
- AWGN channel test (`sigma = 0.5`): 8 actual bit flips occurred, receiver remainder `1011000` -> error detected.
- MATLAB MEX benchmark confirms linear `O(N * L_CRC)` processing delay scaling: `~15..43 us` for `250 B` packets and `~50..162 us` for `1000 B` packets (~4x ratio).

## Files

- [`crc.cpp`](crc.cpp) - C++ CRC encoder/checker, 257-bit single-error test, and AWGN channel check
- [`crc_mex.cpp`](crc_mex.cpp) - thin MATLAB MEX wrapper calling `generateData` and `calcCRC` directly from `crc.cpp`
- [`plot_crc_delay.m`](plot_crc_delay.m) - MATLAB script compiling `crc_mex.cpp`, running 10000-trial geometric mean timing sweep over CRC sizes `1..32` bits, and saving `crc_delay.png`

## Run

```bash
g++ -O2 crc.cpp -o crc
./crc
```

In MATLAB (from `lab5/`):

```matlab
run('plot_crc_delay.m')
```
