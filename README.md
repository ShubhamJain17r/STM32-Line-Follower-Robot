# STM32-Projects: Layer 3 Applications & Embedded Robotics

Production-grade embedded applications and robotics systems targeting the **STM32F446RE** microcontroller (ARM Cortex-M4F @ 180 MHz), tested on the NUCLEO-F446RE development board and ready for custom PCB deployment.

---

## Architecture Overview

This repository represents **Layer 3 (Application Layer)** in our modular embedded architecture. It consumes two linked Git submodules in `lib/`:

```
STM32-Projects/
├── lib/
│   ├── STM32-Library/               # [Layer 1] Bare-metal C++17 Peripheral Engine
│   │   ├── Inc/stm32/               # (GPIO, ADC, PWM, Timers, UART, SPI, I2C, DMA, SysTick)
│   │   └── Drivers/CMSIS/           # Official CMSIS Core and STM32F4xx headers
│   │
│   └── STM32-Components/            # [Layer 2] External Sensor & Actuator Drivers
│       └── include/components/      # (TB6612FNG, QTR-8A, HC-05, ADXL345, SSD1306, etc.)
│
├── projects/                        # [Layer 3] Standalone Application Projects
│   └── line_follower_robot/         # High-Speed Competition Line Following Robot
│
├── CMakeLists.txt                   # Root CMake build orchestrator
├── Makefile                         # Unified root Makefile runner
└── README.md                        # Documentation and project index
```

---

## Projects Index

| Project | Target MCU | Key Hardware / Sensors | Status |
| :--- | :--- | :--- | :--- |
| **`projects/line_follower_robot`** | STM32F446RE | 8-Ch QTR Reflectance Array, TB6612FNG, N20 600 RPM Motors, HC-05 Bluetooth | Active (Phase 1) |

---

## Build Instructions

### Prerequisites
- GNU ARM Embedded Toolchain (`arm-none-eabi-gcc` / `g++` 7.2.1+)
- GNU Make 4.0+ or CMake 3.16+
- OpenOCD or `st-flash` for flashing to NUCLEO-F446RE

### Building via Makefile
```bash
# Build default project (projects/line_follower_robot)
make

# Build specific project
make PROJECT=projects/line_follower_robot

# Check binary footprint
make size

# Flash to Nucleo board via OpenOCD
make flash

# Flash via ST-Link utility
make flash-stlink

# Clean build artifacts
make clean
```

---

## Coding & Architectural Standards

1. **Bare-Metal C++17 (No RTOS, Zero Vendor HAL Bloat)**:
   - Direct register manipulation and lightweight zero-cost C++ abstractions.
   - Strictly `-fno-exceptions -fno-rtti -fno-use-cxa-atexit`.
2. **Zero Dynamic Memory Allocation**:
   - Heap footprint = 0 bytes. All buffers, queues, and structures are statically or stack allocated.
3. **Hardware Independence & Custom PCB Readiness**:
   - Pin definitions and peripheral configurations are cleanly isolated in `robot_config.hpp` files.
