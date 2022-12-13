/*
Define the control for the motor
Autor: Carlos Eduardo Foltran
Date: 2022-12-09
*/

#pragma once

#ifndef PetonatorMOTOR
#define PetonatorMOTOR

#include <Arduino.h>

#define MaxRPM 10000

class Motor
{
private:
    uint8_t pwmPin;       // this is the pin for the PWM to control the motor
    uint8_t tacoPin;      // pin where the photosensor is connected
    uint16_t targetRPM;   // the target velocity for the motor
    uint16_t measuredRPM; // actual speed
    bool started;

    /* data */
public:
    Motor(uint8_t control, uint8_t feebBack);
    ~Motor();
    void setRPM(uint16_t); // sets the target speed for the motor
    uint16_t getRPM();     // returns the set speed
    uint16_t readRPM();    // returns the measured speed

    void update(); // updated PID control. Must be in mail loop
    void start();  // turns the motor on
    void stop();   // turns the motor off
};

#endif