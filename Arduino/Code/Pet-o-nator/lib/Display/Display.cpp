#include <Display.h>

/**************************************************************************/
/*
    Display()

    Class constructor
*/
/**************************************************************************/
Display::Display(unsigned long diplaysRefreshTime)
{
    anyChange = true;
    started = false;
    targetSpeed = 0;
    targetTemperature = 0;
    measuredSpeed = 0;
    measuredTemperature = 0;
    refreshTime = diplaysRefreshTime;
    nextRefresh = millis();
    lLcd = LiquidCrystal_I2C(PCF8574_ADDR_A21_A11_A01, 4, 5, 6, 16, 11, 12, 13, 14, POSITIVE);
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

void Display::ajustValue(uint16_t *setting, float passedValue)
{
    uint16_t val = uint16_t round(passedValue);
    if (*setting != val)
    {
        anyChange = true;
        *setting = val;
    }
}

void Display::setTargetSpeed(float speed)
{
    ajustValue(&targetSpeed, speed);
}

void Display::setTargetTemperature(float temperature)
{
    ajustValue(&targetTemperature, temperature);
}

void Display::setMeasuredSpeed(float speed)
{
    ajustValue(&measuredSpeed, speed);
}

void Display::setMeasuredTemperature(float temperature)
{
    ajustValue(&measuredTemperature, temperature);
}

void Display::setStarted(bool start)
{
    started = start;
}

/**************************************************************************
 *
 *   update()

 *   Updates the display in case of any change

 *   NOTE:
 *   - If no value have changed since last update, nothing will happen

**************************************************************************/
void Display::update()
{
    if (anyChange && millis() > nextRefresh)
    {
        char buffer[21];
        lLcd.setCursor(0, 0);
        //               01234567890123456789
        lLcd.print(F("           Now  Goal"));
        sprintf(buffer, "Speed      %3d   %3d", measuredSpeed, targetSpeed);
        lLcd.print(buffer);
        sprintf(buffer, "Temp (C)   %3d   %3d", measuredTemperature, targetTemperature);
        lLcd.print(buffer);
        if (started)
        {
            lLcd.print(F(" (mm/min)    running"));
        }
        else
        {

            lLcd.print(F(" (mm/min)    stopped"));
        }
        anyChange = false;
        nextRefresh = millis() + refreshTime;
    }
}