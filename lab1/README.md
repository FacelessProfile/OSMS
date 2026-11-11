English | [Русский](README.ru.md)

# Lab 1. Time and Frequency Domains. Fourier Transform. Sampling

**Variant:** 26

Sampling theorem check, manual DFT/IDFT vs built-in FFT, spectral aliasing under decimation, and uniform ADC quantization in MATLAB/Octave.

## Parameters

- Signal: `y(t) = cos(28*pi*t) + cos(42*pi*t)` (`f1 = 14 Hz`, `f2 = 21 Hz`, fundamental `f = 7 Hz`)
- Sampling rates: `F_d = 42 Hz` (Nyquist boundary) and `168 Hz` (`4 * F_d`)
- Audio decimation factor: `10x`
- ADC resolution sweep: `3` to `16` bits

## Results

- Sampled the two-tone signal at `42 Hz` and `168 Hz`: `42 Hz` preserves only the boundary frequency content without waveform shape, while `168 Hz` retains the envelope.
- Implemented direct DFT/IDFT sums and confirmed numerical agreement with `fft` and `ifft`.
- Downsampled an audio recording by `10x`, observing high-frequency aliasing in the spectrum, followed by linear interpolation reconstruction.
- Evaluated quantization error and spectral distortion across `3–6 bit` and up to `16 bit` uniform quantizers.

## Files

- [`labs_en/lab01_sampling_and_fourier.m`](../labs_en/lab01_sampling_and_fourier.m) - English script
- [`labs_ru/lab01.m`](../labs_ru/lab01.m) - Russian script

## Run

```bash
octave --no-gui labs_en/lab01_sampling_and_fourier.m
```
