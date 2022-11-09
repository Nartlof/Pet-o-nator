#include <Arduino.h>
#include <CharlieKey.h>

CharlieKey::CharlieKey(uint8_t setPins)
{
    Pins = new uint8_t[setPins];
    pinsSet = 0;
};

CharlieKey::~CharlieKey()
{
    delete[] Pins;
}

void CharlieKey::addPin(uint8_t Pin)
{
    Pins[pinsSet] = Pin;
    pinsSet++;
}

uint8_t CharlieKey::nPins()
{
    return pinsSet;
}

uint8_t CharlieKey::read()
{
    uint8_t key = 0;
    // To ensure a proper reading, at least 2 consecutive readings must match
    uint8_t lastKey = 255;

    // setup ports..
    for (uint8_t i = 0; i < pinsSet; i++)
    {
        // Reset all pins as inputs
        pinMode(Pins[i], INPUT);
        digitalWrite(Pins[i], HIGH);
    }
    // Reading the lines
    while (lastKey != key)
    {
        lastKey = key;
        uint8_t rawkey = 0;
        uint8_t parity = 0;
        uint8_t auxColumn = 0;
        uint8_t column = 0;
        for (uint8_t line = 0; line < pinsSet; line++)
        {
            // set the reading line as output '0'
            pinMode(Pins[line], OUTPUT);
            digitalWrite(Pins[line], LOW);
            // delay(1);
            //  read ports..
            for (uint8_t j = 0; j < pinsSet; j++)
            {
                if (line != j)
                {
                    if (LOW == digitalRead(Pins[j]))
                    {
                        bitSet(rawkey, j);
                        parity++;
                    }
                }
            }
            // Reset the pin as input again
            pinMode(Pins[line], INPUT);
            digitalWrite(Pins[line], HIGH);
            if (rawkey != 0x0)
            { // key pressed, return key
                // Odd parity means the dyagonal bit is off
                if (parity == 1)
                {
                    bitSet(rawkey, line);
                }
                // Determining the column
                auxColumn = 1;
                bitSet(auxColumn, pinsSet - 1);
                if (auxColumn == rawkey)
                {
                    column = pinsSet;
                }
                else
                {
                    auxColumn = 0b00000011; // Set the value to b00000011
                    for (uint8_t j = 1; j < pinsSet; j++)
                    {
                        if (auxColumn == rawkey)
                        {
                            column = j;
                            break;
                        }
                        auxColumn = auxColumn << 1;
                    }
                }
                if (column != 0)
                {
                    key = column + line * pinsSet;
                }
                break;
            }
        }
        // Add a delay for debouncing
        delay(10);
    }
    return key;
}
