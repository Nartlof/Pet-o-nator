/*
Define a tachometer class
This class is based upon the work of InterlinkKnight
Example taken from: https://www.youtube.com/watch?v=u2uJMJWsfsg
Autor: Carlos Eduardo Foltran
Date: 2023-01-10
*/

#ifndef TACHOMETER_H
#define TACHOMETER_H

#pragma once

#include <Arduino.h>

class Tachometer
{
public:
    Tachometer();
    Tachometer(uint8_t pulsesPerRevolution, uint8_t Pin, unsigned long Timeout, uint8_t Readings);
    ~Tachometer();
    uint16_t readRPM(); // Returns the RPM of the motor
    void initialize();  // must be called every time the motor is started

private:
    uint8_t pulsesPerRevolution;
    uint8_t interruptPin;
    unsigned long zeroTimeout;
    static uint8_t interruptionNumber;// static copy of the interruption
    static uint8_t readings;          // amount of samples used to compute the period.
    static unsigned long *periods;    // Vector of the last measured periods.
    static uint8_t periodIndex;       // Where in the period vector the next sample will be recorded.
    static unsigned long lastPulse;   // Micros() when the last pulse happened.
    static bool hasPulsed;            // Tells if a pulse had ocurred since last reading of RPM.
    uint16_t measuredRPM;             // keeps the last computed RPM

    static void pulseEventISR(); // Treats the pulse event

};

#endif