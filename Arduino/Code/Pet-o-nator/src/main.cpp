#include <Arduino.h>
#include <LiquidCrystal.h>

#define NtcPin A0
#define SenseResistor 500.0
#define PwmPin 6

const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

void setup()
{
  pinMode(PwmPin, OUTPUT);
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

  analogWrite(PwmPin, analogRead(A1) / 4);

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
  lcd.print(millis() / 1000);

  delay(100);
}