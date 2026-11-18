# Board 2: Front Optical Sensor Blade Specification (KiCad 8)

The Front Sensor Blade is a decoupled, sacrificial optical sensing array positioned at the front of the robot ahead of the ball caster.

---

## 1. Physical & Mechanical Specs
* **Sensors**: 8× Vishay `QRE1113GR` miniature SMD optical reflectance phototransistors.
* **Pitch**: **7.5 mm uniform pitch** between optical centers.
  - Span: $(8 - 1) \times 7.5\text{ mm} = \mathbf{52.5\text{ mm}}$.
  - White line width typically: $15\text{ mm}$ to $19\text{ mm}$ (covers 2–3 sensors simultaneously for fine Gaussian centroid interpolation).
* **Operating Height (Ground Clearance)**: **3.0 mm $\pm$ 0.5 mm** from the track surface.
* **Dimensions**: $65.0\text{ mm} \times 16.0\text{ mm}$, double-sided FR4, $1.0\text{ mm}$ thickness (reducing front overhang moment of inertia).
* **Solder Mask**: Matte Black (prevents internal optical glare and stray IR reflections).
* **Mounting Holes**: 2× slotted M2.5 / M3 holes at $X = \pm 29.0\text{ mm}$ ($58.0\text{ mm}$ center-to-center) enabling slotted vertical height adjustment.

---

## 2. Active Ambient Light Rejection Circuit (AutoDifferential)

```
       3.3V Logic Rail
          │
          ├───[ 100 Ω ]───(>| IR Emitter 1 )───┐
          ├───[ 100 Ω ]───(>| IR Emitter 2 )───┤
          │        ...                          │
          └───[ 100 Ω ]───(>| IR Emitter 8 )───┤
                                                │
                                            Drain (D)
   EMITTER_GATE (from PB14) ──[ 1 kΩ ]──┤ 2N7002 N-MOSFET (Q_GATE)
                                        │
                            [ 100 kΩ ]──┤ Source (S)
                            (pull-down) │
                                       GND
```

### Phototransistor Collector Pull-Up Network:
* Each sensor's phototransistor collector connects to `3.3V` through a $10\text{ k}\Omega$ (1%) SMD pull-up resistor (`R_PU1`..`R_PU8`).
* Each sensor's emitter connects to `GND`.
* The midpoint (Collector node) connects to the respective analog output lines `S1_ADC` through `S8_ADC`.
* Dark line (absorbs IR) $\to$ phototransistor OFF $\to$ Output pulled HIGH towards 3.3V ($\approx 4095$ counts).
* White floor (reflects IR) $\to$ phototransistor ON $\to$ Output pulled LOW towards GND ($\approx 200\text{--}500$ counts).
* Transition rise/fall times: $t_r, t_f < 15\,\mu\text{s}$, supporting ultra-high scan rates ($> 10\text{ kHz}$).

---

## 3. 11-Pin Inter-Board Ribbon Pinout (J7)

Matches Motherboard header `J3`:

| Pin # | Net Name | Wire Color | Function |
| :---: | :--- | :--- | :--- |
| **1** | `+3.3V` | Red | Clean 3.3V logic supply for optical sensors |
| **2** | `GND` | Black | Common signal ground |
| **3** | `S1_ADC` | Brown | Sensor 1 Analog Voltage (ADC1_IN10 / PC0) |
| **4** | `S2_ADC` | Orange | Sensor 2 Analog Voltage (ADC1_IN11 / PC1) |
| **5** | `S3_ADC` | Yellow | Sensor 3 Analog Voltage (ADC1_IN12 / PC2) |
| **6** | `S4_ADC` | Green | Sensor 4 Analog Voltage (ADC1_IN13 / PC3) |
| **7** | `S5_ADC` | Blue | Sensor 5 Analog Voltage (ADC1_IN14 / PC4) |
| **8** | `S6_ADC` | Purple | Sensor 6 Analog Voltage (ADC1_IN15 / PC5) |
| **9** | `S7_ADC` | Gray | Sensor 7 Analog Voltage (ADC1_IN8 / PB0) |
| **10**| `S8_ADC` | White | Sensor 8 Analog Voltage (ADC1_IN9 / PB1) |
| **11**| `EMITTER_GATE`| Yellow/Green | Gate drive signal from MCU pin PB14 |
