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
    const unsigned long startRepeatDelay = 1024;
    static uint8_t newKey = 0;
    static uint8_t lastKey = 0;
    static unsigned long repeatDelay = startRepeatDelay;
    static unsigned long nextRepeat = startRepeatDelay;
    static unsigned long repeatTime = startRepeatDelay;
    unsigned long now = 0;
    newKey = KeyBoard.read();
    //***********************
    // Treating the keyboard
    //***********************
    if (newKey != lastKey)
    {
        // There was a change in keyboard reading
        // Reset repeat delay and repeats
        repeatDelay = startRepeatDelay;
        nextRepeat = millis() + repeatDelay;
        repeatTime = nextRepeat;
        if (newKey != 0)
        {
            Serial.print(newKey);
        }
        else
        {
            Serial.println();
        }
    }
    else
    {
        // It is a repeat
        // Only do something if a key is pressed
        if (newKey != 0)
        {
            // Check if it is time to repeat
            now = millis();
            if (now > nextRepeat)
            {
                // do the repetition
                Serial.print(newKey);
                // Check how many repeats for increiasing speed
                if (now > repeatTime)
                {
                    // It is time to update the repeating delay
                    repeatDelay /= 4;
                    repeatTime = now + startRepeatDelay;
                }
                nextRepeat = millis() + repeatDelay;
            }
        }
    }
    lastKey = newKey;
    //***************************
    // End treating the keyboard
    //***************************
}