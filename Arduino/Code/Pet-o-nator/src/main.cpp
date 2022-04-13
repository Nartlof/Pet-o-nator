#include <Arduino.h>
#include <LiquidCrystal.h>
#define USE_TIMER_1 true
#include <TimerInterrupt.h>

#define NtcPin A0
#define SenseResistor 10000.0
#define PwmPin 6

const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

// These are the figures to be used to calculate the temperature from the NTC reading
const float ResistToTemp[] = {7.06114140e-04, 2.69749565e-04, -6.99387329e-06, 3.01741645e-07};

//PwmValue is an absolute value from 0 to 1024. Larger values mean 100% dutty cicle
int PwmValue = 0;

void BitBangingPWM(){
  static int Time = 0;
  digitalWrite(PwmPin, (Time < PwmValue));
  Time++;
  if (Time>1023){
    Time = 0;
  }
}


float Temperature(float NtcReading)
{
  double x = log(NtcReading);
  double xx = 1;
  double eq = 0;
  for (int i = 0; i < 4; i++)
  {
    eq += xx * ResistToTemp[i];
    xx *= x;
  }
  return float(1 / eq - 273.16);
}

void setup()
{
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  pinMode(PwmPin, OUTPUT);
  // Setting timer interrupt
  ITimer1.init();
  ITimer1.attachInterruptInterval(1, BitBangingPWM);

  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);
  // initialize the serial communications:
  Serial.begin(9600);
  Serial.write("Conectado\n");
}

void loop()
{
  unsigned char i;
  unsigned char j;
  float avarege = 0;
  unsigned int partAvarege;
  float NtcResistance;

  PwmValue = analogRead(A1);

  // Loading ADC for the NTC
  for (i = 0; i < 16; i++)
  {
    partAvarege = 0;
    for (j = 0; j < 16; j++)
    {
      partAvarege += analogRead(NtcPin);
    }
    avarege += partAvarege / 16.0;
  }
  avarege /= 16.0;

  NtcResistance = SenseResistor * (1024.0 - avarege) / avarege;
  lcd.clear();
  lcd.print(NtcResistance);
  lcd.print(" Ohms");
  lcd.setCursor(0, 1);
  // print the number of seconds since reset:
  lcd.print(Temperature(NtcResistance));
  lcd.print("C");

  delay(100);
}