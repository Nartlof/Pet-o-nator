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
    Serial.println(KeyBoard.read());
}

void loop()
{
    ;
}