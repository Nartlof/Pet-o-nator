#include <Arduino.h>
#include <CharlieKey.h>

CharlieKey::CharlieKey(uint8_t setPins, uint16_t debounceTime)
{
    _debouceTime = debounceTime;
    Pins = new uint8_t[setPins];
    pinsSet = 0;
    key = 0;
    lastKey = 0;
    nextRead = millis();
};

CharlieKey::~CharlieKey()
{
    delete[] Pins;
}

void CharlieKey::addPin(uint8_t Pin)
{
    // Save the pin in the array
    Pins[pinsSet] = Pin;
    // Set the pin as input with a pullup
    pinMode(Pin, INPUT);
    digitalWrite(Pin, HIGH);
    // Increment the number of pins set
    pinsSet++;
}

uint8_t CharlieKey::nPins()
{
    return pinsSet;
}

uint8_t CharlieKey::read()
{
    if (nextRead <= millis())
    {
        // It is time for a new reading
        uint8_t newKey = rawRead();
        if (lastKey == newKey)
        {
            // two consecutive readings resulted in the same key
            // so, that is the key to be returned
            key = newKey;
        }
        else
        {
            // there is an inconsistance in reading,
            // so no valid key is pressed
            key = 0;
        }
        // Updating the read to compare with next iteration
        lastKey = newKey;
        // Set the time for the next reading
        nextRead = millis() + _debouceTime;
    }
    return key;
}

uint8_t CharlieKey::rawRead()
{
    uint8_t readKey = 0;
    uint8_t rawkey = 0;
    uint8_t parity = 0;
    uint8_t auxColumn = 0;
    uint8_t column = 0;
    for (uint8_t line = 0; line < pinsSet; line++)
    {
        // set the reading line as output '0'
        pinMode(Pins[line], OUTPUT);
        digitalWrite(Pins[line], LOW);
        //  read ports..
        for (uint8_t j = 0; j < pinsSet; j++)
        {
            if (line != j)
            {
                if (LOW == digitalRead(Pins[j]))
                {
                    bitSet(rawkey, j);
                    // counting how many bits where read
                    parity++;
                }
            }
        }
        // Reset the pin as input again
        pinMode(Pins[line], INPUT);
        digitalWrite(Pins[line], HIGH);
        if (rawkey != 0x0)
        {
            // Some key were pressed. Let's determine witch one
            // Odd parity means the dyagonal bit is off.
            if (parity == 1)
            {
                // Setting the dyagonal bit on
                bitSet(rawkey, line);
            }
            // Determining the column
            // The last column has the first and last bits on
            // The others have two consecutive bits on
            // So, let's check the last column firt
            auxColumn = 1;
            bitSet(auxColumn, pinsSet - 1);
            if (auxColumn == rawkey)
            {
                // It is the last column
                column = pinsSet;
            }
            else
            {
                // It is not the last column.
                // Set the value to b00000011 for the first column
                auxColumn = 0b00000011;
                for (uint8_t j = 1; j < pinsSet; j++)
                {
                    if (auxColumn == rawkey)
                    {
                        // Found the column. No need to check further
                        column = j;
                        break;
                    }
                    // Rotate the bits for the next column
                    auxColumn = auxColumn << 1;
                }
            }
            // If column is zero, a invalid stream of bits was read
            // and no match was found and this reading should be ignored.
            if (column != 0)
            {
                // Calculating the index of the key pressed
                readKey = column + line * pinsSet;
            }
            // No need to check further. A key was found or a reading error occurred
            break;
        }
    }
    return readKey;
}
