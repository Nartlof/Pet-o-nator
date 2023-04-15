#include <Arduino.h>
#include <HotEnd.h>

HotEnd::HotEnd(uint8_t control, uint8_t ntcReadPin, uint8_t rSelection,
               float Kp, float Ki, float Kd, double R1, double R2)
{
    hotEndPWM = control;
    hotEndNtcRead = ntcReadPin;
    hotEndRSelection = rSelection;
    senseResistor1 = R1;
    senseResistor2 = R2;
    targetTemperature = zeroCinK;
    measuredTemperature = zeroCinK;
    pwmValue = 0;
    pinMode(hotEndPWM, OUTPUT);
    stop();
    pinMode(hotEndNtcRead, INPUT);
    pinMode(hotEndRSelection, INPUT);
    hotEndPID = QuickPID(&measuredTemperature, &pwmValue, &targetTemperature);
    hotEndPID.SetTunings(Kp, Ki, Kd);
    hotEndPID.SetProportionalMode(QuickPID::pMode::pOnError);
    hotEndPID.SetDerivativeMode(QuickPID::dMode::dOnError);
    hotEndPID.SetAntiWindupMode(QuickPID::iAwMode::iAwClamp);
    hotEndPID.SetControllerDirection(QuickPID::Action::direct);
}

HotEnd::~HotEnd()
{
}

/*setTemperature()******************************************
 *                                                          *
 * Sets the target temperature for the hotend.              *
 * Argument in Kelvin
 *                                                          *
 ************************************************************/
void HotEnd::setTemperature(float Temperature)
{
    if (Temperature <= MaxTemperature)
    {
        targetTemperature = Temperature;
    }
    else
    {
        targetTemperature = zeroCinK;
    }
}

/*getTemperature()******************************************
 *                                                          *
 * Returns the target temperature for the hotend in Celsius *
 *                                                          *
 ************************************************************/
float HotEnd::getTemperature()
{
    return targetTemperature - zeroCinK;
}

/*readTemperature()******************************************
 *                                                          *
 * Returns the temperature in Celsius measured with the NTC *
 *                                                          *
 ************************************************************/
float HotEnd::readTemperature()
{
    return measuredTemperature - zeroCinK;
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
    if (targetTemperature > zeroCinK)
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
        if ((millis() & 255UL) <= pwmValue)
        {
            digitalWrite(hotEndPWM, HIGH);
        }
        else
        {
            digitalWrite(hotEndPWM, LOW);
        }
    }
}

void HotEnd::start()
{
    started = true;
    hotEndPID.SetMode(QuickPID::Control::automatic);
}

bool HotEnd::isStarted() { return started; }

void HotEnd::stop()
{
    started = false;
    hotEndPID.SetMode(QuickPID::Control::manual);
    digitalWrite(hotEndPWM, LOW);
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
float HotEnd::temperature(double NtcResistence)
{
    double x = log(NtcResistence);
    double xx = 1;
    double eq = 0;
    for (int i = 0; i < 4; i++)
    {
        eq += xx * ResistToTemp[i];
        xx *= x;
    }
    return float(1 / eq);
}