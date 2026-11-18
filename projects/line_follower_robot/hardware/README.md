# High-Speed Line Follower Robot Hardware Specification

Target Microcontroller: **STM32F446RE** (ARM Cortex-M4F @ 180 MHz, LQFP-64 package)
Deployment Platforms:
1. **NUCLEO-F446RE Development Board** (Rapid prototyping / breadboard verification)
2. **Custom Modular Competition PCB** (Low-inductance, direct bare-IC deployment)

---

## Complete MCU Pinout Allocation

| Function | Signal | Physical Pin | Alternate Function / Mode | Description |
| :--- | :--- | :--- | :--- | :--- |
| **QTR-8A Sensor Array** | S1 (Far Left) | `PC0` | ADC1_IN10 (Analog) | DMA circular scan index 0 |
| | S2 | `PC1` | ADC1_IN11 (Analog) | DMA circular scan index 1 |
| | S3 | `PC2` | ADC1_IN12 (Analog) | DMA circular scan index 2 |
| | S4 (Center Left) | `PC3` | ADC1_IN13 (Analog) | DMA circular scan index 3 |
| | S5 (Center Right) | `PC4` | ADC1_IN14 (Analog) | DMA circular scan index 4 |
| | S6 | `PC5` | ADC1_IN15 (Analog) | DMA circular scan index 5 |
| | S7 | `PB0` | ADC1_IN8 (Analog) | DMA circular scan index 6 |
| | S8 (Far Right) | `PB1` | ADC1_IN9 (Analog) | DMA circular scan index 7 |
| **TB6612FNG Motor Driver** | PWMA (Left Motor) | `PA0` | TIM2_CH1 (AF1) | 20 kHz ultrasonic PWM |
| | AIN1 | `PC6` | GPIO Output Push-Pull | Atomic BSRR direction |
| | AIN2 | `PC7` | GPIO Output Push-Pull | Atomic BSRR direction |
| | PWMB (Right Motor)| `PA1` | TIM2_CH2 (AF1) | 20 kHz ultrasonic PWM |
| | BIN1 | `PC8` | GPIO Output Push-Pull | Atomic BSRR direction |
| | BIN2 | `PC9` | GPIO Output Push-Pull | Atomic BSRR direction |
| | STBY | `PC10` | GPIO Output Push-Pull | Active-HIGH (or tied to 3.3V on PCB) |
| **HC-05 Telemetry** | TX (MCU -> BT) | `PB6` | USART1_TX (AF7) | Telemetry & tuning link |
| | RX (MCU <- BT) | `PB7` | USART1_RX (AF7) | Command parser link |
| | STATE | `PB2` | GPIO Input Floating | HIGH when paired/connected |
| | KEY / EN | `PB12` | GPIO Output Push-Pull | AT mode selection |
| **UI & Indicators** | STATUS LED | `PA5` | GPIO Output Push-Pull | Nucleo-64 Green LED (LD2) |
| | USER BUTTON | `PC13` | GPIO Input Pull-up | Nucleo-64 Blue Button (B1) |

---

## Power Distribution & Actuator Specs
* **Motors**: 2× N20 12 V DC 600 RPM micro metal gear motors (no encoders).
* **Wheels**: 42 mm diameter rubber tires.
  * Circumference = $\pi \times 42\text{ mm} \approx 131.95\text{ mm}$.
  * At 600 RPM ($10\text{ rev/s}$): Theoretical max velocity $\approx 1.32\text{ m/s}$.
* **Battery**: 3S Li-ion battery pack ($11.1\text{ V}$ nominal, $12.6\text{ V}$ peak, $9.0\text{ V}$ cutoff).
* **Logic Rail**: $3.3\text{ V}$ regulated via low-dropout regulator (LDO) on board.
