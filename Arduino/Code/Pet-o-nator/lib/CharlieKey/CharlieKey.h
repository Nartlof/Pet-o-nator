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
    CharlieKey(uint8_t setPins = 8, uint16_t debouce = 50); // Constructor
    ~CharlieKey();
    void addPin(uint8_t Pin); // Used to set the vector with pins
    uint8_t read();           // Return the debounced read of the keyboard
    uint8_t nPins();          // Returns the number of pins set

private:
    uint8_t rawRead(); // reads the keyboard
    uint8_t *Pins;
    uint8_t pinsSet;
    uint8_t key;
    uint8_t lastKey;        // used for debouncing
    unsigned long nextRead; // time for the next reading of the keyboad
    uint8_t _debouceTime;   // deboucing time in ms
};

#endif