#include <main.h>

void setup()
{
    uint8_t keyPins[keboardBits] = {keboardA0, keboardA1, keboardA2};
    // Serial.begin(115200);
    // Serial.println(F("Iniciando..."));
    for (uint8_t i = 0; i < keboardBits; i++)
    {
        keyboard.addPin(keyPins[i]);
    }
    display.initialize();
    // Serial.println(F("Lendo o teclado"));
}

void loop()
{
    treatKeybord();
    hotEnd.update();
    display.setMeasuredTemperature(hotEnd.readTemperature());
    display.setTargetTemperature(hotEnd.getTemperature());
    display.setTargetSpeed(motor.getSpeed());
    display.setStarted(hotEnd.isStarted() || motor.isStarted());
    display.update();
}

void treatKeybord()
{
    const unsigned long startRepeatDelay = 1024;
    static uint8_t newKey = 0;
    static uint8_t lastKey = 0;
    static unsigned long repeatDelay = startRepeatDelay;
    static unsigned long nextRepeat = startRepeatDelay;
    static unsigned long repeatTime = startRepeatDelay;
    unsigned long now = 0;
    newKey = keyboard.read();
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
            // The change was a new key pressed
            treatKeyPressed(newKey, false);
        }
        else
        {
            //  The change was the release of a key
            //  It is coded to the treatment routine as a zero-false paramenter
            treatKeyPressed(0, false);
        }
    }
    else
    {
        // It is a repeat
        // Only do something if a key is pressed
        // The release of the key was treated above
        if (newKey != 0)
        {
            // Check if it is time to repeat
            now = millis();
            if (now > nextRepeat)
            {
                // do the repetition
                treatKeyPressed(newKey, true);
                // Check how much time passes before increiasing speed
                if (now > repeatTime)
                {
                    // It is time to update the repeating delay
                    repeatDelay /= 4;
                    repeatTime = now + startRepeatDelay;
                }
                nextRepeat = now + repeatDelay;
            }
        }
    }
    // Update lastKey for the next treatment
    lastKey = newKey;
}

void treatKeyPressed(uint8_t key, bool repeat)
{
    switch (key)
    {
    case preSetButton:
        hotEnd.setTemperature(HotEndPreSetTemperature);
        motor.setRPM(MotorPreSetRpm);
        break;

    case tempUp:
        hotEnd.incTemp();
        break;

    case tempDown:
        hotEnd.decTemp();
        break;

    case speedUp:
        motor.incSpeed();
        break;

    case speedDown:
        motor.decSpeed();
        break;
    case startButton:
        motor.start();
        hotEnd.start();
        break;
    case stopButton:
        motor.stop();
        hotEnd.stop();
        break;

    default:
        break;
    }
}