# Production PCB Layout & Routing Guide

**Autonomous High-Speed Closed-Loop Line Following Robot**  
**Target Manufacturing:** JLCPCB / PCBWay 4-Layer FR4 Process  
**Applicability:** Main Motherboard ($80\text{ mm} \times 50\text{ mm}$) and Front Sensor Blade ($65\text{ mm} \times 16\text{ mm}$)

---

## 1. Board Geometry, Form Factors & Mechanical Keepouts

### 1.1 Main Motherboard ($80.0\text{ mm} \times 50.0\text{ mm}$)
* **Mounting Pattern**: 4× M3 clearance holes ($3.2\text{ mm}$ drill, $6.0\text{ mm}$ annular pad) located at $X = \pm 36.0\text{ mm}, Y = \pm 21.0\text{ mm}$ ($4.0\text{ mm}$ inset from each board edge).
* **Battery Through-Pocket**: Central rectangular through-slot ($58.0\text{ mm} \times 32.0\text{ mm}$) allowing the 3S LiPo battery pack to sit directly above the rear axle, lowering the center of gravity and minimizing polar yaw inertia.
* **Component Placement Zones**:
  - **Rear Zone**: Power entry (XT30-PW, reverse protection P-MOSFET, 3A fuse), 5V TPS54302 buck regulator, and 3.3V AP2112 LDO.
  - **Center-Left & Center-Right Zones**: TB6612FNG H-bridge driver, bulk $100\,\mu\text{F}$ capacitor, and JST-PH motor/encoder connectors (J4, J5).
  - **Forward Zone**: STM32F446RET6 MCU, 8 MHz crystal oscillator, SWD programming header (J2), and 11-pin sensor blade header (J3).
  - **Top/Periphery**: HC-05 Bluetooth female socket (J1), active buzzer (BZ1), status LED (D3), and user button (SW_USER).

### 1.2 Front Sensor Blade ($65.0\text{ mm} \times 16.0\text{ mm}$)
* **Mounting Holes**: 2× slotted M2.5 / M3 holes centered at $X = \pm 29.0\text{ mm}$ ($58.0\text{ mm}$ center-to-center) with $4.0\text{ mm}$ vertical slot travel for continuous ground clearance adjustment ($2.0\text{ mm}\text{--}4.0\text{ mm}$).
* **Solder Mask**: **Matte Black** (strictly mandatory to prevent stray infrared reflections and cross-channel optical glare).
* **Thickness**: $1.0\text{ mm}$ double-sided FR4 (reduces front cantilever mass and moment of inertia).

---

## 2. 4-Layer FR4 Stackup Strategy (Motherboard)

A standard JLCPCB JLC04161H-7628 ($1.6\text{ mm}$ thickness, $1\text{ oz}$ outer / $1\text{ oz}$ inner copper) stackup is specified:

```
┌────────────────────────────────────────────────────────────────────────┐
│ Layer 1: Top (F.Cu) - 1 oz (35 µm)                                     │
│  - High-speed digital signals (SWD, UART, Encoder inputs)              │
│  - High-current motor supply traces (VM, AO1/AO2, BO1/BO2)             │
│  - Component mounting pads and local bypass capacitors                 │
├────────────────────────────────────────────────────────────────────────┤
│ Dielectric 1: Prepreg 7628 (0.210 mm, εr ≈ 4.4)                        │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 2: Inner 1 (In1.Cu) - 1 oz (35 µm)                               │
│  - SOLID, UNBROKEN GROUND PLANE (0% cutouts, zero split planes)        │
│  - Provides low-impedance image return path for all Layer 1 traces     │
├────────────────────────────────────────────────────────────────────────┤
│ Dielectric 2: FR4 Core (1.065 mm, εr ≈ 4.5)                            │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 3: Inner 2 (In2.Cu) - 1 oz (35 µm)                               │
│  - SPLIT POWER PLANES:                                                 │
│    ├── Zone A: +12V Motor Rail (VM)                                    │
│    ├── Zone B: +5V System Rail (Buck output)                           │
│    └── Zone C: +3.3V Logic Rail (LDO output)                           │
├────────────────────────────────────────────────────────────────────────┤
│ Dielectric 3: Prepreg 7628 (0.210 mm, εr ≈ 4.4)                        │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 4: Bottom (B.Cu) - 1 oz (35 µm)                                  │
│  - Low-speed signals, non-critical interconnections                    │
│  - Secondary ground copper pour stitched with 5.0 mm via matrix        │
└────────────────────────────────────────────────────────────────────────┘
```

### Stackup Design Principles:
1. **Zero Ground Plane Splitting on Layer 2**: Never route signal traces or split planes on Layer 2. Any cut in the ground plane forces return currents to take long detour loops, creating substantial magnetic loop antennas and radiating EMI into the analog ADC lines.
2. **Immediate Power Plane Decoupling**: With Layer 2 (GND) and Layer 3 (Power) separated by the core, interplane capacitance provides high-frequency damping. Local bypass capacitors connect directly from Layer 1 to Layer 2 GND vias within $< 1.5\text{ mm}$.

---

## 3. High-Current & Motor Routing Rules

### 3.1 Trace Widths & Current Capacity
Based on IPC-2152 standards for $1\text{ oz}$ copper with $\Delta T \le 10^\circ\text{C}$:

| Net Name | Peak Current | Minimum Trace Width | Recommended Width | Routing Layer |
| :--- | :---: | :---: | :---: | :---: |
| **Battery In (XT30 $\to$ Fuse $\to$ Q1)** | $4.0\text{ A}$ | $1.2\text{ mm}$ ($48\text{ mil}$) | **$1.8\text{ mm}$ ($70\text{ mil}$)** | Layer 1 |
| **Motor Rail (VM $\to$ TB6612 Pins 13, 24)**| $3.0\text{ A}$ | $0.9\text{ mm}$ ($35\text{ mil}$) | **$1.5\text{ mm}$ ($60\text{ mil}$)** | Layer 1 + Layer 3 pour |
| **Motor Outputs (AO1, AO2, BO1, BO2)** | $1.5\text{ A}$ | $0.5\text{ mm}$ ($20\text{ mil}$) | **$0.8\text{ mm}$ ($32\text{ mil}$)** | Layer 1 |
| **+5V Buck Output $\to$ LDO & Loads** | $1.2\text{ A}$ | $0.4\text{ mm}$ ($16\text{ mil}$) | **$0.8\text{ mm}$ ($32\text{ mil}$)** | Layer 3 pour |
| **+3.3V Logic Rail** | $0.4\text{ A}$ | $0.25\text{ mm}$ ($10\text{ mil}$)| **$0.5\text{ mm}$ ($20\text{ mil}$)** | Layer 3 pour |
| **Signal Traces (ADC, GPIO, SPI, UART)**| $< 10\text{ mA}$| $0.15\text{ mm}$ ($6\text{ mil}$) | **$0.20\text{ mm}$ ($8\text{ mil}$)** | Layer 1 & Layer 4 |

### 3.2 Star Ground & Motor Ground Isolation
Motor switching generates significant ground bounce due to inductive flyback currents:
* **Star Point**: The negative terminal of the XT30 power connector (J6) is the single central star ground reference point.
* **Motor Ground**: The ground pins of the TB6612FNG (pins 3, 4, 9, 10) must return directly to the bulk capacitor $C_1$ ($100\,\mu\text{F}$) and the XT30 negative terminal through wide copper pours, completely isolated from the analog ADC ground.
* **Thermal Relief & Heat Sinking**:
  - Place a $3 \times 3$ grid of $0.3\text{ mm}$ drill vias with $0.6\text{ mm}$ annular rings directly beneath the TB6612FNG IC and its ground pins.
  - Connect these thermal vias to Layer 2 (GND) and Layer 4 bottom ground pour to dissipate motor driver heat during heavy braking.

---

## 4. Switching Power Supply (TPS54302 Buck) Layout

The TPS54302 switching regulator operates at $400\text{ kHz}$. Poor layout of this circuit is the #1 cause of ADC noise and microcontroller reset glitches.

```
       [ C_IN1, C_IN2 ] (2× 10µF 1206)
              │  (< 2mm trace to Pin 2)
              ▼
       ┌──────────────┐
       │   Pin 2: VIN │
       │  TPS54302    │── Pin 5: SW ───[ L1: 4.7µH Inductor ]───┬─── +5V VOUT
       │   Pin 1: GND │                                          │
       └──────┬───────┘                              [ C_OUT: 2× 22µF ]
              │                                                  │
       [ Star GND Via ]                                    [ GND Plane ]
```

### Strict Buck Layout Rules:
1. **Critical High di/dt Loop Minimization**:
   - The loop formed by $C_{IN} \to \text{Pin 2 (VIN)} \to \text{Internal High-Side FET} \to \text{Pin 5 (SW)} \to \text{Internal Low-Side FET} \to \text{Pin 1 (GND)} \to C_{IN}$ ground terminal must be kept as small as physically possible ($< 5\text{ mm}$ total loop area).
   - Place $C_2, C_3$ ($2\times 10\,\mu\text{F}$ 1206) immediately adjacent to pins 1 and 2 on Layer 1.
2. **Switching Node (SW) Copper Area**:
   - The copper trace connecting Pin 5 (`SW`), bootstrap capacitor $C_{25}$, and Inductor $L_1$ carries high $dv/dt$ ($12\text{V}$ transition in $< 10\text{ ns}$).
   - Make this trace **short and wide** (e.g. $1.0\text{ mm}$ wide, $< 4\text{ mm}$ long). Do not make it excessively large as excess copper acts as an E-field antenna radiating RF noise into the MCU.
3. **Feedback Trace Isolation**:
   - The feedback trace from $V_{OUT}$ to resistor divider $R_2/R_3$ into pin 4 (`FB`) must be routed **away from inductor L1 and switching node SW**.
   - Route the FB trace on Layer 4 or shielded beneath the Layer 2 ground plane.
   - Place $R_2$ and $R_3$ right next to Pin 4 (`FB`), not next to the inductor.

---

## 5. Analog & Sensor Signal Routing Rules

### 5.1 8-Channel ADC Signal Line Routing (PC0..PC5, PB0, PB1)
* **Contiguous Ground Reference**: Every analog trace (`S1_ADC` through `S8_ADC` and `VBAT_SENSE`) must route directly over the solid, unbroken ground plane on Layer 2. Never cross a split between power zones.
* **$3W$ Spacing Rule**: Spacing between adjacent analog signal traces must be $\ge 3\times$ the trace width:
  - Trace width: $W = 0.20\text{ mm}$ ($8\text{ mil}$).
  - Trace-to-trace spacing: $S \ge 0.60\text{ mm}$ ($24\text{ mil}$).
  - Prevents capacitive crosstalk between adjacent optical channels during high-speed DMA conversion sweeps.
* **Isolation from PWM Motor Lines**:
  - Maintain a minimum clearance of **$4.0\text{ mm}$** between the 20 kHz PWM motor traces (`PWMA`, `PWMB`) and the 8 analog sensor traces.
  - If crossing is unavoidable, cross at strict **$90^\circ$ right angles** on opposite outer layers with the Layer 2 ground plane sandwiched between them.

### 5.2 Battery Sensing Anti-Aliasing (PA4)
* Place filter capacitor $C_{10}$ ($100\text{ nF}$) within $< 2.0\text{ mm}$ of MCU pin 20 (`PA4`).
* Connect the ground terminal of $C_{10}$ and divider resistor $R_5$ directly to the MCU analog ground via a dedicated via into Layer 2.

---

## 6. Microcontroller & Oscillator Routing Rules

### 6.1 MCU Decoupling Placement (STM32F446RET6 LQFP-64)
* **Pin Pairs**: (19/18), (32/31), (48/47), (64/63).
* **Placement Priority**:
  - The $100\text{ nF}$ ceramic capacitor must be placed closer to the MCU pin than the via to the power plane.
  - Correct route order: `MCU VDD Pad` $\to$ `Capacitor Pad` $\to$ `Via to 3.3V Plane`.
  - Place capacitor ground pad directly adjacent to a via into Layer 2 GND.
* **$V_{CAP1}$ and $V_{CAP2}$ Pins (Pins 30 and 42)**:
  - Route short, wide traces ($0.4\text{ mm}$) to $2.2\,\mu\text{F}$ capacitors $C_{18}$ and $C_{19}$.
  - Ground pads of $C_{18}, C_{19}$ must via directly to the ground plane adjacent to MCU $V_{SS}$ pins.

### 6.2 8.000 MHz Crystal Oscillator (HSE) Routing
* **Location**: Place crystal $Y_1$ within $< 4.0\text{ mm}$ of pins 5 (`PH0/OSC_IN`) and 6 (`PH1/OSC_OUT`).
* **Symmetry**: Keep traces from crystal pads to MCU pads symmetrical in length ($\Delta L < 0.5\text{ mm}$) and parallel.
* **Guard Ring**: Surround the crystal and load capacitors ($C_{11}, C_{12}$) with a continuous ground trace tied to Layer 2 with multiple vias.
* **Under-Crystal Keepout**: Do not route any signal traces on Layer 1 or Layer 4 directly beneath the crystal body or load capacitors.

---

## 7. Front Sensor Blade Layout & Optical Alignment

```
               [ 7.5 mm Pitch ]
   ├── 7.5 mm ──┼── 7.5 mm ──┼── 7.5 mm ──┼── 7.5 mm ──┼── 7.5 mm ──┼── 7.5 mm ──┤
   ▼            ▼            ▼            ▼            ▼            ▼            ▼
 ┌────┐       ┌────┐       ┌────┐       ┌────┐       ┌────┐       ┌────┐       ┌────┐
 │ S1 │       │ S2 │       │ S3 │       │ S4 │       │ S5 │       │ S6 │       │ S7 │
 └────┘       └────┘       └────┘       └────┘       └────┘       └────┘       └────┘
 ◄────────────────────────────── 52.5 mm Total Optical Span ─────────────────────►
```

### Sensor Blade Layout Specifics:
1. **Precision Component Placement**:
   - All 8× Vishay `QRE1113GR` sensors must be placed with their optical centers exactly **$7.50\text{ mm} \pm 0.05\text{ mm}$** apart on a single horizontal axis.
   - Maintain uniform orientation across all 8 sensors (e.g. IR emitter on top, phototransistor on bottom).
2. **Current-Limiting Resistor Placement**:
   - Place the 8 ballast resistors $R_{EM1}\text{--}R_{EM8}$ ($100\,\Omega$) and 8 pull-up resistors $R_{PU1}\text{--}R_{PU8}$ ($10\text{ k}\Omega$) on the reverse side or directly above each sensor footprint to keep signal traces short ($< 3.0\text{ mm}$).
3. **Central Ground & Modulation Switch Placement**:
   - Place the `2N7002` MOSFET (`Q_GATE`) in the horizontal center of the sensor blade (between sensors S4 and S5).
   - This equalizes the cathode return trace lengths from all 8 emitter LEDs, ensuring identical optical emission intensity across the entire array.
4. **Connector Placement**:
   - Place header `J7` (JST-PH 11-pin right-angle) at the top edge of the board with pin 1 (+3.3V) and pin 2 (GND) positioned closest to the ribbon cable entry.

---

## 8. Manufacturing & DFM Design Rules (JLCPCB / PCBWay)

| Constraint / Rule | Specification | Minimum Value | Recommended Production Value |
| :--- | :--- | :---: | :---: |
| **Minimum Trace Width** | Signal traces | $0.127\text{ mm}$ ($5\text{ mil}$) | **$0.20\text{ mm}$ ($8\text{ mil}$)** |
| **Minimum Trace Clearance** | Copper-to-copper spacing | $0.127\text{ mm}$ ($5\text{ mil}$) | **$0.20\text{ mm}$ ($8\text{ mil}$)** |
| **High-Voltage Clearance** | 12V to 3.3V logic / GND | $0.25\text{ mm}$ ($10\text{ mil}$) | **$0.40\text{ mm}$ ($16\text{ mil}$)** |
| **Minimum Via Drill Hole** | Standard vias | $0.30\text{ mm}$ ($12\text{ mil}$) | **$0.30\text{ mm}$ ($12\text{ mil}$)** |
| **Minimum Via Diameter** | Standard vias | $0.50\text{ mm}$ ($20\text{ mil}$) | **$0.60\text{ mm}$ ($24\text{ mil}$)** |
| **Minimum Annular Ring** | Via annular ring width | $0.13\text{ mm}$ ($5\text{ mil}$) | **$0.15\text{ mm}$ ($6\text{ mil}$)** |
| **Copper to Board Edge** | Clearance from outline | $0.30\text{ mm}$ ($12\text{ mil}$) | **$0.50\text{ mm}$ ($20\text{ mil}$)** |
| **Solder Mask Clearance** | Expansion over pads | $0.05\text{ mm}$ ($2\text{ mil}$) | **$0.05\text{ mm}$ ($2\text{ mil}$)** |
| **Silkscreen Min Line** | Text and legend line width | $0.15\text{ mm}$ ($6\text{ mil}$) | **$0.20\text{ mm}$ ($8\text{ mil}$)** |
| **Silkscreen Min Height** | Text character height | $0.80\text{ mm}$ ($32\text{ mil}$) | **$1.00\text{ mm}$ ($40\text{ mil}$)** |
| **Surface Finish** | Chemical Gold / Lead-Free | HASL Lead-Free | **ENIG (Electroless Nickel Immersion Gold)** |
| **Solder Mask Color** | Motherboard | Any (Green/Blue/Black) | **Matte Black** |
| **Solder Mask Color** | Front Sensor Blade | **Matte Black ONLY** | **Matte Black ONLY** |

---

## 9. Pre-Fabrication Checklist

Before releasing Gerbers for manufacturing:
- [ ] Run Design Rules Check (DRC) with $0.15\text{ mm}$ clearance and $0.3\text{ mm}$ min drill hole. Zero DRC errors.
- [ ] Verify that Layer 2 (Inner 1) is a 100% solid, contiguous copper plane with no missing polygons or accidental split lines.
- [ ] Verify that every $V_{DD}$ pin pair on the STM32F446RE has a dedicated $100\text{ nF}$ bypass capacitor within $< 2\text{ mm}$.
- [ ] Verify that $V_{CAP1}$ (pin 30) and $V_{CAP2}$ (pin 42) connect **only** to $2.2\,\mu\text{F}$ capacitors to GND, never to 3.3V.
- [ ] Verify that TB6612FNG Pin 19 (`STBY`) is hardwired directly to the +3.3V copper plane.
- [ ] Verify that reverse-polarity protection P-MOSFET Q1 has its gate clamped to $15\text{V}$ via Zener diode D2.
- [ ] Verify that the Sensor Blade optical centers have exactly $7.50\text{ mm}$ uniform pitch.
- [ ] Export drill files in Excellon format with metric 2:4 decimal format, absolute coordinates.
- [ ] Export Gerbers in RS-274X format with 4.6 metric precision and matched board outline layer (GKO / Edge.Cuts).
