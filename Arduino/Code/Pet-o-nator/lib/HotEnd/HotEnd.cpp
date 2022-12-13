#include <Arduino.h>
#include <HotEnd.h>

HotEnd::HotEnd(uint8_t control, uint8_t feedBack1, uint8_t feedBack2)
{
    hotEndPWM = control;
    hotEndFeedBack1 = feedBack1;
    hotEndFeedBack2 = feedBack2;
    targetTemperature = 0;
    measuredTemperature = 0;
    pinMode(hotEndPWM, OUTPUT);
    stop();
    pinMode(hotEndFeedBack1, INPUT);
    pinMode(hotEndFeedBack2, INPUT);
}

HotEnd::~HotEnd()
{
}

void HotEnd::setTemperature(double Temperature)
{
    if (Temperature <= MaxTemperature)
    {
        targetTemperature = Temperature;
    }
    else
    {
        targetTemperature = 0;
    }
}

double HotEnd::getTemperature()
{
    return targetTemperature;
}

double HotEnd::readTemperature()
{
    return measuredTemperature;
}

void HotEnd::update()
{
    // put PWM here
}

void HotEnd::start()
{
    started = true;
}

void HotEnd::stop()
{
    started = false;
    analogWrite(hotEndPWM, 0);
}