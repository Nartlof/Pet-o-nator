#include <Arduino.h>
#include <HotEnd.h>

HotEnd::HotEnd(uint8_t control, uint8_t ntcReadPin, uint8_t rSelection,
               double Kp, double Ki, double Kd, double R1, double R2)
{
    hotEndPWM = control;
    hotEndNtcRead = ntcReadPin;
    hotEndRSelection = rSelection;
    senseResistor1 = R1;
    senseResistor2 = R2;
    targetTemperature = 273.15;
    measuredTemperature = 273.15;
    pwmValue = 0;
    pinMode(hotEndPWM, OUTPUT);
    stop();
    pinMode(hotEndNtcRead, INPUT);
    pinMode(hotEndRSelection, INPUT);
    hotEndPID.SetPointers(&measuredTemperature, &pwmValue, &targetTemperature);
    hotEndPID.SetTunings(Kp, Ki, Kd, P_ON_E);
    hotEndPID.SetControllerDirection(DIRECT);
    hotEndPID.SetOutputLimits(0, 255);
    hotEndPID.SetSampleTime(100);
    hotEndPID.SetMode(AUTOMATIC);
}

HotEnd::~HotEnd()
{
}

void HotEnd::setTemperature(double Temperature)
{
    if (Temperature <= MaxTemperature)
    {
        targetTemperature = Temperature;
    }
    else
    {
        targetTemperature = 0;
    }
}

double HotEnd::getTemperature()
{
    return targetTemperature - 273.15;
}

double HotEnd::readTemperature()
{
    return measuredTemperature - 275.15;
}

void HotEnd::incTemp()
{
    if (targetTemperature < MaxTemperature)
    {
        targetTemperature++;
    }
}

void HotEnd::decTemp()
{
    if (targetTemperature > 273.15)
    {
        targetTemperature--;
    }
}

void HotEnd::update()
{
    measuredTemperature = temperature(readNtc());
    if (started)
    {
        hotEndPID.Compute();
        analogWrite(hotEndPWM, pwmValue);
    }
}

void HotEnd::start()
{
    started = true;
}

void HotEnd::stop()
{
    started = false;
    analogWrite(hotEndPWM, 0);
}

// Returns the resistence of the NTC in Ohms
double HotEnd::readNtc()
{
    static double senseResistor = senseResistor1;
    double ntcReading = analogRead(hotEndNtcRead);
    if (ntcReading == 0)
    {
        ntcReading = 1;
    }
    double ntcResistance = senseResistor * (1024.0 - ntcReading) / ntcReading;
    if (ntcResistance < senseResistor1 / 10)
    {
        // If resistence is too low, change to the lower value
        senseResistor = 1 / (1 / senseResistor1 + 1 / senseResistor2);
        pinMode(hotEndRSelection, OUTPUT);
        digitalWrite(hotEndRSelection, LOW);
    }
    if (ntcResistance > 5 * senseResistor2)
    {
        // If resistance is too high, go back to the high resistor
        pinMode(hotEndRSelection, INPUT);
        senseResistor = senseResistor1;
    }
    return ntcResistance;
}

// Returns the temperature in K for the reading on the NTC in Ohms
// The parameters on ResistToTemp[] are calculated using the python code
// on this project for minimal squares. Steinhart-Hart equation is used
// writen as a series powers in log(R)
double HotEnd::temperature(double NtcResistence)
{
    double x = log(NtcResistence);
    double xx = 1;
    double eq = 0;
    for (int i = 0; i < 4; i++)
    {
        eq += xx * ResistToTemp[i];
        xx *= x;
    }
    return double(1 / eq);
}