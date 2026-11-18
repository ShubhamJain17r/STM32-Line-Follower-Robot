/**
 * @file motor_subsystem.hpp
 * @brief High-performance dual DC motor actuator pipeline using ultrasonic 20 kHz PWM and TB6612FNG.
 *
 * Provides deadband compensation, static friction overcoming duty cycle,
 * differential steering mixing, and active dynamic short-braking.
 */

#pragma once

#include <cstdint>

#include "stm32/timer/timer.hpp"
#include "components/actuators/tb6612fng/tb6612fng.hpp"
#include "robot_config.hpp"

namespace robot
{

class MotorSubsystem
{
public:
    MotorSubsystem();
    ~MotorSubsystem() = default;

    MotorSubsystem(const MotorSubsystem&) = delete;
    MotorSubsystem& operator=(const MotorSubsystem&) = delete;

    /**
     * @brief Initialize 20 kHz timer PWM channels, direction GPIOs, and standby manager.
     * @return true if initialization succeeded.
     */
    bool init() noexcept;

    /**
     * @brief Set normalized motor speeds in range [-1.0f, +1.0f].
     *
     * @param leftSpeed Left motor speed (-1.0 = full reverse, +1.0 = full forward)
     * @param rightSpeed Right motor speed (-1.0 = full reverse, +1.0 = full forward)
     */
    void setSpeeds(float leftSpeed, float rightSpeed) noexcept;

    /**
     * @brief Differential drive steering mixer.
     *
     * @param throttle Forward/reverse throttle in [-1.0f, +1.0f]
     * @param steering Steering bias in [-1.0f, +1.0f] (positive turns right, negative turns left)
     */
    void drive(float throttle, float steering) noexcept;

    /**
     * @brief Actively short-brake both motors (shorts H-bridge outputs to ground).
     */
    void brake() noexcept;

    /**
     * @brief Freewheel coast both motors (High-Z floating outputs).
     */
    void coast() noexcept;

    /**
     * @brief Enter low-power standby mode.
     */
    void standby() noexcept;

    /**
     * @brief Wake from standby mode.
     */
    void wake() noexcept;

    [[nodiscard]] float getLeftSpeed() const noexcept;
    [[nodiscard]] float getRightSpeed() const noexcept;
    [[nodiscard]] bool isStandby() const noexcept;

private:
    timer::PwmHandler<config::MOTOR_PWM_TIMER>                           pwm_;
    components::actuators::tb6612fng::Tb6612Fng<config::MOTOR_PWM_TIMER> motors_;
};

} // namespace robot
