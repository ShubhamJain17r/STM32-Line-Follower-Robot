# Autonomous High-Speed Closed-Loop Line Following Robot

Production-grade, competition-oriented autonomous line following robot built on the **STM32F446RE** microcontroller (ARM Cortex-M4F @ 180 MHz), featuring bare-metal C++17 closed-loop PID control, dual hardware quadrature encoders, 20 kHz ultrasonic PWM, active ambient light rejection, and a modular two-board PCB architecture.

---

## 1. System Specifications & Features

| Metric / Parameter | Value / Implementation | Notes |
| :--- | :--- | :--- |
| **Microcontroller** | STM32F446RET6 (180 MHz ARM Cortex-M4F) | 512 KB Flash, 128 KB SRAM, LQFP-64 |
| **Wheel Diameter** | **42 mm** ($\text{Circumference } \approx 131.95\text{ mm}$) | High-traction rubber tires |
| **Top Linear Velocity** | **$\approx 1.32\text{ m/s}$ ($4.75\text{ km/h}$)** | N20 12V 600 RPM gearmotors (30:1 ratio) |
| **Encoders** | 2× Magnetic Hall Quadrature (1440 CPR) | **TIM3 & TIM4 Silicon Hardware Decoding (0% CPU)** |
| **Motor Driver** | Toshiba TB6612FNG Dual H-Bridge IC | **20 kHz Ultrasonic PWM on TIM2**, `STBY` tied to 3.3V |
| **Optical Sensor Blade**| 8× Vishay QRE1113GR @ 7.5 mm pitch | **Continuous Circular DMA ADC1**, `AutoDifferential` Rejection |
| **Ambient Rejection** | 2N7002 N-Channel MOSFET Gate | Active ambient sunlight & fluorescent light subtraction |
| **Steering Controller** | 1 kHz Discrete PID with Derivative Filter | Anti-windup clamping, dynamic curvature slowdown |
| **Battery Protection** | 3S LiPo Voltage Divider on `PA4` | Warning at $< 9.9\text{V}$, Emergency Cutoff at $< 9.3\text{V}$ |
| **Audio Feedback** | Active Buzzer on `PB8` | Non-blocking boot chime and low-battery alarms |
| **Wireless Telemetry** | HC-05 Bluetooth on USART1 (`PA9`/`PA10`) | Framed packets: `<START>`, `<STOP>`, `<KP:val>`, `<KD:val>` |

---

## 2. Repository Architecture

```
STM32-Line-Follower-Robot/
├── apps/
│   └── line_follower/               # Primary Consumer Firmware Application
│       ├── CMakeLists.txt           # Application CMake build
│       ├── Makefile                 # Application Makefile build
│       ├── include/
│       │   ├── robot_config.hpp     # Hardware pin assignments & tuning constants
│       │   ├── sensor_subsystem.hpp # 8-channel DMA ADC & AutoDifferential ambient rejection
│       │   ├── drive_subsystem.hpp  # TB6612 (HardwareTiedHigh STBY) & dual encoders
│       │   ├── battery_monitor.hpp  # 3S LiPo ADC voltage monitor with low-voltage protection
│       │   ├── telemetry_manager.hpp# HC-05 packet parser (<KP:...>, <KD:...>, <SPEED:...>, etc.)
│       │   └── robot_controller.hpp # Finite State Machine (Init, Calib, Ready, Track, Lost, Stop)
│       └── src/
│           ├── main.cpp             # 1 kHz deterministic control loop
│           ├── sensor_subsystem.cpp
│           ├── drive_subsystem.cpp
│           ├── battery_monitor.cpp
│           ├── telemetry_manager.cpp
│           └── robot_controller.cpp
│
├── hardware/                        # KiCad 8 / 7 Hardware Designs
│   ├── motherboard/                 # Board 1: STM32F446 + TB6612 + Buck/LDO + HC-05
│   │   └── README.md                # Schematics & routing specifications
│   ├── sensor_blade/                # Board 2: 8x QRE1113GR + 2N7002 MOSFET Blade
│   │   └── README.md                # Optical pitch, clearance, and ribbon pinout
│   └── gerbers/                     # Production Gerbers for JLCPCB / PCBWay
│
├── mechanical/                      # 3D Chassis CAD & 3D Print Files
│   ├── README.md                    # Dimensions, wheel clearance, 3D printing specs
│   ├── cad/                         # STEP / CAD assembly models
│   └── 3d_print_stls/               # Ball caster bracket, N20 motor mounts
│
├── lib/                             # Submodules
│   ├── STM32-Components/            # [Layer 2] Device Drivers (TB6612, QTR, Encoder, Buzzer)
│   └── STM32-Library/               # [Layer 1] Bare-Metal Peripheral Engine
│
├── CMakeLists.txt                   # Root CMake orchestrator
├── Makefile                         # Unified root Makefile
└── README.md                        # Product documentation
```

---

## 3. Hardware Pinout Allocation

| Function | Signal | Pin | Alternate Function / Mode | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Motor PWM (TB6612FNG)** | PWMA (Left) | `PA0` | TIM2_CH1 (AF1) | 20 kHz ultrasonic PWM |
| | PWMB (Right) | `PA1` | TIM2_CH2 (AF1) | 20 kHz ultrasonic PWM |
| **Motor Direction** | AIN1, AIN2 | `PC8`, `PC9` | GPIO Output Push-Pull | Atomic BSRR direction |
| | BIN1, BIN2 | `PC11`, `PC12` | GPIO Output Push-Pull | Atomic BSRR direction |
| **Motor Standby** | STBY | N/A | Hardware Tied High | Hardwired to 3.3V on PCB trace (0 GPIOs wasted) |
| **Encoder Left (TIM3)** | ENC_L_A, ENC_L_B | `PA6`, `PA7` | TIM3_CH1, CH2 (AF2) | 1440 CPR hardware decoding |
| **Encoder Right (TIM4)** | ENC_R_A, ENC_R_B | `PB6`, `PB7` | TIM4_CH1, CH2 (AF2) | 1440 CPR hardware decoding |
| **Sensor Blade (QRE1113GR)**| S1 .. S8 | `PC0`..`PC5`, `PB0`, `PB1` | ADC1_IN10..15, IN8, IN9 | Circular DMA Scan |
| **Sensor Emitter MOSFET** | EMITTER_GATE | `PB14` | GPIO Output Push-Pull | 2N7002 gate (AutoDifferential ambient rejection) |
| **Battery Voltage Monitor** | VBAT_SENSE | `PA4` | ADC1_IN4 (Analog) | Voltage divider (3S LiPo alarm < 9.9V) |
| **Active Buzzer** | BUZZER | `PB8` | GPIO Output Push-Pull | Non-blocking tones and alarms |
| **HC-05 Bluetooth (USART1)**| BT_TX, BT_RX | `PA9`, `PA10` | USART1_TX, RX (AF7) | 9600 baud wireless telemetry & PID tuning |
| | BT_STATE | `PB2` | GPIO Input Floating | HIGH when paired/connected |
| **UI & Indicators** | STATUS LED | `PA5` | GPIO Output Push-Pull | Nucleo onboard LD2 |
| | USER BUTTON | `PC13` | GPIO Input Pull-Up | Nucleo onboard B1 |

---

## 4. Build Instructions

### Prerequisites
- GNU ARM Embedded Toolchain (`arm-none-eabi-gcc` / `g++` 7.2.1+)
- GNU Make 4.0+ or CMake 3.16+
- OpenOCD or `st-flash`

### Compiling & Flashing
```bash
# Build firmware binary
make

# Check binary footprint
make size

# Flash to STM32F446RE via OpenOCD
make flash

# Flash via ST-Link utility
make flash-stlink

# Clean build artifacts
make clean
```

### Memory Footprint
```
   text    data     bss     dec     hex filename
  35884     504    3724   40112    9cb0 build/line_follower.elf
```
* **Flash**: `36.3 KB` (~7.1% of 512 KB Flash).
* **SRAM**: `4.2 KB` (~3.3% of 128 KB SRAM).
* **Heap**: **0 bytes** (zero dynamic memory allocation).

---

## 5. Wireless Tuning & Telemetry Interface

Connect via Bluetooth SPP at 9600 baud to the HC-05 module:

| Command | Action | Example |
| :--- | :--- | :--- |
| `<START>` | Arms and starts closed-loop tracking | `<START>` |
| `<STOP>` | Emergency stops and brakes both motors | `<STOP>` |
| `<CALIB>` | Initiates dynamic 3-second sensor sweep | `<CALIB>` |
| `<KP:value>` | Updates steering proportional gain | `<KP:0.00075>` |
| `<KI:value>` | Updates steering integral gain | `<KI:0.00002>` |
| `<KD:value>` | Updates steering derivative gain | `<KD:0.00035>` |
| `<SPEED:value>` | Sets baseline straightaway throttle in [0.1, 1.0] | `<SPEED:0.70>` |
