# Battery Tester

- Constant Current load (analog control loop MOSFET, OpAmp, current sense feedback loop)
- Low-side (simpler) versus high-side current sense
- Constant-current discharge
- Measure battery voltage
- Measure discharge current
- Cut-off voltage
- Temperature sensing
- Discharge profiles
- Reverse polarity protection
- Input fuse

- target common chargers/banks: 5/9/12/15/20 V, up to 3 A (standard power range)
- current-sense IC
- TO-247 (or similar) MOSFET chosen for DC SOA
- <https://jasper.sikken.nl/electronicload/index.html>
  - Single MOSFET, low-side sense
- <https://www.smbaker.com/raspberry-pi-controlled-dc-load>
  - web server that can be used to operate the project from a desktop PC or a mobile device
  - 3 MOSFETs in parallel
- [EEVblog #102 - DIY Constant Current Dummy Load for Power Supply and Battery Testing](https://www.youtube.com/watch?v=8xX2SVcItOA)
- [EEVblog 1688 - Constant Current Sources EXPLAINED + DEMO](https://www.youtube.com/watch?v=xGwnAH_qvto)
- [Great Scott DIY Adjustable Constant Load (Current & Power)](https://www.youtube.com/watch?v=VwCHtwskzLA)
  - MOSFET: IRFZ44N
  - Current Sense IC: AC712
- <https://www.mouser.com/pdfdocs/DC_Electronic_Load_Application_Note.pdf>
- IXTH75N10L2 linear FET, IRFP250N
