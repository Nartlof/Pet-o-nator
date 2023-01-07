/*
Define the control for the hotend and NTC
Autor: Carlos Eduardo Foltran
Date: 2022-12-09
*/

#pragma once

#ifndef PetonatorHOTEND
#define PetonatorHOTEND

#include <Arduino.h>
#include <QuickPID.h>
#define MaxTemperature 573.15

class HotEnd
{
private:
    uint8_t hotEndPWM;
    uint8_t hotEndNtcRead;
    uint8_t hotEndRSelection;
    double senseResistor1;
    double senseResistor2;
    float targetTemperature;
    float measuredTemperature;
    float pwmValue;
    const float zeroCinK = 273.15;
    bool started;
    QuickPID hotEndPID;
    //  These are the figures to be used to calculate the temperature from the NTC reading
    const double ResistToTemp[4] = {7.06114140e-04, 2.69749565e-04, -6.99387329e-06, 3.01741645e-07};

public:
    HotEnd(uint8_t control, uint8_t ntcRead, uint8_t rSelection,
           float Kp, float Ki, float Kd, double R1, double R2);
    ~HotEnd();
    void setTemperature(float Temperature); // sets the target temperature
    float getTemperature();                 // returns the target temperature
    float readTemperature();                // returns the temperature from NTC
    void incTemp();                         // increments temperature by one degree
    void decTemp();                         // decrements temperature by one degree
    void update();                          // Must be in the mais loop
    void start();                           // Starts the heating
    void stop();                            // Turns off the hearter
    float temperature(double NtcReading);   // Returns the temperature in Kelvin from a NTC reading
    double readNtc();                       // Returns the resistance of the NTC in Ohms
};

#endif