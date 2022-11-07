/*
Define a Charlieplex keyboard
Example taken from: https://forum.arduino.cc/t/extended-charlieplexing/138569
Autor: Carlos Eduardo Foltran
Date: 2022-11-07
*/

#ifndef CHARLIEKEY
#define CHARLIEKEY

class CharlieKey
{
public:
    CharlieKey(uint8_t setPins); // Constructor
    ~CharlieKey();
    void addPin(uint8_t Pin); // Used to set the vector with pins
    uint8_t read();           // Reads the keyboard

private:
    uint8_t *Pins;
    uint8_t nPins;
    uint8_t pinsSet;
};

#endif