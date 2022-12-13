#include <Display.h>

/**************************************************************************/
/*
    Display()

    Class constructor
*/
/**************************************************************************/
Display::Display()
{
    anyChange = true;
    targetVelocity = 0;
    targetTemperature = 0;
    measuredVelocity = 0;
    measuredTemperature = 0;
    LiquidCrystal_I2C lLcd(PCF8574_ADDR_A21_A11_A01, 4, 5, 6, 16, 11, 12, 13, 14, POSITIVE);
}

Display::~Display()
{
}

void Display::initialize(){
    lLcd.begin(20, 4);
    lLcd.clear();
    update();
}

void Display::setTargetVelocity(double velocity)
{
    if (targetVelocity != velocity)
    {
        anyChange = true;
        targetVelocity = velocity;
    }
}

void Display::setTargetTemperature(double temperature)
{
    if (targetTemperature != temperature)
    {
        anyChange = true;
        targetTemperature = temperature;
    }
}

void Display::setMeasuredVelocity(double velocity)
{
    if (measuredVelocity != velocity)
    {
        anyChange = true;
        measuredVelocity = velocity;
    }
}

void Display::setMeasuredTemperature(double temperature)
{
    if (measuredTemperature != temperature)
    {
        anyChange = true;
        measuredTemperature = temperature;
    }
}

/**************************************************************************/
/*
    update()

    Updates the display in case of any change

    NOTE:
    - If no value have changed since last update, nothing will happen
*/
/**************************************************************************/
void Display::update()
{
    if (anyChange)
    {
        lLcd.setCursor(0, 0);
        //            01234567890123456789
        lLcd.print(F("      Temp.  Speed  "));
        lLcd.setCursor(0, 1);
        lLcd.print(F("       (C)   (mm/s) "));
        anyChange = false;
    }
}