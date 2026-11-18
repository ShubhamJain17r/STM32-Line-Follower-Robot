# Board 1: Main Motherboard Specification (KiCad 8)

The Main Motherboard serves as the power, compute, wireless telemetry, and motor actuation hub for the high-speed line follower robot.

---

## 1. Electrical & Power Architecture

```
3S LiPo (11.1V - 12.6V)
   │
 [XT30-PW]
   │
 [F1: 3.0A PPTC 1812 Fuse]
   │
 [Q1: AO3401A P-MOSFET Reverse Polarity Protection + 15V Zener Clamp]
   │
   ├───> VM Rail (11.1V - 12.6V Fused)
   │        ├── 100 µF 25V Low-ESR Electrolytic (Motor inductive kick absorption)
   │        └── TB6612FNG Dual H-Bridge (Pins 13 & 24)
   │
   ├───> 3S LiPo Voltage Monitor Divider
   │        └── 100 kΩ / 22 kΩ (Ratio = 0.1803) + 100 nF filter ──> PA4 (ADC1_IN4)
   │
   └───> 5.0V Buck Converter (TPS54302 3A / 400 kHz)
            │
            ├── L1: 4.7 µH Shielded Power Inductor (4.5A Isat)
            ├── C4/C5: 2× 22 µF 10V X7R Ceramic Output Filter
            │
            ├───> +5V System Rail
            │        ├── HC-05 Bluetooth Socket (J1)
            │        ├── N20 Dual Encoders VCC (J4 & J5)
            │        ├── Active Piezo Buzzer (BZ1 driven via S8050 NPN)
            │        │
            │        └──> 3.3V Ultra-Low-Noise LDO (AP2112K-3.3, 600mA, SOT-23-5)
            │                 │
            │                 ├── C7: 4.7 µF 10V + C9: 100 nF Ceramic Output Filter
            │                 │
            │                 └───> +3.3V Logic Rail
            │                          ├── STM32F446RET6 VDD / VSS Pairs (4× 100 nF)
            │                          ├── VDDA Analog Domain (FB1: 600Ω Bead + 100 nF + 1 µF)
            │                          ├── VCAP1 / VCAP2 Core Regulators (2× 2.2 µF)
            │                          ├── TB6612FNG VCC (Pin 20) + 100 nF
            │                          ├── TB6612FNG STBY (Pin 19) HARDWIRED DIRECTLY TO 3.3V!
            │                          └── J3 Inter-Board Ribbon Header (Pin 1 to Sensor Blade)
```

---

## 2. Silicon Pinout & Channel Mapping (STM32F446RET6 LQFP-64)

| Function | Signal Net Name | MCU Pin | Peripheral AF Mode | Hardware Connection |
| :--- | :--- | :--- | :--- | :--- |
| **Left Motor PWM** | `PWMA_TIM2_CH1` | `PA0` | TIM2_CH1 (AF1) | TB6612 Pin 23 (20 kHz Ultrasonic PWM) |
| **Right Motor PWM** | `PWMB_TIM2_CH2` | `PA1` | TIM2_CH2 (AF1) | TB6612 Pin 17 (20 kHz Ultrasonic PWM) |
| **Left Motor Dir 1** | `AIN1_PC8` | `PC8` | GPIO Output Push-Pull | TB6612 Pin 21 (Atomic BSRR) |
| **Left Motor Dir 2** | `AIN2_PC9` | `PC9` | GPIO Output Push-Pull | TB6612 Pin 22 (Atomic BSRR) |
| **Right Motor Dir 1** | `BIN1_PC11` | `PC11` | GPIO Output Push-Pull | TB6612 Pin 19 (Atomic BSRR) |
| **Right Motor Dir 2** | `BIN2_PC12` | `PC12` | GPIO Output Push-Pull | TB6612 Pin 18 (Atomic BSRR) |
| **Motor Standby** | `MOTOR_STBY` | **N/A** | Hardware Tied High | Hardwired to 3.3V plane (0 GPIOs wasted) |
| **Left Encoder Phase A** | `ENC_L_A_PA6` | `PA6` | TIM3_CH1 (AF2) | J4 Pin 5 (Silicon Hardware Decoding) |
| **Left Encoder Phase B** | `ENC_L_B_PA7` | `PA7` | TIM3_CH2 (AF2) | J4 Pin 6 (Silicon Hardware Decoding) |
| **Right Encoder Phase A**| `ENC_R_A_PB6` | `PB6` | TIM4_CH1 (AF2) | J5 Pin 5 (Silicon Hardware Decoding) |
| **Right Encoder Phase B**| `ENC_R_B_PB7` | `PB7` | TIM4_CH2 (AF2) | J5 Pin 6 (Silicon Hardware Decoding) |
| **Battery Voltage Sense**| `VBAT_SENSE_PA4` | `PA4` | ADC1_IN4 (Analog) | Voltage divider (3S LiPo cutoff < 9.3V) |
| **Sensor Emitter Gate** | `EMITTER_GATE` | `PB14` | GPIO Output Push-Pull | J3 Pin 11 to 2N7002 Gate on Sensor Blade |
| **Sensor 1 (Far-Left)** | `S1_ADC` | `PC0` | ADC1_IN10 (Analog) | J3 Pin 3 (DMA Scan Index 0) |
| **Sensor 2** | `S2_ADC` | `PC1` | ADC1_IN11 (Analog) | J3 Pin 4 (DMA Scan Index 1) |
| **Sensor 3** | `S3_ADC` | `PC2` | ADC1_IN12 (Analog) | J3 Pin 5 (DMA Scan Index 2) |
| **Sensor 4 (Center-L)**| `S4_ADC` | `PC3` | ADC1_IN13 (Analog) | J3 Pin 6 (DMA Scan Index 3) |
| **Sensor 5 (Center-R)**| `S5_ADC` | `PC4` | ADC1_IN14 (Analog) | J3 Pin 7 (DMA Scan Index 4) |
| **Sensor 6** | `S6_ADC` | `PC5` | ADC1_IN15 (Analog) | J3 Pin 8 (DMA Scan Index 5) |
| **Sensor 7** | `S7_ADC` | `PB0` | ADC1_IN8 (Analog) | J3 Pin 9 (DMA Scan Index 6) |
| **Sensor 8 (Far-Right)**| `S8_ADC` | `PB1` | ADC1_IN9 (Analog) | J3 Pin 10 (DMA Scan Index 7) |
| **Active Buzzer** | `BUZZER_PB8` | `PB8` | GPIO Output Push-Pull | Base of S8050 NPN Transistor (Q3) |
| **Bluetooth TXD** | `BT_TXD_PA9` | `PA9` | USART1_TX (AF7) | J1 Pin 4 (HC-05 RXD @ 115200 / 9600) |
| **Bluetooth RXD** | `BT_RXD_PA10` | `PA10` | USART1_RX (AF7) | J1 Pin 3 (HC-05 TXD @ 115200 / 9600) |
| **Bluetooth State** | `BT_STATE_PB2` | `PB2` | GPIO Input Floating | J1 Pin 5 (HIGH when paired) |
| **Status LED** | `STATUS_LED_PA5`| `PA5` | GPIO Output Push-Pull | D3 Green LED via 1 kΩ |
| **User Pushbutton** | `USER_BTN_PC13` | `PC13` | GPIO Input Pull-up | SW_USER (Active-LOW with 10k pullup) |
| **SWD Clock** | `SWCLK` | `PA14` | SYS_JTCK-SWCLK | J2 Pin 3 (SWD 4-Pin Debug Header) |
| **SWD Data I/O** | `SWDIO` | `PA13` | SYS_JTMS-SWDIO | J2 Pin 2 (SWD 4-Pin Debug Header) |

---

## 3. PCB Layout & Manufacturing Guidelines

* **Dimensions**: $80\text{ mm} \times 50\text{ mm}$, 4-layer FR4, $1.6\text{ mm}$ thickness, $1\text{ oz}$ outer / $1\text{ oz}$ inner copper weight.
* **Stackup**:
  - **Layer 1 (Top / F.Cu)**: High-speed signal traces, local component routing, high-current $V_M$ power rails ($> 40\text{ mil}$ / $1.0\text{ mm}$ width).
  - **Layer 2 (In1.Cu)**: Solid, unbroken GND plane serving as immediate reference for impedance and high-frequency return paths.
  - **Layer 3 (In2.Cu)**: Power plane split into +5V Buck zone, +3.3V LDO zone, and +12V Motor zone.
  - **Layer 4 (Bottom / B.Cu)**: Low-speed signal routing and secondary ground flood stitched with via stitching grid ($5\text{ mm}$ pitch).
* **Thermal Management**:
  - Thermal relief copper pour under TB6612FNG (SSOP-24) connected through a $3 \times 3$ array of $0.3\text{ mm}$ vias into the inner ground plane.
  - High-current motor ground return paths are routed directly to the XT30 negative terminal, avoiding ground bounce across MCU analog inputs.
* **Decoupling Rule**:
  - Every single $V_{DD}$ pin pair on the STM32F446RE has a dedicated $100\text{ nF}$ 0603 X7R capacitor placed within $< 2.0\text{ mm}$ of the package pad.
