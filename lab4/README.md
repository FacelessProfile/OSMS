English | [Русский](README.ru.md)

# Lab 4. Correlation Properties of Synchronization Sequences

**Variant:** 25 (odd group number - LFSR scheme 4.5)

Gold sequence generation in C++ and MATLAB, cyclic vs aperiodic autocorrelation analysis, cross-correlation calculation, and automated Golomb randomness verification.

## Parameters

- Period: `N = 2^5 - 1 = 31` (`5`-bit registers)
- First Gold sequence (`seq1`): `x1 = 25` (`11001`), `y1 = 1` (`00001`)
- Second Gold sequence (`seq2`): `x2 = 26`, `y2 = 27`

## Results

- Cyclic autocorrelation of `seq1` has main peak `R(0) = 1.00` and three sidelobe levels: `{-0.03, 0.10, 0.23}`.
- Zero-shift cross-correlation between `seq1` and `seq2`: `R_12 = -0.10`.
- Demonstrated why MATLAB `autocorr()` and bipolar `xcorr(..., 'normalized')` differ from cyclic binary correlation: without circular bit wrap-around, overlap decreases with lag `tau` and sidelobes decay toward zero.
- Added `autocheck` verifying balance, run distribution, and shift correlation (Golomb's three postulates).

## Files

- [`gold.cpp`](gold.cpp) - C++ generator, cyclic ACF table, `R_12`, and `autocheck` (accepts an optional binary string CLI argument)
- [`lab4.m`](lab4.m) - MATLAB script generating Gold sequences, comparing cyclic ACF with `xcorr(..., 'normalized')` and `autocorr()`, and plotting comparison graphs

## Run

```bash
g++ -O2 gold.cpp -o gold
./gold
./gold 0001100001001100010010101000000
```

In MATLAB:

```matlab
run('lab4.m')
```
