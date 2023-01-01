/*
Define the control for the LCD display
This class was writen for a 4x20 I2C display
Autor: Carlos Eduardo Foltran
Date: 2022-12-09
*/

#pragma once

#ifndef PetonatorDISPLAY
#define PetonatorDISPLAY

#include <Arduino.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#define LCD_SPACE_SYMBOL 0x20 // space symbol from the LCD ROM, see p.9 of GDM2004D datasheet

#ifndef DiplayRefreshTime
#define DiplayRefreshTime 128 // The amount of time between two refreshes
#endif

class Display
{
private:
    /* data */
    uint16_t targetSpeed;
    uint16_t targetTemperature;
    uint16_t measuredSpeed;
    uint16_t measuredTemperature;
    bool anyChange;
    unsigned long nextRefresh;
    unsigned long refreshTime;
    LiquidCrystal_I2C lLcd;
    void ajustValue(uint16_t *, double); // rounds and ajusts the value for the sets

public:
    Display(unsigned long diplaysRefreshTime);
    ~Display();
    void initialize();
    void setTargetSpeed(double speed);
    void setTargetTemperature(double temperature);
    void setMeasuredSpeed(double speed);
    void setMeasuredTemperature(double temperature);
    void update(); // must be on the main loop
};

#endif