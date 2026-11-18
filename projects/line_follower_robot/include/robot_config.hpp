/**
 * @file robot_config.hpp
 * @brief Centralized hardware pin definitions, peripheral mappings, and physical tuning parameters.
 *
 * Designed for 1:1 hardware portability between NUCLEO-F446RE prototyping
 * and custom competition PCB manufacturing.
 */

#pragma once

#include <cstdint>
#include <array>

#include "stm32/gpio/gpio.hpp"
#include "stm32/adc/adc.hpp"
#include "stm32/timer/timer.hpp"
#include "stm32/uart/uart.hpp"

namespace robot::config
{

// =============================================================================
// 1. SENSOR ARRAY CONFIGURATION (QTR-8A / Analog Reflectance Array)
// =============================================================================
constexpr std::size_t NUM_SENSORS = 8;

// Physical GPIO Pins connected to Sensor Array Outputs (Analog Mode)
constexpr std::array<gpio::Pin, NUM_SENSORS> SENSOR_PINS = {
    gpio::PC0, // S1: Far Left       -> ADC1_IN10
    gpio::PC1, // S2: Left-Mid Outer -> ADC1_IN11
    gpio::PC2, // S3: Left-Mid Inner -> ADC1_IN12
    gpio::PC3, // S4: Center Left    -> ADC1_IN13
    gpio::PC4, // S5: Center Right   -> ADC1_IN14
    gpio::PC5, // S6: Right-Mid Inner-> ADC1_IN15
    gpio::PB0, // S7: Right-Mid Outer-> ADC1_IN8
    gpio::PB1  // S8: Far Right      -> ADC1_IN9
};

// Corresponding ADC1 Channels in scan order
constexpr std::array<adc::Channel, NUM_SENSORS> SENSOR_ADC_CHANNELS = {
    adc::Channel::IN10,
    adc::Channel::IN11,
    adc::Channel::IN12,
    adc::Channel::IN13,
    adc::Channel::IN14,
    adc::Channel::IN15,
    adc::Channel::IN8,
    adc::Channel::IN9
};

// Sensor Range Constants
constexpr std::int32_t SENSOR_MIN_POSITION   = 0;
constexpr std::int32_t SENSOR_CENTER_POSITION = 3500;
constexpr std::int32_t SENSOR_MAX_POSITION   = 7000;
constexpr std::uint32_t SENSOR_LOST_LINE_THRESHOLD = 200; // Sum of reflections below this = track lost
constexpr std::uint32_t SENSOR_CALIB_DURATION_MS   = 3000;

// =============================================================================
// 2. MOTOR DRIVER ACTUATOR CONFIGURATION (TB6612FNG Dual DC Motor Driver)
// =============================================================================
// Timer Instance for 20 kHz PWM
constexpr timer::Instance MOTOR_PWM_TIMER = timer::Instance::tim2;

// Motor A (Left Wheel)
constexpr gpio::Pin       PIN_PWMA = gpio::PA0; // TIM2_CH1 (AF1)
constexpr timer::Channel  CH_PWMA  = timer::Channel::CH1;
constexpr gpio::Pin       PIN_AIN1 = gpio::PC6; // Direction 1
constexpr gpio::Pin       PIN_AIN2 = gpio::PC7; // Direction 2

// Motor B (Right Wheel)
constexpr gpio::Pin       PIN_PWMB = gpio::PA1; // TIM2_CH2 (AF1)
constexpr timer::Channel  CH_PWMB  = timer::Channel::CH2;
constexpr gpio::Pin       PIN_BIN1 = gpio::PC8; // Direction 1
constexpr gpio::Pin       PIN_BIN2 = gpio::PC9; // Direction 2

// Standby Pin (Active-HIGH)
constexpr gpio::Pin       PIN_STBY = gpio::PC10;

// PWM Frequency: 20 kHz (eliminates audible motor whine)
constexpr std::uint32_t   MOTOR_PWM_FREQUENCY_HZ = 20'000;

// Tuning & Stiction Compensation
constexpr float           MOTOR_DEADBAND = 0.05f; // Ignore jitter near 0
constexpr float           MOTOR_MIN_DUTY = 0.15f; // Minimum duty to break N20 gearbox static friction

// Inversion flags (set true if gearbox or wheel is wired with inverted polarity)
constexpr bool            MOTOR_A_INVERTED = false;
constexpr bool            MOTOR_B_INVERTED = false;

// =============================================================================
// 3. WIRELESS TELEMETRY CONFIGURATION (HC-05 Bluetooth Module)
// =============================================================================
constexpr uart::Instance  TELEMETRY_UART = uart::Instance::usart1;
constexpr std::uint32_t   TELEMETRY_BAUDRATE = 115'200;
constexpr gpio::Pin       PIN_BT_TX = gpio::PB6; // STM32 TX -> HC-05 RX
constexpr gpio::Pin       PIN_BT_RX = gpio::PB7; // STM32 RX <- HC-05 TX
constexpr gpio::Pin       PIN_BT_STATE = gpio::PB2; // Connection indicator
constexpr gpio::Pin       PIN_BT_KEY   = gpio::PB12; // AT Mode control

// =============================================================================
// 4. ONBOARD USER INTERFACE CONFIGURATION (Nucleo-64)
// =============================================================================
constexpr gpio::Pin       PIN_STATUS_LED  = gpio::PA5;  // Onboard Green LED (LD2)
constexpr gpio::Pin       PIN_USER_BUTTON = gpio::PC13; // Onboard Blue Pushbutton (B1)

// =============================================================================
// 5. DETERMINISTIC CONTROL LOOP TIMEBASE
// =============================================================================
constexpr std::uint32_t   CONTROL_LOOP_FREQ_HZ = 1000; // 1.0 ms period
constexpr float           CONTROL_LOOP_DT_SEC  = 0.001f;

// =============================================================================
// 6. PHYSICAL ROBOT KINEMATICS
// =============================================================================
constexpr float           WHEEL_DIAMETER_METERS   = 0.042f; // 42 mm tires
constexpr float           MAX_LINEAR_VELOCITY_MPS = 1.32f;  // ~1.32 m/s @ 600 RPM

} // namespace robot::config
