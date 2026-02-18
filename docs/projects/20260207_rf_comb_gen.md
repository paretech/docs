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
- SMA to BNC adapters ()
- Screw on banana plugs (power supply to dupont adapter)
- SMA Edge mount (Molex 0732511153, $3.86)
  - 1.6 mm recommended PCB Thickness
  - Existing kicad footprint
- Oscillator
- N↔SMA adapter/cable (HP 4195A)
- Step Recovery Diode
  - [MAVR-044769-12790T](https://www.digikey.com/en/products/detail/macom-technology-solutions/MAVR-044769-12790T/12629365)
    - Package SC-79 goes by JEDEC SOD-523 in KiCad and other contexts
- .01μF bypass capacitor
- 10 MHz Osc
  - XLH736010.000000I

## Schematic Capture

- Schematics cache symbol copies. Updating the library does not automatically update placed symbols.
- Create custom symbols in project first. Promote them to higher scopes later after they are proven.
- Create new symbols as small as possible. Try to use vendor pin names when possible, hopefully they are short.
- If you want symbol update to work, don't change symbol name...
- Place power port on generic connector pins to satisfy ERC
- Ground pins on ICs/modules should be Power input, not Power output.
- Don't make per instance sybmol changes. They are hard to debug. Either update the root symbol or explicitely specify with flags (e.g., PWR_FLAG)
- PWR_FLAG can be applied to a NET to tell ERC where power comes from (e.g., on a connector pin)
- Use "power_input" for ground pins on active parts and "passive" for connectors and mechanical.
- Use CTRL+4 to select all segments of a connected wire in schematic editor.
- If you want maximum hand-solder comfort without editing footprints, increase solder-mask expansion slightly (global board setting).
- The diode uses SC-79 package, in KiCad this is equivalent to JEDEC SOD-523.
- <https://jlcpcb.com/capabilities/pcb-capabilities>

## PCB

Define PCB

- 2-layer FR-4
  - Note that JLCPCB provides impedance control for even quantity layers 4 and above (not 2-layer)
- 1.6 mm thick
- Full bottom ground plane
- Routing
  - Short trace
  - Straight into SMA
  - Ground vias near connector
  - Decoupling cap tight to XO

Assign Footprints to schematic components

- Critical Components First (connectors, power, ICs)

- Created footprint for XLH Oscillator, everything else from lib.
- <https://www.protoexpress.com/blog/pcb-footprint-creation-allegro-altium-designer-kicad/>
- See [IPC-7351](https://www.protoexpress.com/blog/features-of-ipc-7351-standards-to-design-pcb-component-footprint/) for SMD footprint designs and land pattern standards.
- Create a single pad, then use
- CTRL+T to "Create Array" of pads
- Draw dimensions on user.Drawings layer to confirm layout
- Warning: Dimensions drawn in foot print editor are not anchored to shapes.
- Add actual component outline to F.Fab
- Add pin 1 designator to F.Fab and F.Silkscreen
- Add enlarged and enclosed component outline to F.Courtyard. Courtyard should include everything (e.g., pads, silkscreen). Do not expand courtyard for pin 1 designator or reference designator.
- Use "Edit > Text and Graphic Properties" to batch edit line weights if created incorrectly
- Now that I'm done with new component, when I went to apply and searched JU6, there was already a JU6 in the core lib... Not sure why I didn't find earlier.

- layout
- From PCB Editor, F8 to update from schematic
- Define board stackup
- Board
  - Board: 25.0 × 25.0 mm
  - Mount holes: 4× M2.5 clearance (2.7 mm NPTH)
  - Hole centers: 3.0 mm inset from each edge
  - Hole coordinates: (3,3), (22,3), (3,22), (22,22)
- Use Netclasses!!! <https://www.youtube.com/watch?v=o34fSnf43bE>
- Coplanar WaveGUIDES CPWG have narrower tracewidths for 2-layer FR4 compared to microstripline
- <https://gitlab.com/kicad/libraries/kicad-footprints/-/merge_requests/1770>
- Arg

Picking Components

- Capacitors
  - NP0/C0G has the lowest dielectric absorption and the flattest capacitance vs frequency/voltage, so it behaves more like an ideal cap at RF.
  - Low ESR for DC Block
  - X7R for decoupling caps
  - c2: C0805C222K2GECTU (2.2nF)
  - c2: C0805C332J1GEC7210, C0805C102K5GACTU (3.3 nF, 1nF)
  - C1: C0805C100J5GACTU (10pF)
  - C3: C0603C103K5RACT (10 nF)
- Resistors
  - R1: 100R MCU08050C1000FP500
  - R2: 50R MCU0805PD4999DP500

### TODOs

[ ] Add thermal relief spikes to SMA edge connector ground pads
[ ] Connector silkscreen
[ ] Add power on LED
[ ] Add reverse polarity protection (Series Schottky diode or “Ideal diode” PFET)
[ ] Consider adding a 3.3VDC LDO regulator to accommodate 3.3-5VDC VIN
[ ] Refine board for impedance control
[ ] Remove solder mask from RF50 tracks
[ ] Test Point loop
    - <https://www.keyelco.com/userAssets/file/M65p55.pdf>
      - 5019 minature and there is a matching footprint in KiCad!

## Plugins to Explore

- Gerber to order
- Interactive HTML BOM
- Board to PDF
- Transform It
- Place Footprints
- Round tracks
- PCB Coil Generator
- Color Themes
- <https://github.com/easyw/RF-tools-KiCAD>
- <https://github.com/jsreynaud/kicad-action-scripts>
