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
    targetSpeed = 0;
    targetTemperature = 0;
    measuredSpeed = 0;
    measuredTemperature = 0;
    LiquidCrystal_I2C lLcd(PCF8574_ADDR_A21_A11_A01, 4, 5, 6, 16, 11, 12, 13, 14, POSITIVE);
}

Display::~Display()
{
}

void Display::initialize()
{
    lLcd.begin(20, 4);
    lLcd.clear();
    update();
}

void Display::ajustValue(uint16_t *setting, double passedValue)
{
    uint16_t val = uint16_t round(passedValue);
    if (*setting != val)
    {
        anyChange = true;
        *setting = val;
    }
}

void Display::setTargetSpeed(double speed)
{
    ajustValue(&targetSpeed, speed);
}

void Display::setTargetTemperature(double temperature)
{
    ajustValue(&targetTemperature, temperature);
}

void Display::setMeasuredSpeed(double speed)
{
    ajustValue(&measuredSpeed, speed);
}

void Display::setMeasuredTemperature(double temperature)
{
    ajustValue(&measuredTemperature, temperature);
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
        char buffer[21];
        lLcd.setCursor(0, 0);
        //               01234567890123456789
        lLcd.print(F("           Now  Goal"));
        sprintf(buffer, "Speed      %3d   %3d", measuredSpeed, targetSpeed);
        lLcd.print(buffer);
        sprintf(buffer, "Temp (C)   %3d   %3d", measuredTemperature, targetTemperature);
        lLcd.print(buffer);
        lLcd.print(F(" (mm/min)           "));
        anyChange = false;
    }
}