# RF Comb Generator

An RF Comb Generator generates RF spurs over wide bandwidth by intentionally creating harmonics of an input signal. Comb generators are frequently used in test equipment calibration.

The goal of this project is to exercise the input of a HP 4195a Network / Spectrum Analyzer (100 kHz to 500 MHz)

## Applications

- Test Equipment
- Built in Test
  - Test Spectrum Analyzers, receivers, ADCs

## Goals

- checking that the receiver is alive and coherent across band.

## Resources

- [Simple Comb Generator Design for SWaP-Constrained Applications (MIT Lincoln Laboratory)](https://apps.dtic.mil/sti/tr/pdf/AD1034739.pdf)

## Requirements

- Input Signal
  - Impedance: 50 Ohms
  - Frequency (f0): 4 MHz
  - Minimum Power Level: +0 dBm
  - Maximum Power Level: +20 dBm continuous
  - Coupling: AC Coupled (SMA connector followed by DC block)
  - Connector: SMA
  - Waveform Shape (square, sine)
  - Source Type (temperature controlled, Crystal)
- Frequency Range: f0-1 GHz
- Integrated frequency generator (as opposed to external). Perhaps an external should be provided as a first step. Accept BNC or SMA input. SMA has smaller footprint.

## Design

- Reference clock/oscillator (internal versus external)
- Input DC block
- Input pad (3, 6, 10 dB selectable)
- Input LPF

### Component Selection

#### Step Recovery Diode

- Peak Reverse Voltage (PRV or VRRM) is mostly a reliability / survivability spec,
not a primary performance spec for SRD comb generation.

## Operation

- Even harmonics are zero

## Material Required

- SMA to BNC cables
- SMA to BNC adapters
- Edge mount SMA
- Oscillator
- N↔SMA adapter/cable
- Step Recovery Diode
  - [MAVR-044769-12790T](https://www.digikey.com/en/products/detail/macom-technology-solutions/MAVR-044769-12790T/12629365)
- .01μF bypass capacitor
