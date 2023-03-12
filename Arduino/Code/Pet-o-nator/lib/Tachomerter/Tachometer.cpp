

#include "Tachometer.h"

// Defining static members
uint8_t Tachometer::interruptionNumber = 0;
uint8_t Tachometer::readings = 0;
unsigned long *Tachometer::periods = NULL;
uint8_t Tachometer::periodIndex = 0;
unsigned long Tachometer::lastPulse = 0;
bool Tachometer::hasPulsed = false;

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
    this->pulsesPerRevolution = pulsesPerRevolution;
    interruptPin = Pin;
    interruptionNumber = digitalPinToInterrupt(Pin);
    zeroTimeout = Timeout * 1000; // Converting to micro seconds
    readings = Readings;
    periods = new unsigned long[readings];
    pinMode(interruptPin, INPUT);
    initialize();
    attachInterrupt(interruptionNumber, pulseEventISR, RISING);
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
    static unsigned long lastAvaregePeriod = zeroTimeout;
    if (hasPulsed)
    {
        unsigned long avaregePeriod;
        // Computes the avarege period until no pulse has been detected durig the calculation
        // but no more than two times. For large pulse rates it can leed to an infinit loop.
        uint8_t tryTwice = 0;
        while (hasPulsed && tryTwice < 2)
        {
            tryTwice++;
            hasPulsed = false;
            avaregePeriod = 0;
            for (uint8_t i = 0; i < readings; i++)
            {
                avaregePeriod += periods[i];
            }
        }
        avaregePeriod /= readings;
        lastAvaregePeriod = avaregePeriod;
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
        unsigned long sinceLastPulse = micros() - lastPulse;
        if (sinceLastPulse > zeroTimeout)
        {
            // motor is locked becaus too much time has passed
            measuredRPM = 0;
        }
        else
        {
            // Checking if rotation has decreased abruptly
            if (sinceLastPulse > 1.1875 * lastAvaregePeriod)
            {
                // if so, updates measuredRPM
                measuredRPM = 60000000 / (sinceLastPulse * pulsesPerRevolution);
            }
        }
    }
    return measuredRPM;
}

// This function is attached to the interruption
void Tachometer::pulseEventISR()
{
    // Deatach the interruption to avoid inner calling
    detachInterrupt(interruptionNumber);
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
    hasPulsed = true;
    // Saves the period in the buffer
    periods[periodIndex] = thisPeriod;
    // Signals that a pulse had occurred.
    // hasPulsed = true;
    // updates variables for the next cicle.
    lastPulse = now;
    periodIndex++;
    if (periodIndex == readings)
        periodIndex = 0;
    // Reattach interruption
    attachInterrupt(interruptionNumber, pulseEventISR, RISING);
    return;
}