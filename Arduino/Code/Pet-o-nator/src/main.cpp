//#include <Arduino.h>
#include <main.h>

void setup()
{
    Serial.begin(9600);
    Serial.println(F("Iniciando..."));
    Serial.println(F("Setando o teclado"));
    KeyBoard.addPin(11);
    KeyBoard.addPin(12);
    KeyBoard.addPin(13);
    Serial.println(F("Lendo o teclado"));
}

void loop()
{
    static uint8_t newKey = 0;
    static uint8_t lastKey = 0;
    newKey = KeyBoard.read();
    if (newKey != lastKey)
    {
        if (newKey != 0)
        {
            //Serial.print(newKey, BIN);
            //Serial.print(" ");
            Serial.println(newKey);
        }
        lastKey = newKey;
    }
}