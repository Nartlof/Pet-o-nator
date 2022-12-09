/*
Define the control for the LCD display
This class was writen for a 4x20 I2C display
Autor: Carlos Eduardo Foltran
Date: 2022-12-09
*/

#ifndef PetonatorDISPLAY
#define PetonatorDISPLAY

#include <Arduino.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

class Display
{
private:
    /* data */
    LiquidCrystal_I2C *lcdDisplay;
    double newTargetVelocity;
    double oldTargetVelocity;
    double newTargetTemperature;
    double oldTargetTemperature;
    double newMeasuredVelocity;
    double oldMeasuredVelocity;
    double newMeasuredTemperature;
    double oldMeasuredTemperature;

public:
    Display();
    ~Display();
    void setTargetVelocity(double velocity);
    void setTargetTemperature(double temperature);
    void setMeasuredVelocity(double velocity);
    void setMeasuredTemperature(double temperature);
};

#endif