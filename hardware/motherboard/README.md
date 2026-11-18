# Board 1: Main Motherboard Specification (KiCad 8)

The Main Motherboard serves as the power, compute, and motor actuation hub for the robot.

---

## 1. Key Components & IC Packages

| Component | Part / Value | Package | Description |
| :--- | :--- | :--- | :--- |
| **Microcontroller (U1)** | STM32F446RET6 | LQFP-64 (10x10 mm, 0.5 mm pitch) | 180 MHz ARM Cortex-M4F, 512KB Flash, 128KB SRAM |
| **HSE Crystal (Y1)** | 8.000 MHz (16-18 pF) | 3225 (3.2x2.5 mm) SMD | External high-speed crystal oscillator with 2x 20pF caps |
| **Motor Driver (U2)** | TB6612FNG | SSOP-24 (0.65 mm pitch) | Dual H-Bridge, 1.2A continuous / 3.2A peak per channel |
| **Step-Down Buck (U3)**| MP1584 / TPS54302 | SOIC-8 / SOT-23-6 | 12V LiPo to 5V (2A rating) for HC-05, encoders, buzzer |
| **Linear LDO (U4)** | AP2112K-3.3 / AMS1117-3.3 | SOT-23-5 / SOT-223 | Ultra-low noise 3.3V (600mA) for STM32 VDD & VDDA |
| **Active Buzzer (BZ1)** | 5V / 3.3V Active Buzzer | 9.5 mm / 12 mm SMD | GPIO-driven audio warning transducer |
| **Bluetooth Header (J1)**| 6-Pin 2.54 mm Female Header | Through-Hole | HC-05 Breakout Socket (VCC, GND, TX, RX, STATE, EN) |
| **SWD Debug Header (J2)**| 4-Pin or 6-Pin 2.54 mm Header| Through-Hole / SMD | SWDIO (PA13), SWCLK (PA14), NRST, GND, 3.3V |
| **Sensor Blade Header(J3)**| 10-Pin 2.0 mm / 2.54 mm JST | Right-Angle / Vertical | Inter-board ribbon connection to Front Sensor Blade |
| **Motor A Connector (J4)**| 6-Pin 1.5 mm / 2.0 mm JST | SMD / Through-Hole | N20 Left Motor (M+, M-, 5V, GND, Enc_A, Enc_B) |
| **Motor B Connector (J5)**| 6-Pin 1.5 mm / 2.0 mm JST | SMD / Through-Hole | N20 Right Motor (M+, M-, 5V, GND, Enc_A, Enc_B) |
| **Power Switch & Jack (SW1/J6)**| XT30 / JST-XH 2.54 mm | Through-Hole | 3S LiPo battery power input |

---

## 2. Electrical Design Guidelines

### A. Power Distribution & Decoupling
* **Bulk Capacitors**:
  * $100\,\mu\text{F}$ 25V Low-ESR electrolytic/tantalum capacitor directly across TB6612 `VM` and `GND` pins to absorb motor inductive kickback.
  * $10\,\mu\text{F}$ ceramic on Buck 12V input and 5V output.
  * $1\,\mu\text{F}$ and $10\,\mu\text{F}$ on 3.3V LDO input and output.
* **STM32 Decoupling**:
  * One $100\text{ nF}$ ceramic capacitor placed immediately adjacent to EVERY `VDD`/`VSS` pin pair (pins 19/18, 32/31, 48/47, 64/63).
  * One $4.7\,\mu\text{F}$ bulk ceramic cap placed near pin 64.
  * Dedicated ferrite bead + $100\text{ nF} + 1\,\mu\text{F}$ filter network for `VDDA`/`VSSA` (analog supply for ADC1).
  * Two $2.2\,\mu\text{F}$ low-ESR ceramic caps on `VCAP_1` and `VCAP_2` (internal 1.2V core regulator stabilization).

### B. TB6612FNG Hardwired Bare-IC Implementation
* Connect `STBY` (pin 19 of TB6612) directly to the **3.3V logic rail** with a $0\,\Omega$ jumper or direct trace.
* Connect `VCC` (pin 20) to 3.3V.
* Connect `VM` (pins 24 & 13) to raw 12V LiPo battery.
* Connect `PGND` and `SGND` together into the main bottom ground plane.

### C. Battery Voltage Divider Network
* Top resistor: $100\text{ k}\Omega$ (1% tolerance) from LiPo (+) rail.
* Bottom resistor: $22\text{ k}\Omega$ (1% tolerance) to GND.
* Filter capacitor: $100\text{ nF}$ in parallel with $22\text{ k}\Omega$ resistor.
* Tap point connects to STM32 `PA4` (ADC1_IN4).
* Voltage scaling: $\frac{22}{100 + 22} = \frac{22}{122} \approx 0.1803$. At $12.6\text{V}$, $V_{\text{pin}} \approx 2.27\text{V} < 3.3\text{V}$.

---

## 3. 10-Pin Inter-Board Ribbon Connector Pinout (J3)

Connects Mainboard to Front Sensor Blade:

| Pin # | Net Name | Wire Color Suggestion | Description |
| :---: | :--- | :--- | :--- |
| **1** | `VDD_3V3` | Red | Clean 3.3V logic supply for optical sensors |
| **2** | `GND` | Black | Common signal ground |
| **3** | `S1_ADC_PC0` | Brown | Sensor 1 Analog Voltage (ADC1_IN10) |
| **4** | `S2_ADC_PC1` | Orange | Sensor 2 Analog Voltage (ADC1_IN11) |
| **5** | `S3_ADC_PC2` | Yellow | Sensor 3 Analog Voltage (ADC1_IN12) |
| **6** | `S4_ADC_PC3` | Green | Sensor 4 Analog Voltage (ADC1_IN13) |
| **7** | `S5_ADC_PC4` | Blue | Sensor 5 Analog Voltage (ADC1_IN14) |
| **8** | `S6_ADC_PC5` | Purple | Sensor 6 Analog Voltage (ADC1_IN15) |
| **9** | `S7_ADC_PB0` | Gray | Sensor 7 Analog Voltage (ADC1_IN8) |
| **10**| `S8_ADC_PB1` | White | Sensor 8 Analog Voltage (ADC1_IN9) |
| **11**| `EMITTER_PB14`| Yellow/Green | 2N7002 MOSFET Gate drive signal |
