#include <Arduino.h>
#include <LiquidCrystal.h>
#include <PID_v1.h>
#define USE_TIMER_1 true
#include <TimerInterrupt.h>

#define NtcPin A0
#define SenseResistor 9800.0
#define PwmPin 6

const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

// PwmValue is an absolute value from 0 to 1024. Larger values mean 100% dutty cicle

// Define Variables for PID control
double PwmValue = 0;
double TargetTemp = 0;
double ReadTemp = 0;

// Specify the links and initial tuning parameters
double Kp = 120, Ki = 14, Kd = 60;
PID myPID(&ReadTemp, &PwmValue, &TargetTemp, Kp, Ki, Kd, DIRECT);

// Function to control the heater via timer interrupt
void BitBangingPWM()
{
  static int Time = 0;
  digitalWrite(PwmPin, (Time < PwmValue));
  Time++;
  if (Time > 1023)
  {
    Time = 0;
  }
}

// These are the figures to be used to calculate the temperature from the NTC reading
const float ResistToTemp[] = {7.06114140e-04, 2.69749565e-04, -6.99387329e-06, 3.01741645e-07};

// Returns the temperature in K for the reading on the NTC in Ohms
// The parameters on ResistToTemp[] are calculated using the python code
// on this project for minimal squares. Steinhart-Hart equation is used
double Temperature(double NtcReading)
{
  double x = log(NtcReading);
  double xx = 1;
  double eq = 0;
  for (int i = 0; i < 4; i++)
  {
    eq += xx * ResistToTemp[i];
    xx *= x;
  }
  return double(1 / eq);
}

void setup()
{
  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);
  lcd.clear();
  lcd.print("Initializing...");
  // initialize the serial communications:
  // Serial.begin(9600);
  // Serial.write("Conectado\n");

  // Setting up pins
  pinMode(PwmPin, OUTPUT);

  // Setting up PID
  myPID.SetOutputLimits(0, 1024);
  myPID.SetSampleTime(100);
  myPID.SetMode(AUTOMATIC);
  // Setting timer interrupt
  ITimer1.init();
  ITimer1.attachInterruptInterval(1, BitBangingPWM);

  // This is a test bit.
  TargetTemp = float(analogRead(A1) / 4 + 273);
}

void loop()
{
  static long LoopCount = millis();
  static double avarege = analogRead(NtcPin);
  double NtcResistance = SenseResistor * (1024.0 - avarege) / avarege;

  TargetTemp = float(analogRead(A1) / 4 + 273) / 16.0 + TargetTemp * 15.0 / 16.0;

  // Loading ADC for the NTC
  avarege = analogRead(NtcPin); // (analogRead(NtcPin) + 15 * avarege) / 16;

  NtcResistance = SenseResistor * (1024.0 - avarege) / avarege;
  ReadTemp = Temperature(NtcResistance);
  myPID.Compute();
  if (millis() - LoopCount > 500)
  {
    lcd.clear();
    lcd.print(NtcResistance);
    lcd.print("R");
    lcd.setCursor(11, 0);
    lcd.print(PwmValue);
    lcd.setCursor(0, 1);
    lcd.print(TargetTemp - 273);
    lcd.print("C");
    lcd.setCursor(8, 1);
    lcd.print(ReadTemp - 273);
    lcd.print("C");
    LoopCount = millis();
  }

  delay(10);
}