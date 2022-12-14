/*
Define the control for the hotend and NTC
Autor: Carlos Eduardo Foltran
Date: 2022-12-09
*/

#pragma once

#ifndef PetonatorHOTEND
#define PetonatorHOTEND

#define MaxTemperature 300

class HotEnd
{
private:
    uint8_t hotEndPWM;
    uint8_t hotEndFeedBack1;
    uint8_t hotEndFeedBack2;
    double targetTemperature;
    double measuredTemperature;
    bool started;

public:
    HotEnd(uint8_t control, uint8_t feedBack1, uint8_t feedBack2);
    ~HotEnd();
    void setTemperature(double Temperature); // sets the target temperature
    double getTemperature();                 // returns the target temperature
    double readTemperature();                // returns the temperature from NTC
    void incTemp();                          // increments temperature by one degree
    void decTemp();                          // decrements temperature by one degree
    void update();                           // Must be in the mais loop
    void start();                            // Starts the heating
    void stop();                             // Turns off the hearter
};

#endif