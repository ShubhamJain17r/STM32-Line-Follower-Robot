/**
 * @file motor_subsystem.cpp
 * @brief Implementation of ultrasonic 20 kHz dual motor actuator pipeline.
 */

#include "motor_subsystem.hpp"

namespace robot
{

namespace
{
components::actuators::tb6612fng::ChannelConfig makeChannelConfig(bool inverted) noexcept
{
    components::actuators::tb6612fng::ChannelConfig cfg;
    cfg.inverted      = inverted;
    cfg.deadband      = config::MOTOR_DEADBAND;
    cfg.minDuty       = config::MOTOR_MIN_DUTY;
    cfg.zeroSpeedMode = components::actuators::tb6612fng::ZeroSpeedMode::Brake;
    return cfg;
}
} // anonymous namespace

MotorSubsystem::MotorSubsystem()
    : pwm_(config::MOTOR_PWM_FREQUENCY_HZ),
      motors_(config::PIN_AIN1, config::PIN_AIN2, pwm_, config::CH_PWMA,
              config::PIN_BIN1, config::PIN_BIN2, pwm_, config::CH_PWMB,
              config::PIN_STBY,
              makeChannelConfig(config::MOTOR_A_INVERTED),
              makeChannelConfig(config::MOTOR_B_INVERTED))
{
}

bool MotorSubsystem::init() noexcept
{
    // 1. Start TIM2 counter for 20 kHz ultrasonic PWM
    pwm_.start();

    // 2. Initialize GPIO direction pins, standby manager, and timer channels
    const bool ok = motors_.init(config::PIN_PWMA, config::PIN_PWMB);

    // 3. Ensure standby is disabled and motors start in short-braked state
    motors_.wake();
    motors_.brake();

    return ok;
}

void MotorSubsystem::setSpeeds(float leftSpeed, float rightSpeed) noexcept
{
    motors_.setSpeeds(leftSpeed, rightSpeed);
}

void MotorSubsystem::drive(float throttle, float steering) noexcept
{
    motors_.drive(throttle, steering);
}

void MotorSubsystem::brake() noexcept
{
    motors_.brake();
}

void MotorSubsystem::coast() noexcept
{
    motors_.coast();
}

void MotorSubsystem::standby() noexcept
{
    motors_.standby();
}

void MotorSubsystem::wake() noexcept
{
    motors_.wake();
}

float MotorSubsystem::getLeftSpeed() const noexcept
{
    return motors_.a().getSpeed();
}

float MotorSubsystem::getRightSpeed() const noexcept
{
    return motors_.b().getSpeed();
}

bool MotorSubsystem::isStandby() const noexcept
{
    return motors_.isStandby();
}

} // namespace robot
