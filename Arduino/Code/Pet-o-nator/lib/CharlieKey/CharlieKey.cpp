#include <Arduino.h>
#include <CharlieKey.h>

CharlieKey::CharlieKey(uint8_t setPins)
{
    nPins = setPins;
    Pins = new uint8_t[nPins];
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

uint8_t CharlieKey::read()
{
    return Pins[1];
}