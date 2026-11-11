English | [Русский](README.ru.md)

# Lab 2. Radio Coverage Planning. Propagation Models. Link Budgets

**Variant:** 26

Calculation of uplink and downlink LTE 1.8 GHz radio budgets, path loss modeling across propagation environments, cell radius dimensioning for macro and indoor networks, and sensitivity analysis over ambient temperature and carrier frequency.

## What Was Done

1. **Uplink (UL) and Downlink (DL) Link Budget Calculation:**
   - Evaluated receiver thermal noise power (`ThermalNoise = -174 + 10*log10(BW)`) for `BW_UL = 10 MHz` (`-104.00 dBm`) and `BW_DL = 20 MHz` (`-100.99 dBm`).
   - Computed receiver sensitivities (`NF + ThermalNoise + ReqSINR`): `-97.60 dBm` at BS (`NF = 2.4 dB`, `SINR = 4 dB`) and `-92.99 dBm` at UE (`NF = 6.0 dB`, `SINR = 2 dB`).
   - Calculated Maximum Allowable Path Loss (`MAPL`) accounting for feeder/TMA/jumper losses (`2.9 dB`), BS antenna gain (`21 dBi`), `2x2 MIMO` gain (`3 dB`), penetration margin (`15 dB`), and interference margin (`1 dB`):
     - `MAPL_UL = 126.70 dB`
     - `MAPL_DL = 144.09 dB`
   - Confirmed a `17.39 dB` link asymmetry: because UE transmit power (`24 dBm`) is significantly lower than BS transmit power (`46 dBm`), cell range is strictly **uplink-limited**.

2. **Propagation Model Comparison (`d = 0.01..10 km`, `f = 1.8 GHz`):**
   - Implemented and compared path loss curves `PL(d)` in MATLAB for:
     - **FSPM** (Free Space Path Loss Model)
     - **UMiNLOS** (Urban Micro Non-Line-of-Sight)
     - **COST 231 Hata** (Urban macrocell, piecewise slope for `d < 1 km` and `d >= 1 km`, `h_BS = 30 m`, `h_ms = 1.5 m`)
     - **COST 231 Walfish-Ikegami** (both LOS and NLOS with rooftop height `20 m`, street width `20 m`, building spacing `40 m`, orientation angle `90°`)

3. **Cell Radius & Site Count Dimensioning:**
   - **Macro network (`100 km²`, COST 231 Hata):** intersecting `PL(d)` with `MAPL_UL` and `MAPL_DL` yields `R_UL = 0.599 km` and `R_DL = 2.153 km`. Using the limiting radius `R = 0.599 km`, one 3-sector site covers `S_site = 1.95 * R^2 = 0.6997 km²`, requiring **143 base stations**.
   - **Indoor / microcell network (`4 km²`, UMiNLOS):** intersections yield `R_UL = 450.0 m` and `R_DL = 1339.0 m`. Using `R = 450.0 m` (`0.3949 km²` per 3-sector site), coverage requires **11 three-sector sites** (omnidirectional access point area `pi * R^2` was also evaluated).

4. **Temperature and Carrier Frequency Sweep:**
   - Replaced the room-temperature constant (`-174 dBm/Hz`) with `N = k * T * BW` across `T = -40..+60 °C` and swept `f = 1500..2000 MHz` under `COST 231 Hata`, plotting the 3D surface `R(f, T)` to confirm that both rising temperature (higher thermal noise) and higher carrier frequency reduce cell radius.

## Summary Results

| Parameter | Uplink (UL) | Downlink (DL) | Unit |
|---|---:|---:|---|
| Channel bandwidth (`BW`) | 10.0 | 20.0 | MHz |
| Transmit power (`TxPower`) | 24.0 | 46.0 | dBm |
| Thermal noise (`ThermalNoise`) | -104.00 | -100.99 | dBm |
| Noise figure (`NoiseFigure`) | 2.40 | 6.00 | dB |
| Required `SINR` | 4.00 | 2.00 | dB |
| Receiver sensitivity (`RxSens`) | -97.60 | -92.99 | dBm |
| **Max allowable path loss (`MAPL`)** | **126.70** | **144.09** | **dB** |
| Macrocell radius (`COST 231 Hata`) | **0.599** | 2.153 | km |
| Indoor cell radius (`UMiNLOS`) | **450.0** | 1339.0 | m |
| **Required sites (3-sector)** | **143** (`100 km²`) | **11** (`4 km²`, indoor) | sites |
