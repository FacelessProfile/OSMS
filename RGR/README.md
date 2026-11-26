English | [Русский](README.ru.md)

# Course Project (RGR). End-to-End Digital Transmission Link in MATLAB

**Variant:** 25 (Gold sequence from Lab 4 + CRC-7 polynomial from Lab 5)

Full transceiver simulation in MATLAB combining ASCII encoding/decoding, CRC-7 error detection, 31-bit Gold sequence frame synchronization, amplitude modulation (`N` samples per bit), unknown frame offset, AWGN channel, correlation receiver, threshold symbol demodulation, FFT spectral analysis, and `parfor` Monte Carlo performance evaluation (`BLER`, `BER`, normalized sync peak vs `sigma`).

## Parameters

- Input message: `Nikita Shalamov` (`15` ASCII chars -> `L = 120` bits)
- CRC-7 polynomial (Lab 5, Var. 25): `poly = [1 0 0 0 1 1 1 1]`, `M = 7` bits (`CRC = 0101100`)
- Synchronization preamble (Lab 4, Var. 25): `31`-bit Gold sequence (`x1 = 25`, `y1 = 1`, `G = 31` bits)
- Total frame length: `G + L + M = 158` bits
- Samples per bit: `N = 8` (also compared with `N = 4`, `N = 16` for spectra, and `N = 2` for Monte Carlo BLER/BER)
- Sampling frequency: `fs = 1000` Hz

## Results

- With `shift = 420` and `sigma = 0.25`, the correlation receiver (`find_sync` with zero-mean Gold reference) detects frame start at exact sample `421`, threshold demodulation (`P = N/2 = 4`) recovers all bits, CRC remainder is `0000000`, and `Nikita Shalamov` is decoded without errors.
- At `sigma = 0.50`, frame sync remains locked at sample `421` while CRC detects bit errors in the payload.
- FFT spectral comparison confirms uniform AWGN noise floor and inverse scaling between symbol duration and main-lobe bandwidth (`±250 Hz` for `N = 4`, `±125 Hz` for `N = 8`, `±62.5 Hz` for `N = 16`).
- Parallel Monte Carlo simulation (`5000` runs per `sigma` via `parfor`) compares `N = 8` vs `N = 2`: reducing `N` by 4x shifts the `BLER` curve left by 2x (`BLER = 0.5` at `sigma ≈ 0.27` vs `0.55`), matching the theoretical `sqrt(8/2) = 2` noise-averaging gain.

## Files

- [`rgr.m`](rgr.m) - standalone MATLAB script implementing steps 1–13 of the RGR and `parfor` Monte Carlo `BLER`/`BER`/correlation peak analysis
- [`RGR_guide.md`](RGR_guide.md) - detailed Russian walkthrough of every line of code and defense Q&A

## Run

In MATLAB (from `RGR/`):

```matlab
run('rgr.m')
```
