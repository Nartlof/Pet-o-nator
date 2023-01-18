

#include "Tachometer.h"

Tachometer *Tachometer::ThisTachometer=0;

/*Default constructor*/
Tachometer::Tachometer() {}

/*Tachometer Constructor*************************
 * Parameters:
 * pulsesPerRevolution = Pulses Per Revolution. Default 2
 * Pin = The pin where the interrupt will be assigned. Default 2
 * Timeout = Time elapsed in ms before returning 0 RPM. Default 300ms
 * Readings = Number of samples for smoothing the period. Default 8
 */
Tachometer::Tachometer(uint8_t pulsesPerRevolution = 2, uint8_t Pin = 2, unsigned long Timeout = 300, uint8_t Readings = 8)
{
    // Creating a pointer to itself to manage the interruption
    ThisTachometer = this;
    this->pulsesPerRevolution = pulsesPerRevolution;
    interruptPin = Pin;
    zeroTimeout = Timeout * 1000; // Converting to micro seconds
    readings = Readings;
    periods = new unsigned long[readings];
    initialize();
    attachInterrupt(digitalPinToInterrupt(interruptPin), pulseEventISR, RISING);
}

Tachometer::~Tachometer()
{
    delete[] periods;
}

/*initialize()********************************************
 * Initializes the tachometer. It must be called when the
 * motor is started and called again every time it is stoped
 * and restarted.
 **********************************************************/
void Tachometer::initialize()
{
    // initialises the readings for a valid return before anything was measured
    measuredRPM = 0;
    // no pulses have been counted yet
    hasPulsed = false;
    // periods is initialized with a large value so a reading is shown only after the buffer is full
    unsigned long initPeriod = readings * zeroTimeout;
    for (uint8_t i = 0; i < readings; i++)
    {
        periods[i] = initPeriod;
    }
    periodIndex = 0;
    lastPulse = micros();
}

/*readRPM()*****************************************************
 * Returns the avareged RPM for the motor
 ****************************************************************/
uint16_t Tachometer::readRPM()
{
    // The calculations must be performed only if a pulse has been detected
    // and repeted if a pulse occurrs again during the computation
    if (hasPulsed)
    {
        unsigned long avaregePeriod;
        // Computes the avarege period until no pulse has been detected durig the calculation
        while (hasPulsed)
        {
            hasPulsed = false;
            avaregePeriod = 0;
            for (uint8_t i = 0; i < readings; i++)
            {
                avaregePeriod += periods[i];
            }
        }
        avaregePeriod /= readings;
        unsigned long revolutionPeriod; // The time needed for one revolution
        revolutionPeriod = avaregePeriod * pulsesPerRevolution;
        // First check if the motor is too slow
        if (revolutionPeriod > zeroTimeout)
        {
            measuredRPM = 0;
        }
        // Then checks if it is too fast
        else if (revolutionPeriod < 916)
        {
            measuredRPM = 65530; // Sets to maximum reading possible.
        }
        else // if all is ok, calculate the value
        {
            measuredRPM = 60000000 / (revolutionPeriod);
        }
    }
    else
    {
        // Check if the motor is locked
        if (micros() - lastPulse > zeroTimeout)
        {
            measuredRPM = 0;
        }
    }
    return measuredRPM;
}

// This function is just a workaround to create an interruption inside a class
void Tachometer::pulseEventISR()
{
    ThisTachometer->pulseEvent();
}

void Tachometer::pulseEvent()
{
    // This function must be as fast as possible.
    // Before anyting, saves the instance when a pulse occurrs
    unsigned long now = micros();
    // Then calculates how long from the last pulse
    long thisPeriod = (long)(now - lastPulse);
    // micros() roll over every 71 minutes, so it must be treated.
    // If a roll over occurs, _now_ will be lower than lastPulse and
    // thisPeriod will be less than zero. The solution is to multiply
    // it by -1 in case it is negative.
    // This is a branchless way to solve the problem:
    thisPeriod *= 1 - 2 * (int8_t)(thisPeriod < 0);
    // Saves the period in the buffer
    periods[periodIndex] = thisPeriod;
    // Signals that a pulse had occurred.
    hasPulsed = true;
    // updates variables for the next cicle.
    lastPulse = now;
    periodIndex++;
    if (periodIndex == readings)
        periodIndex = 0;
}