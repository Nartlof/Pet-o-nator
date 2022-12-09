#include <Arduino.h>
#include <Display.h>

Display::Display()
{
    lcdDisplay = new LiquidCrystal_I2C(PCF8574_ADDR_A21_A11_A01, 4, 5, 6, 16, 11, 12, 13, 14, POSITIVE);
    lcdDisplay->begin(20, 4);
    lcdDisplay->clear();
    lcdDisplay->setCursor(0, 0);
    lcdDisplay->print(F("Initializing..."));
    newTargetVelocity = 0;
    oldTargetVelocity = -1;
    newTargetTemperature = 0;
    oldTargetTemperature = -1;
    newMeasuredVelocity = 0;
    oldMeasuredVelocity = -1;
    newMeasuredTemperature = 0;
    oldMeasuredTemperature = -1;
}

Display::~Display()
{
}

void Display::setTargetVelocity(double velocity)
{
    newTargetVelocity = velocity;
}

void Display::setTargetTemperature(double temperature)
{
    newTargetTemperature = temperature;
}

void Display::setMeasuredVelocity(double velocity)
{
    newMeasuredVelocity = velocity;
}

void Display::setMeasuredTemperature(double temperature)
{
    newMeasuredTemperature = temperature;
}