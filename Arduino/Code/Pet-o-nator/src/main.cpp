//#include <Arduino.h>
#include <main.h>

void setup()
{
    uint8_t KeyPins[keboardBits] = {keboardA0, keboardA1, keboardA2};
    Serial.begin(9600);
    Serial.println(F("Iniciando..."));
    Serial.println(F("Setando o teclado"));
    for (uint8_t i = 0; i < keboardBits; i++)
    {
        KeyBoard.addPin(KeyPins[i]);
    }
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
            // Serial.print(newKey, BIN);
            // Serial.print(" ");
            Serial.println(newKey);
        }
        lastKey = newKey;
    }
}