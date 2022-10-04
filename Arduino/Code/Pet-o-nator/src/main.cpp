#include <Arduino.h>
//#include <LiquidCrystal.h>
#include <PID_v1.h>
#define USE_TIMER_1 true
#include <TimerInterrupt.h>

#include <Wire.h>
#include <LiquidCrystal_I2C.h>

#define COLUMS 20
#define ROWS 4

#define LCD_SPACE_SYMBOL 0x20 // space symbol from the LCD ROM, see p.9 of GDM2004D datasheet

LiquidCrystal_I2C lcd(PCF8574_ADDR_A21_A11_A01, 4, 5, 6, 16, 11, 12, 13, 14, POSITIVE);

// NTC and PWM definitions
#define NtcPin A0
#define SenseResistor1 9800.0
#define SenseResistor2 555.0
#define ResistorSelectingPin 7
#define PwmPin 6

const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
// LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

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

double ReadNtc()
{
  static double SenseResistor = SenseResistor1;
  double NtcReading = analogRead(NtcPin);
  if (NtcReading == 0)
  {
    NtcReading = 1;
  }
  double NtcResistance = SenseResistor * (1024.0 - NtcReading) / NtcReading;
  if (NtcResistance < SenseResistor1 / 10)
  {
    // If resistence is too low, change to the lower value
    SenseResistor = 1 / (1 / SenseResistor1 + 1 / SenseResistor2);
    pinMode(ResistorSelectingPin, OUTPUT);
    digitalWrite(ResistorSelectingPin, LOW);
  }
  if (NtcResistance > 5 * SenseResistor2)
  {
    // If resistance is too high, go back to the high resistor
    pinMode(ResistorSelectingPin, INPUT);
    SenseResistor = SenseResistor1;
  }
  return NtcResistance;
}

void setup()
{
  //  set up the LCD's number of columns and rows:
  lcd.begin(20, 4);
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(F("Initializing..."));
  // initialize the serial communications:
  // Serial.begin(9600);
  // Serial.write("Conectado\n");

  // Setting up pins
  pinMode(PwmPin, OUTPUT);
  // Put the resistor selection in high impedance
  pinMode(ResistorSelectingPin, INPUT);

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
  TargetTemp = float(analogRead(A1) / 4 + 273 + 20) / 16.0 + TargetTemp * 15.0 / 16.0;

  // Loading ADC for the NTC
  // avarege = analogRead(NtcPin); // (analogRead(NtcPin) + 15 * avarege) / 16;

  // NtcResistance = SenseResistor * (1024.0 - avarege) / avarege;
  double NtcResistance = ReadNtc();
  ReadTemp = Temperature(NtcResistance);
  myPID.Compute();
  if (millis() - LoopCount > 500)
  {
    lcd.clear();
    // lcd.setCursor(0, 0);
    lcd.print(NtcResistance);
    lcd.print("R");
    lcd.setCursor(13, 0);
    lcd.print(PwmValue);
    lcd.setCursor(0, 1);
    lcd.print(TargetTemp - 273);
    lcd.print("C");
    lcd.setCursor(13, 1);
    lcd.print(ReadTemp - 273);
    lcd.print("C");
    LoopCount = millis();
  }

  delay(10);
}