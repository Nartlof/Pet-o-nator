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

void Motor::setRPM(double RPM)
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

double Motor::getRPM()
{
    return targetRPM;
}

double Motor::readRPM()
{
    return measuredRPM;
}

void Motor::setSpeed(double speed)
{
    setRPM(speed * SpeedToRpm);
}

double Motor::getSpeed()
{
    return round(targetRPM / SpeedToRpm);
}

double Motor::readSpeed()
{
    return round(measuredRPM / SpeedToRpm);
}

void Motor::incSpeed()
{
    if (targetRPM < MaxRPM)
    {
        targetRPM += SpeedToRpm;
        if (targetRPM > MaxRPM)
        {
            targetRPM = MaxRPM;
        }
    }
}

void Motor::decSpeed()
{
    if (targetRPM > 0)
    {
        targetRPM -= SpeedToRpm;
        if (targetRPM < 0)
        {
            targetRPM = 0;
        }
    }
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

bool Motor::isStarted() { return started; }

void Motor::stop()
{
    analogWrite(pwmPin, 0);
    started = false;
}