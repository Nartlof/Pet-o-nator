/*
Define the control for the motor
Autor: Carlos Eduardo Foltran
Date: 2022-12-09
*/

#pragma once

#ifndef PetonatorMOTOR
#define PetonatorMOTOR

#include <Arduino.h>
#include <Tachometer.h>
#include <QuickPID.h>

#define MaxRPM 10000.0

class Motor
{
private:
    uint8_t pwmPin;    // this is the pin for the PWM to control the motor
    float targetRPM;   // the target RPM for the motor
    float measuredRPM; // actual RPM
    float speedToRpm;  // relation between the RPM and speed of the device
    float pwmValue;
    bool started;
    Tachometer tachometer; // class to measure the motor RPM
    QuickPID motorPID;     // PID controler

    /* data */
public:
    Motor(uint8_t control, uint8_t feebBack, float speedToRPM,
          float Kp, float Ki, float Kd,
          uint8_t pulsesPerRevolution,
          unsigned long timeOut);
    ~Motor();
    void setRPM(float);   // sets the target RPM for the motor
    float getRPM();       // returns the set RPM
    float readRPM();      // returns the measured RPM
    void setSpeed(float); // sets the pulling speed
    float getSpeed();     // returns the target pulling speed
    float readSpeed();    // returns the actual pulling speed
    void incSpeed();      // increments speed by 1mm/min
    void decSpeed();      // decrements speed by 1mm/min

    void update();    // updated PID control. Must be in mail loop
    void start();     // turns the motor on
    void stop();      // turns the motor off
    bool isStarted(); // returns weather or not the motor is running
    void setPid(float Kp, float Ki, float Kd); // Sets the constants for the PID
};

#endif