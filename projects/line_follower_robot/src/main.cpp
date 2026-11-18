/**
 * @file main.cpp
 * @brief High-Speed Competition Line Following Robot - Phase 1 Integration Firmware.
 *
 * Validates:
 * 1. Continuous 8-channel ADC acquisition via circular DMA (SensorSubsystem).
 * 2. Dynamic optical calibration sweep across track and surface.
 * 3. Weighted centroid calculation with lost-line memory.
 * 4. Ultrasonic 20 kHz dual-channel PWM actuator control (MotorSubsystem).
 * 5. Proportional steering and dynamic short-braking safety cutoff.
 */

#include <cstdint>
#include <array>

#include "stm32/common/systick/systick.hpp"
#include "stm32/gpio/gpio.hpp"

#include "robot_config.hpp"
#include "sensor_subsystem.hpp"
#include "motor_subsystem.hpp"

using namespace robot;

int main()
{
    // -------------------------------------------------------------------------
    // 1. Core System Initializations
    // -------------------------------------------------------------------------
    // Initialize SysTick monotonic 1.0 ms timebase
    systick::init(1000);

    // Initialize Onboard User LED (PA5) and User Pushbutton (PC13)
    gpio::DigitalOutput statusLed{config::PIN_STATUS_LED};
    gpio::DigitalInput  userButton{config::PIN_USER_BUTTON, gpio::Pull::UP};

    statusLed.high(); // Turn LED on during boot

    // -------------------------------------------------------------------------
    // 2. Subsystem Initializations
    // -------------------------------------------------------------------------
    SensorSubsystem sensors;
    if (!sensors.init())
    {
        // Fault state: rapid blink indicates sensor init failure
        while (true)
        {
            statusLed.toggle();
            systick::delayMs(50);
        }
    }

    MotorSubsystem motors;
    if (!motors.init())
    {
        // Fault state: slow blink indicates motor init failure
        while (true)
        {
            statusLed.toggle();
            systick::delayMs(200);
        }
    }

    // -------------------------------------------------------------------------
    // 3. Dynamic Optical Sensor Calibration Phase
    // Sweep the robot sensor array manually or automatically across track/floor.
    // -------------------------------------------------------------------------
    statusLed.high(); // Solid ON indicates calibration in progress

    const std::uint32_t calibStartTime = systick::millis();
    while ((systick::millis() - calibStartTime) < config::SENSOR_CALIB_DURATION_MS)
    {
        sensors.updateCalibration();
        systick::delayMs(5);
    }

    statusLed.low(); // LED OFF indicates calibration completed
    systick::delayMs(500);

    // -------------------------------------------------------------------------
    // 4. Phase 1 Motor Actuator Self-Test Sweep
    // Brief forward ramp and short-brake to verify 20 kHz PWM and H-bridge
    // -------------------------------------------------------------------------
    for (float speed = 0.0f; speed <= 0.35f; speed += 0.05f)
    {
        motors.setSpeeds(speed, speed);
        systick::delayMs(40);
    }
    systick::delayMs(150);
    motors.brake();
    systick::delayMs(300);

    // -------------------------------------------------------------------------
    // 5. Deterministic Control & Line Tracking Loop
    // -------------------------------------------------------------------------
    std::array<std::uint16_t, config::NUM_SENSORS> calibratedReadings{0};

    std::uint32_t lastControlTime = systick::millis();

    while (true)
    {
        const std::uint32_t now = systick::millis();

        // Enforce 1.0 ms deterministic control period (1 kHz rate)
        if ((now - lastControlTime) >= 1)
        {
            lastControlTime = now;

            // 1. Sample weighted centroid line position directly from circular DMA
            const std::int32_t linePosition = sensors.readLine(calibratedReadings);
            const bool lineDetected = sensors.isLineDetected();

            // 2. Status LED indicates line detection health
            statusLed.write(lineDetected ? gpio::PinState::HIGH : gpio::PinState::LOW);

            if (lineDetected)
            {
                // Steering error: range [-3500, +3500]
                const std::int32_t error = linePosition - sensors.getCenterPosition();

                // Phase 1 Normalized Proportional Steering: [-0.6f, +0.6f]
                float steering = static_cast<float>(error) / static_cast<float>(config::SENSOR_CENTER_POSITION);
                if (steering > 0.6f)  steering = 0.6f;
                if (steering < -0.6f) steering = -0.6f;

                // Drive with baseline exploration throttle
                constexpr float BASE_THROTTLE = 0.35f;
                motors.drive(BASE_THROTTLE, steering);
            }
            else
            {
                // Track lost safety response: active dynamic short-brake
                motors.brake();
            }
        }
    }

    return 0;
}
