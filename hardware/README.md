# Hardware Architecture & Electronics Package

**Autonomous High-Speed Closed-Loop Line Following Robot**  
**Target Microcontroller:** STM32F446RET6 (180 MHz ARM Cortex-M4F)

---

## 1. Overview & Engineering Documentation

The electronics subsystem employs a modular two-board architecture designed for high electrical noise immunity, ultra-low center of gravity, and rapid pit-lane serviceability:

1. **[Complete Schematic Design Guide](SCHEMATIC_GUIDE.md)**:
   - Detailed circuit schematics, power distribution architecture, and passive component selection equations.
   - Microcontroller core decoupling, HSE crystal load calculations, and NRST reset debouncing.
   - TB6612FNG H-bridge interface with hardware-tied `STBY` and ultrasonic 20 kHz PWM mapping.
   - Front sensor array with active AutoDifferential ambient light rejection (2N7002 low-side MOSFET switch).
   - Pinout allocation table and complete signal netlist mapping.

2. **[Production PCB Layout & Routing Guide](PCB_ROUTING_GUIDE.md)**:
   - 4-layer FR4 stackup specifications (JLCPCB JLC04161H-7628 process).
   - High-current motor supply routing ($> 40\text{ mil}$ traces) and star ground isolation.
   - TPS54302 buck converter critical loop area minimization ($< 5\text{ mm}$ loop).
   - ADC analog signal line shielding ($3W$ spacing rule, contiguous Layer 2 ground reference).
   - Optical sensor alignment ($7.50\text{ mm} \pm 0.05\text{ mm}$ pitch) with matte black solder mask.
   - Manufacturing DFM rules (minimum trace/space, annular rings, drill hole sizes).

3. **Production Bill of Materials (BOM)**:
   - **[`jlcpcb_bom.csv`](jlcpcb_bom.csv)**: Consolidated system BOM with component values, packages, and verified LCSC part numbers.
   - **[`motherboard/motherboard_bom.csv`](motherboard/motherboard_bom.csv)**: Motherboard specific component list.
   - **[`sensor_blade/sensor_blade_bom.csv`](sensor_blade/sensor_blade_bom.csv)**: Front Sensor Blade component list.

---

## 2. Modular Board Breakdown

```
hardware/
├── SCHEMATIC_GUIDE.md            # Comprehensive circuit design & component calculations
├── PCB_ROUTING_GUIDE.md          # 4-layer PCB stackup, trace widths, & DFM rules
├── jlcpcb_bom.csv                # Complete consolidated LCSC manufacturing BOM
│
├── motherboard/                  # Board 1: Power, Compute, Actuation & Telemetry
│   ├── README.md                 # Motherboard technical specifications
│   └── motherboard_bom.csv       # Motherboard component listing & LCSC part numbers
│
└── sensor_blade/                 # Board 2: Front Optical Sensor Array (8× QRE1113GR)
    ├── README.md                 # Sensor Blade optical specifications & pinout
    └── sensor_blade_bom.csv      # Sensor Blade component listing & LCSC part numbers
```

---

## 3. Key Specifications

| Parameter | Main Motherboard (Board 1) | Front Sensor Blade (Board 2) |
| :--- | :--- | :--- |
| **Dimensions** | $80.0\text{ mm} \times 50.0\text{ mm}$ | $65.0\text{ mm} \times 16.0\text{ mm}$ |
| **Layer Count** | 4-Layer FR4 ($1.6\text{ mm}$ thickness) | 2-Layer FR4 ($1.0\text{ mm}$ thickness) |
| **Copper Weight** | $1\text{ oz}$ Outer / $1\text{ oz}$ Inner | $1\text{ oz}$ Outer |
| **Solder Mask** | Matte Black or Green | **Matte Black ONLY** (prevents optical glare) |
| **Key ICs / Sensors** | STM32F446RET6, TB6612FNG, TPS54302, AP2112K | 8× Vishay QRE1113GR, 2N7002 N-MOSFET |
| **Operating Voltage**| 3S LiPo ($11.1\text{V}\text{--}12.6\text{V}$ Fused) | $+3.3\text{V}$ Clean Logic Supply |
| **Interconnect** | 11-Pin JST-PH 2.0mm Header (`J3`) | 11-Pin JST-PH 2.0mm Header (`J7`) |
