/*
Define the control for the motor
Autor: Carlos Eduardo Foltran
Date: 2022-12-09
*/

#pragma once

#ifndef PetonatorMOTOR
#define PetonatorMOTOR

#include <Arduino.h>

#define MaxRPM 10000.0
#define SpeedToRpm 97.0

class Motor
{
private:
    uint8_t pwmPin;     // this is the pin for the PWM to control the motor
    uint8_t tacoPin;    // pin where the photosensor is connected
    double targetRPM;   // the target RPM for the motor
    double measuredRPM; // actual RPM
    bool started;

    /* data */
public:
    Motor(uint8_t control, uint8_t feebBack);
    ~Motor();
    void setRPM(double);   // sets the target RPM for the motor
    double getRPM();       // returns the set RPM
    double readRPM();      // returns the measured RPM
    void setSpeed(double); // sets the pulling speed
    double getSpeed();     // returns the target pulling speed
    double readSpeed();    // returns the actual pulling speed
    void incSpeed();       // increments speed by 1mm/min
    void decSpeed();       // decrements speed by 1mm/min

    void update(); // updated PID control. Must be in mail loop
    void start();  // turns the motor on
    void stop();   // turns the motor off
};

#endif