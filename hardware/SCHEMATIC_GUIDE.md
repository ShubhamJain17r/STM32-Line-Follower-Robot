# Complete Hardware Schematic Design Guide

**Autonomous High-Speed Closed-Loop Line Following Robot**  
**Target Microcontroller:** STM32F446RET6 (180 MHz ARM Cortex-M4F, LQFP-64)  
**System Architecture:** Two-Board Modular Topology (Main Motherboard + Front Sensor Blade)

---

## 1. System Electrical Architecture & Power Tree

The robot is powered by a 3S Lithium-Polymer (LiPo) battery ($11.1\text{V}$ nominal, $12.6\text{V}$ peak charge, $9.3\text{V}$ critical cutoff). The power distribution architecture uses a two-stage regulation scheme: a high-efficiency switching buck regulator generates a +5.0V intermediate system rail, and an ultra-low-noise low-dropout (LDO) linear regulator provides the clean +3.3V rail for the MCU, analog sensors, and logic.

```
                  ┌────────────────────────────────────────┐
                  │ 3S LiPo Battery (11.1V - 12.6V, XT30) │
                  └───────────────────┬────────────────────┘
                                      │
                   [F1: 3.0A PPTC 1812 Resettable Fuse]
                                      │
               [Q1: AO3401A P-MOSFET Reverse Polarity Protection]
               [D2: BZX84C15 15V Zener Gate Clamp + R1: 100kΩ]
                                      │
              ┌───────────────────────┴───────────────────────┐
              │                                               │
              ▼ (Fused & Protected VM Rail)                   ▼
   ┌──────────────────────┐                     ┌───────────────────────────┐
   │ Motor Drive (VM)     │                     │ Battery Voltage Monitor   │
   │ - TB6612FNG Pins 13,24                     │ - 100kΩ / 22kΩ Divider    │
   │ - 100 µF 25V Low-ESR │                     │ - 100 nF Anti-Alias Cap   │
   │ - 2× 10 µF 25V X7R   │                     │ - Connects to PA4 (ADC1)  │
   └──────────────────────┘                     └───────────────────────────┘
              │
              ▼
   ┌────────────────────────────────────────────────────────┐
   │ 5.0V Switching Buck Regulator (TI TPS54302, 3A, 400kHz)│
   │ - L1: 4.7 µH Shielded Power Inductor (4.5A Isat)       │
   │ - C_IN: 2× 10 µF 25V X7R Ceramic                       │
   │ - C_OUT: 2× 22 µF 10V X7R Ceramic                      │
   └──────────────────────────┬─────────────────────────────┘
                              │
             ┌────────────────┴────────────────┐
             │ (+5V System Rail)               │
             ▼                                 ▼
   ┌──────────────────────────┐   ┌────────────────────────────────────────┐
   │ 5V Peripheral Loads      │   │ 3.3V Ultra-Low-Noise LDO (AP2112K-3.3) │
   │ - HC-05 Bluetooth Socket │   │ - 600 mA Peak, 55 dB PSRR @ 1 kHz     │
   │ - N20 Hall Encoders (2×) │   │ - C_OUT: 4.7 µF X7R + 100 nF 0603      │
   │ - Active Piezo Buzzer    │   └───────────────────┬────────────────────┘
   └──────────────────────────┘                       │
                                                      │ (+3.3V Logic Rail)
                                      ┌───────────────┴───────────────┐
                                      ▼                               ▼
                      ┌──────────────────────────────┐ ┌──────────────────────────┐
                      │ STM32F446RET6 Core & Logic   │ │ Sensor Blade (Board 2)   │
                      │ - 4× VDD/VSS (4× 100 nF)     │ │ - 8× QRE1113GR Emitters  │
                      │ - VDDA Analog (FB1 + 1 µF)   │ │ - 8× Phototransistor PUs │
                      │ - VCAP1/2 (2× 2.2 µF)        │ │ - 2N7002 Ambient Switch  │
                      │ - TB6612 VCC & STBY (Tied 1) │ └──────────────────────────┘
                      └──────────────────────────────┘
```

---

## 2. Main Motherboard Circuit Schematics

### 2.1 Power Input & Reverse-Polarity Protection

* **Connector (J6)**: Amass `XT30-PW` right-angle male connector rated for 30A continuous.
* **Overcurrent Protection (F1)**: 3.0A hold / 6.0A trip PPTC resettable fuse (1812 package, rated 30V DC).
* **Reverse Polarity Protection (Q1)**: `AO3401A` P-channel MOSFET ($-30\text{V}$, $-4.2\text{A}$, $R_{DS(ON)} \le 44\text{ m}\Omega$).
  - **Source (S)** connected to fused battery positive.
  - **Drain (D)** connected to the internal $V_M$ power rail.
  - **Gate (G)** pulled to GND through $R_1 = 100\text{ k}\Omega$. When battery is connected correctly, $V_{GS} \approx -12\text{V}$ and the MOSFET fully enhances, dropping only $\approx 44\text{ mV}$ at 1A load (compared to $400\text{--}600\text{ mV}$ for a Schottky diode).
  - **Gate Protection (D2)**: `BZX84C15` 15V Zener diode across Gate and Source limits $|V_{GS}| \le 15\text{V}$ against inductive battery spikes (maximum rated $V_{GS} = \pm 20\text{V}$).

### 2.2 Step-Down Buck Converter (+5.0V System Rail)

* **Controller (U3)**: Texas Instruments `TPS54302DDCR` (6-pin SOT-23, $4.5\text{V}\text{--}28\text{V}$ input, 3A continuous output, 400 kHz fixed frequency, integrated high/low-side MOSFETs).
* **Input Capacitors**: $C_2, C_3 = 2\times 10\,\mu\text{F}$ 25V 1206 X7R ceramic placed directly at pin 2 (`VIN`) and pin 1 (`GND`).
* **Inductor (L1)**: $4.7\,\mu\text{H}$ shielded power inductor (`Bourns SRR5028` or `Coilcraft XAL5030`, saturation current $I_{sat} \ge 4.5\text{A}$, $DCR \le 35\text{ m}\Omega$).
* **Feedback Divider**:
  $$V_{OUT} = 0.596\text{V} \times \left(1 + \frac{R_{high}}{R_{low}}\right)$$
  - $R_{high} = R_2 = 100\text{ k}\Omega$ (1%, 0603).
  - $R_{low} = R_3 = 13.7\text{ k}\Omega$ (1%, 0603).
  - Calculated output: $V_{OUT} = 0.596\text{V} \times (1 + 100 / 13.7) = \mathbf{4.947\text{V}} \approx \mathbf{5.0\text{V}}$.
* **Output Filtering**: $C_4, C_5 = 2\times 22\,\mu\text{F}$ 10V 1206 X7R ceramic capacitors in parallel with $C_{26} = 100\text{ nF}$ 0603 for high-frequency ripple suppression.
* **Bootstrap Capacitor**: $C_{25} = 100\text{ nF}$ 50V 0603 between pin 6 (`BOOT`) and pin 5 (`SW`).

### 2.3 Low-Dropout Regulator (+3.3V Logic Rail)

* **LDO (U4)**: Diodes Inc. `AP2112K-3.3TRG1` (SOT-23-5, 600 mA output, $250\text{ mV}$ dropout at 600 mA, $55\text{ dB}$ PSRR, ultra-low quiescent current).
* **Input Filter**: $C_6 = 4.7\,\mu\text{F}$ 10V 0805 X7R + $C_8 = 100\text{ nF}$ 0603.
* **Output Filter**: $C_7 = 4.7\,\mu\text{F}$ 10V 0805 X7R + $C_9 = 100\text{ nF}$ 0603 (maintains loop stability and suppresses transient load drops).

### 2.4 Battery Voltage Sensing Circuit

* **Divider Ratio**: Connects from the fused $V_M$ rail to MCU pin `PA4` (`ADC1_IN4`):
  - $R_4 = 100\text{ k}\Omega$ (1%, 0603, high side).
  - $R_5 = 22\text{ k}\Omega$ (1%, 0603, low side).
  - Voltage attenuation ratio:
    $$\alpha = \frac{R_5}{R_4 + R_5} = \frac{22}{100 + 22} = \mathbf{0.180328}$$
* **Voltage Mapping**:
  - Full battery: $12.6\text{V} \times 0.180328 = \mathbf{2.272\text{V}}$ ($\approx 2819$ ADC counts on 12-bit, 3.3V reference).
  - Low battery warning: $9.9\text{V} \times 0.180328 = \mathbf{1.785\text{V}}$ ($\approx 2215$ counts).
  - Critical cutoff: $9.3\text{V} \times 0.180328 = \mathbf{1.677\text{V}}$ ($\approx 2081$ counts).
* **Anti-Aliasing Filter**: $C_{10} = 100\text{ nF}$ ceramic capacitor placed across $R_5$ to GND, forming a low-pass filter with $f_c \approx 88\text{ Hz}$ to eliminate PWM motor noise from the ADC readings.

### 2.5 Microcontroller Core (STM32F446RET6 LQFP-64)

* **Power Decoupling**:
  - $V_{DD} / V_{SS}$ pairs on pins 19/18, 32/31, 48/47, 64/63: Each pair requires a dedicated $C = 100\text{ nF}$ 0603 X7R capacitor placed within $< 2\text{ mm}$ of the package pads.
  - Bulk decoupling: $C_{17} = 4.7\,\mu\text{F}$ 0805 X7R on the 3.3V plane adjacent to pin 64.
* **Analog Power ($V_{DDA} / V_{SSA}$)**:
  - Pin 13 ($V_{DDA}$) is decoupled with $C_{21} = 1\,\mu\text{F}$ 0603 + $C_{20} = 100\text{ nF}$ 0603.
  - High-frequency isolation via `FB1` ($600\,\Omega$ @ 100 MHz ferrite bead, 0805) separating $V_{DD}$ from $V_{DDA}$.
  - Pin 12 ($V_{SSA}$) connects directly to the solid ground plane at pin 18.
* **Core Voltage Regulators ($V_{CAP1}, V_{CAP2}$)**:
  - Pins 30 and 42 require external low-ESR ceramic capacitors connected directly to $V_{SS}$:
  - $C_{18}, C_{19} = 2.2\,\mu\text{F}$ 10V 0603 X7R ($ESR < 1\,\Omega$). **Do not connect to 3.3V!**
* **External Clock (HSE, 8.000 MHz)**:
  - Crystal (Y1): $8.000\text{ MHz}$ fundamental mode, $18\text{ pF}$ load capacitance, 4-pad SMD 3225 package.
  - Load capacitors: $C_{11}, C_{12} = 18\text{ pF}$ 50V C0G/NP0 0603 connected from crystal pins to ground.
  - Series damping resistor: $R_{damp} = 0\,\Omega$ / jumper.
  - STM32 PLL multiplies 8 MHz HSE to $180\text{ MHz}$ core clock ($M=8, N=360, P=2$).
* **Reset Circuit (NRST)**:
  - Pin 7 (`NRST`): Pulled up to 3.3V via internal resistor, supplemented with external $R_6 = 10\text{ k}\Omega$ pull-up and $C_{13} = 100\text{ nF}$ capacitor to GND for brownout reset debouncing.
* **Boot Configuration**:
  - Pin 60 (`BOOT0`): Pulled to GND through $R_8 = 10\text{ k}\Omega$ resistor (enables Flash boot mode).
* **SWD Programming & Debug Header (J2)**:
  - 4-pin 2.54mm male header:
    - Pin 1: `+3.3V`
    - Pin 2: `SWDIO` (PA13)
    - Pin 3: `SWCLK` (PA14)
    - Pin 4: `GND`

### 2.6 Motor Driver Subsystem (Toshiba TB6612FNG, SSOP-24)

* **Power Rails**:
  - Pins 13, 24 (`VM`): Connected to fused $11.1\text{V}\text{--}12.6\text{V}$ rail.
  - Pin 20 (`VCC`): Connected to $+3.3\text{V}$ logic supply, decoupled with $C_{22} = 100\text{ nF}$ 0603.
  - Bulk Capacitance: $C_1 = 100\,\mu\text{F}$ 25V low-ESR electrolytic ($6.3 \times 5.4\text{ mm}$ SMD) + $C_{24} = 10\,\mu\text{F}$ 25V 1206 ceramic placed directly across VM and PGND.
* **Hardware-Tied Standby Pin**:
  - **Pin 19 (`STBY`) is hardwired directly to the +3.3V logic rail.**
  - Eliminates 1 MCU GPIO pin, eliminates firmware standby bugs, and guarantees H-bridge is permanently operational upon boot.
* **Logic Inputs (Direct MCU Interface)**:
  - Pin 23 (`PWMA`): `PA0` (TIM2_CH1, 20 kHz ultrasonic PWM).
  - Pin 17 (`PWMB`): `PA1` (TIM2_CH2, 20 kHz ultrasonic PWM).
  - Pin 21 (`AIN1`): `PC8` (GPIO Output Push-Pull).
  - Pin 22 (`AIN2`): `PC9` (GPIO Output Push-Pull).
  - Pin 19 (`BIN1`): `PC11` (GPIO Output Push-Pull).
  - Pin 18 (`BIN2`): `PC12` (GPIO Output Push-Pull).
* **Motor Outputs**:
  - Pins 1, 2 (`AO1`): Left Motor terminal (+) $\to$ J4 Pin 1.
  - Pins 5, 6 (`AO2`): Left Motor terminal (-) $\to$ J4 Pin 2.
  - Pins 8, 9 (`BO2`): Right Motor terminal (-) $\to$ J5 Pin 2.
  - Pins 11, 12 (`BO1`): Right Motor terminal (+) $\to$ J5 Pin 1.
* **Control Truth Table**:

| IN1 | IN2 | PWM | STBY | Mode | Output State |
| :---: | :---: | :---: | :---: | :--- | :--- |
| **H** | **L** | **H** | **H (3.3V)** | **Forward** | AO1=H, AO2=L (Motor drives forward) |
| **L** | **H** | **H** | **H (3.3V)** | **Reverse** | AO1=L, AO2=H (Motor drives reverse) |
| **L** | **L** | **X** | **H (3.3V)** | **Coast / Stop**| AO1=OFF, AO2=OFF (High-Z) |
| **H** | **H** | **X** | **H (3.3V)** | **Short Brake** | AO1=L, AO2=L (Dynamic motor braking) |

### 2.7 Dual Quadrature Encoders (TIM3 & TIM4 Silicon Hardware Decoding)

* **Connectors**:
  - Left Motor: J4 (JST-PH 6-pin, 2.0 mm pitch).
  - Right Motor: J5 (JST-PH 6-pin, 2.0 mm pitch).
  - Pinout: Pin 1=Motor+, Pin 2=Motor-, Pin 3=GND, Pin 4=+5V, Pin 5=Encoder A, Pin 6=Encoder B.
* **Hardware Timer Decoding**:
  - Left Motor: `ENC_L_A` on `PA6` (TIM3_CH1), `ENC_L_B` on `PA7` (TIM3_CH2).
  - Right Motor: `ENC_R_A` on `PB6` (TIM4_CH1), `ENC_R_B` on `PB7` (TIM4_CH2).
  - STM32 hardware encoder interface decodes all 4 edges in silicon ($1440\text{ CPR}$ with 30:1 N20 motor), resulting in zero CPU interrupt overhead.
* **Protection / Filtering**: 100Ω series resistors on encoder lines into the MCU with 10kΩ pull-ups to 3.3V.

### 2.8 Telemetry & Sounder Subsystem

* **Bluetooth Interface (J1)**: 6-pin 2.54mm female header for HC-05 / JDY-31 module:
  - Pin 1: `STATE` $\to$ `PB2` (GPIO Input Floating; HIGH when Bluetooth paired).
  - Pin 2: `RXD` $\to$ `PA9` (`USART1_TX`, 3.3V level).
  - Pin 3: `TXD` $\to$ `PA10` (`USART1_RX`, 3.3V level).
  - Pin 4: `GND` $\to$ Ground plane.
  - Pin 5: `+5V` $\to$ +5V Buck supply rail.
  - Pin 6: `EN` $\to$ Float / NC.
* **Piezo Buzzer (BZ1)**: Active 5V magnetic piezo buzzer (85 dB @ 10cm, $30\text{ mA}$ operating current):
  - Driven by `Q3` (`S8050` NPN transistor, SOT-23, $I_c = 500\text{ mA}$).
  - Base connected to `PB8` via $R_7 = 1\text{ k}\Omega$ current limiting resistor.
  - Base pull-down: $R_{10} = 10\text{ k}\Omega$ ensures buzzer stays silent during MCU boot/reset.
  - Flyback protection diode: `D1` (`B5819W` Schottky diode, SOD-123) across the buzzer coil absorbs inductive switch-off spikes.

---

## 3. Front Optical Sensor Blade Circuit Schematics

### 3.1 Optical Array Geometry

* **Sensors**: 8× Vishay `QRE1113GR` miniature SMD optical reflectance phototransistors.
* **Pitch**: **7.5 mm uniform pitch** between optical centers.
  $$\text{Span} = (8 - 1) \times 7.5\text{ mm} = \mathbf{52.5\text{ mm}}$$
* **Optical Focal Distance**: Designed for ground clearance of **$3.0\text{ mm} \pm 0.5\text{ mm}$**.

### 3.2 Active Ambient Light Rejection Circuit (AutoDifferential)

Standard optical sensors suffer saturation from sunlight and 100/120 Hz fluorescent flickering. The Sensor Blade incorporates an active low-side MOSFET switch to modulate all 8 emitter LEDs synchronously with the STM32 ADC sampling pipeline:

```
                  +3.3V Clean Optical Rail
                             │
       ┌──────────┬──────────┼──────────┬──────────┐
       │          │          │          │          │
   [ R_EM1 ]  [ R_EM2 ]  [ R_EM3 ]     ...     [ R_EM8 ]  (8× 100 Ω, 0603)
       │          │          │                     │
      (A)        (A)        (A)                   (A)
     (>| )      (>| )      (>| )                 (>| )     (8× QRE1113GR IR LEDs)
     (IR1)      (IR2)      (IR3)                 (IR8)
      (K)        (K)        (K)                   (K)
       │          │          │                     │
       └──────────┴──────────┼─────────────────────┘
                             │
                         Drain (D)
  EMITTER_GATE (PB14) ──[ R_G: 1kΩ ]──┤ 2N7002 N-MOSFET (SOT-23)
                             │        │
                         [ R_PD ]     │ Source (S)
                         [ 100k ]     │
                             │       GND
                            GND
```

* **LED Ballast Resistors ($R_{EM1}\text{--}R_{EM8}$)**:
  - IR LED forward voltage: $V_f \approx 1.25\text{V}$ @ $I_f = 20\text{ mA}$.
  - Supply: $V_{CC} = 3.3\text{V}$.
  - Resistor calculation:
    $$R = \frac{3.3\text{V} - 1.25\text{V}}{0.020\text{A}} = 102.5\,\Omega \implies \mathbf{100\,\Omega}\text{ (1\%, 0603)}$$
  - Resulting current per LED: $I_f = \frac{3.3 - 1.25}{100} = \mathbf{20.5\text{ mA}}$.
  - Total array current when active: $8 \times 20.5\text{ mA} = \mathbf{164\text{ mA}}$.
* **Modulation Switch (Q_GATE)**:
  - `2N7002` N-channel MOSFET ($60\text{V}$, $300\text{ mA}$, $R_{DS(ON)} \approx 2.5\,\Omega$, $V_{GS(th)} \le 2.0\text{V}$).
  - Gate driven by MCU pin `PB14` through $R_G = 1\text{ k}\Omega$.
  - Gate pull-down: $R_{PD} = 100\text{ k}\Omega$ ensures LEDs remain unpowered during MCU reset.
  - Switching speed: Rise time $t_r < 15\text{ ns}$, Fall time $t_f < 15\text{ ns}$ (supports optical modulation $> 50\text{ kHz}$).

### 3.3 Phototransistor Collector Network

```
                   +3.3V Logic Rail
                          │
                  [ R_PU: 10 kΩ, 1% ]
                          │
                          ├──────────> Analog Output (S1_ADC .. S8_ADC)
                          │
                      Collector (C)
                         ┌┴┐
                      <─ │ │ (Phototransistor QRE1113GR)
                         └┬┘
                       Emitter (E)
                          │
                         GND
```

* **Pull-Up Resistors ($R_{PU1}\text{--}R_{PU8}$)**: $10\text{ k}\Omega$ (1%, 0603).
* **Operating Logic**:
  - Over White Surface: Strong IR reflection excites phototransistor $\to$ conducts hard $\to$ output pulls LOW towards GND ($V_{out} \approx 0.15\text{V}\text{--}0.45\text{V}$, ADC counts $\approx 200\text{--}550$).
  - Over Black Line: IR absorbed $\to$ phototransistor remains OFF $\to$ pull-up pulls output HIGH to 3.3V ($V_{out} \approx 3.25\text{V}$, ADC counts $\approx 4030\text{--}4095$).
* **Differential Math (Implemented in Firmware)**:
  $$V_{calibrated} = V_{reading}(LED_{ON}) - V_{ambient}(LED_{OFF})$$
  Completely cancels out direct sunlight and AC lighting ambient interference.

---

## 4. Complete Inter-Board Interconnect (J3 to J7)

The Motherboard connects to the Front Sensor Blade via an 11-pin JST-PH 2.0mm shielded ribbon cable (`J3` on Motherboard $\to$ `J7` on Sensor Blade):

| Pin # | Net Name | Wire Color | Signal Type | Motherboard Source | Sensor Blade Destination |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **1** | `+3.3V` | Red | Clean Power | AP2112K-3.3 Rail | Pull-ups & Emitter Anodes |
| **2** | `GND` | Black | Ground Return | Motherboard Ground Plane | Transistor Emitters & 2N7002 Source |
| **3** | `S1_ADC` | Brown | Analog (0-3.3V) | MCU Pin `PC0` (ADC1_IN10) | Sensor 1 Collector (Far-Left) |
| **4** | `S2_ADC` | Orange| Analog (0-3.3V) | MCU Pin `PC1` (ADC1_IN11) | Sensor 2 Collector |
| **5** | `S3_ADC` | Yellow| Analog (0-3.3V) | MCU Pin `PC2` (ADC1_IN12) | Sensor 3 Collector |
| **6** | `S4_ADC` | Green | Analog (0-3.3V) | MCU Pin `PC3` (ADC1_IN13) | Sensor 4 Collector (Center-Left) |
| **7** | `S5_ADC` | Blue | Analog (0-3.3V) | MCU Pin `PC4` (ADC1_IN14) | Sensor 5 Collector (Center-Right) |
| **8** | `S6_ADC` | Purple| Analog (0-3.3V) | MCU Pin `PC5` (ADC1_IN15) | Sensor 6 Collector |
| **9** | `S7_ADC` | Gray | Analog (0-3.3V) | MCU Pin `PB0` (ADC1_IN8) | Sensor 7 Collector |
| **10**| `S8_ADC` | White | Analog (0-3.3V) | MCU Pin `PB1` (ADC1_IN9) | Sensor 8 Collector (Far-Right) |
| **11**| `EMITTER_GATE`| White/Black| Digital Out | MCU Pin `PB14` (GPIO Push-Pull) | 2N7002 Gate Switch |

---

## 5. Complete Netlist & Silicon Pin Mapping

| MCU Pin | Pin Name | Net Name | Peripheral Mode | Hardware Connection | Purpose / Role |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **14**| `PA0` | `PWMA_TIM2_CH1` | `TIM2_CH1` (AF1) | TB6612 Pin 23 | Left Motor 20 kHz Ultrasonic PWM |
| **15**| `PA1` | `PWMB_TIM2_CH2` | `TIM2_CH2` (AF1) | TB6612 Pin 17 | Right Motor 20 kHz Ultrasonic PWM |
| **16**| `PA2` | `NC` | Reserved | Test Point | Unused |
| **17**| `PA3` | `NC` | Reserved | Test Point | Unused |
| **20**| `PA4` | `VBAT_SENSE_PA4`| `ADC1_IN4` (Analog)| 100k/22k Divider | 3S LiPo Voltage Monitor |
| **21**| `PA5` | `STATUS_LED_PA5`| `GPIO_Output` | Green LED D3 via 1kΩ | Onboard Status Indicator |
| **22**| `PA6` | `ENC_L_A_PA6` | `TIM3_CH1` (AF2) | Header J4 Pin 5 | Left Encoder Phase A (1440 CPR) |
| **23**| `PA7` | `ENC_L_B_PA7` | `TIM3_CH2` (AF2) | Header J4 Pin 6 | Left Encoder Phase B (1440 CPR) |
| **41**| `PA9` | `BT_TXD_PA9` | `USART1_TX` (AF7) | Header J1 Pin 4 | HC-05 Bluetooth RXD |
| **42**| `PA10`| `BT_RXD_PA10` | `USART1_RX` (AF7) | Header J1 Pin 3 | HC-05 Bluetooth TXD |
| **46**| `PA13`| `SWDIO` | `SYS_JTMS-SWDIO`| Header J2 Pin 2 | SWD Debug Data |
| **49**| `PA14`| `SWCLK` | `SYS_JTCK-SWCLK`| Header J2 Pin 3 | SWD Debug Clock |
| **26**| `PB0` | `S7_ADC` | `ADC1_IN8` (Analog)| Header J3 Pin 9 | Sensor 7 Reflection ADC |
| **27**| `PB1` | `S8_ADC` | `ADC1_IN9` (Analog)| Header J3 Pin 10 | Sensor 8 Reflection ADC |
| **28**| `PB2` | `BT_STATE_PB2` | `GPIO_Input` | Header J1 Pin 5 | HC-05 Bluetooth Connection State |
| **58**| `PB6` | `ENC_R_A_PB6` | `TIM4_CH1` (AF2) | Header J5 Pin 5 | Right Encoder Phase A (1440 CPR) |
| **59**| `PB7` | `ENC_R_B_PB7` | `TIM4_CH2` (AF2) | Header J5 Pin 6 | Right Encoder Phase B (1440 CPR) |
| **61**| `PB8` | `BUZZER_PB8` | `GPIO_Output` | Q3 S8050 Base via 1kΩ| Active Piezo Buzzer Chime/Alarm |
| **34**| `PB14`| `EMITTER_GATE` | `GPIO_Output` | Header J3 Pin 11 | AutoDifferential Emitter Modulation |
| **8** | `PC0` | `S1_ADC` | `ADC1_IN10` (Analog)| Header J3 Pin 3 | Sensor 1 Reflection ADC |
| **9** | `PC1` | `S2_ADC` | `ADC1_IN11` (Analog)| Header J3 Pin 4 | Sensor 2 Reflection ADC |
| **10**| `PC2` | `S3_ADC` | `ADC1_IN12` (Analog)| Header J3 Pin 5 | Sensor 3 Reflection ADC |
| **11**| `PC3` | `S4_ADC` | `ADC1_IN13` (Analog)| Header J3 Pin 6 | Sensor 4 Reflection ADC |
| **24**| `PC4` | `S5_ADC` | `ADC1_IN14` (Analog)| Header J3 Pin 7 | Sensor 5 Reflection ADC |
| **25**| `PC5` | `S6_ADC` | `ADC1_IN15` (Analog)| Header J3 Pin 8 | Sensor 6 Reflection ADC |
| **39**| `PC8` | `AIN1_PC8` | `GPIO_Output` | TB6612 Pin 21 | Left Motor Direction 1 (BSRR) |
| **40**| `PC9` | `AIN2_PC9` | `GPIO_Output` | TB6612 Pin 22 | Left Motor Direction 2 (BSRR) |
| **51**| `PC11`| `BIN1_PC11` | `GPIO_Output` | TB6612 Pin 19 | Right Motor Direction 1 (BSRR) |
| **52**| `PC12`| `BIN2_PC12` | `GPIO_Output` | TB6612 Pin 18 | Right Motor Direction 2 (BSRR) |
| **2** | `PC13`| `USER_BTN_PC13` | `GPIO_Input_PU` | Tactile Button SW_USER| Calibration & Mode Trigger |
| **5** | `PH0` | `OSC_IN` | `RCC_OSC_IN` | Crystal Y1 Pin 1 | 8 MHz HSE Oscillator Input |
| **6** | `PH1` | `OSC_OUT` | `RCC_OSC_OUT` | Crystal Y1 Pin 3 | 8 MHz HSE Oscillator Output |
| **7** | `NRST`| `NRST` | `SYS_RESET` | 10k Pull-up + 100nF | Hardware Master Reset |
| **60**| `BOOT0`| `BOOT0` | `SYS_BOOT0` | 10k Pull-down to GND| Flash Execution Boot Selection |
