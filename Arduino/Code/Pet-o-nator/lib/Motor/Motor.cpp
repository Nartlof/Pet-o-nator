#include <Arduino.h>
#include <Motor.h>

/*Constructor**********************************************************
 * control - Pin where the PWM signal goes
 * feedBack - Pin where the interruption for the IR sensor goes
 * speedToRPM - Relation between one revolution and the actual speed
 * Kp, Ki, Kd - Constants for the PID controler.
 * pulsesPerRevolution - how many pulses sensed represents a revolution
 * timeOut - How long to wait until consider the motor has stoped (ms)
 ***********************************************************************/
Motor::Motor(uint8_t control, uint8_t feebBack, float speedToRPM,
             float Kp, float Ki, float Kd,
             uint8_t pulsesPerRevolution,
             unsigned long timeOut)
{
    pwmPin = control;
    targetRPM = 0;
    measuredRPM = 0;
    pwmValue = 0;
    this->speedToRpm = speedToRPM;
    tachometer = Tachometer(pulsesPerRevolution, feebBack, timeOut, 4);
    motorPID = QuickPID(&measuredRPM, &pwmValue, &targetRPM);
    motorPID.SetTunings(Kp, Ki, Kd);
    motorPID.SetProportionalMode(QuickPID::pMode::pOnError);
    motorPID.SetDerivativeMode(QuickPID::dMode::dOnError);
    motorPID.SetAntiWindupMode(QuickPID::iAwMode::iAwClamp);
    motorPID.SetControllerDirection(QuickPID::Action::direct);
    pinMode(pwmPin, OUTPUT);
    stop();
    pinMode(feebBack, INPUT_PULLUP);
}

Motor::~Motor()
{
}

void Motor::setRPM(float RPM)
{
    if (RPM <= MaxRPM)
    {
        targetRPM = RPM;
    }
    else
    {
        targetRPM = MaxRPM;
    }
}

float Motor::getRPM()
{
    return targetRPM;
}

float Motor::readRPM()
{
    return measuredRPM;
}

void Motor::setSpeed(float speed)
{
    setRPM(speed * speedToRpm);
}

float Motor::getSpeed()
{
    return round(targetRPM / speedToRpm);
}

float Motor::readSpeed()
{
    return round(measuredRPM / speedToRpm);
}

void Motor::incSpeed()
{
    if (targetRPM < MaxRPM)
    {
        targetRPM += speedToRpm;
        if (targetRPM > MaxRPM)
        {
            targetRPM = MaxRPM;
        }
    }
}

void Motor::decSpeed()
{
    if (targetRPM > 0)
    {
        targetRPM -= speedToRpm;
        if (targetRPM < 0)
        {
            targetRPM = 0;
        }
    }
}

void Motor::update()
{
    if (started)
    {
        // Write PID control here
        measuredRPM = tachometer.readRPM();
        motorPID.Compute();
        /*Serial.print("targetRPM=");
        Serial.print(targetRPM);
        Serial.print(" measuredRPM=");
        Serial.print(measuredRPM);
        Serial.print(" pwmValue=");
        Serial.println(pwmValue);*/
        analogWrite(pwmPin, pwmValue);
        // analogWrite(pwmPin, 70);
    }
    else
    {
        analogWrite(pwmPin, 0);
    }
}

void Motor::start()
{
    started = true;
    tachometer.initialize();
    motorPID.SetMode(QuickPID::Control::automatic);
}

bool Motor::isStarted() { return started; }

void Motor::stop()
{
    motorPID.SetMode(QuickPID::Control::manual);
    analogWrite(pwmPin, 0);
    started = false;
    measuredRPM = 0;
}