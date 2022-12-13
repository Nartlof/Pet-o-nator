#include <Arduino.h>
#include <Motor.h>

Motor::Motor(uint8_t control, uint8_t feebBack)
{
    pwmPin = control;
    tacoPin = feebBack;
    targetRPM = 0;
    measuredRPM = 0;
    pinMode(pwmPin, OUTPUT);
    stop();
    pinMode(feebBack, INPUT_PULLUP);
}

Motor::~Motor()
{
}

void Motor::setRPM(uint16_t RPM)
{
    if (RPM <= MaxRPM)
    {
        targetRPM = RPM;
    }
    else
    {
        targetRPM = MaxRPM;
    }
}

uint16_t Motor::getRPM()
{
    return targetRPM;
}

uint16_t Motor::readRPM()
{
    return measuredRPM;
}

void Motor::update()
{
    if (started)
    {
        // Write PID control here
    }
    else
    {
        analogWrite(pwmPin, 0);
    }
}

void Motor::start()
{
    started = true;
}

void Motor::stop()
{
    analogWrite(pwmPin, 0);
    started = false;
}