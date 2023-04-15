#include <main.h>

void setup()
{
    // Checking if there is a valid preset
    EEPROM.get(0, preSet);
    if (preSet.check != 165)
    {
        preSet.check = 165;
        preSet.temp = HotEndPreSetTemperature;
        preSet.speed = MotorPreSetRpm;
        EEPROM.put(0, preSet);
    }

    //---------------------------------------------- Set PWM frequency for D9 & D10 ------------------------------

    TCCR1B = TCCR1B & (B11111000 | B00000001); // set timer 1 divisor to 1 for PWM frequency of 31372.55 Hz
    // TCCR1B = TCCR1B & B11111000 | B00000010; // set timer 1 divisor to 8 for PWM frequency of 3921.16 Hz
    // TCCR1B = TCCR1B & B11111000 | B00000011; // set timer 1 divisor to 64 for PWM frequency of 490.20 Hz (The DEFAULT)
    // TCCR1B = TCCR1B & B11111000 | B00000100; // set timer 1 divisor to 256 for PWM frequency of 122.55 Hz
    // TCCR1B = TCCR1B & B11111000 | B00000101; // set timer 1 divisor to 1024 for PWM frequency of 30.64 Hz

    uint8_t keyPins[keboardBits] = {keboardA0, keboardA1, keboardA2};
    // Serial.begin(115200);
    // Serial.println(F("Iniciando..."));
    for (uint8_t i = 0; i < keboardBits; i++)
    {
        keyboard.addPin(keyPins[i]);
    }
    // Setting up plastic sensor
    hasHadPlastic = false;
    pinMode(PlasticSensorPin, INPUT_PULLUP);
    display.initialize();
    // Serial.println(F("Lendo o teclado"));
}

void loop()
{
    treatKeybord();
    hotEnd.update();
    motor.update();
    display.setMeasuredTemperature(hotEnd.readTemperature());
    display.setTargetTemperature(hotEnd.getTemperature());
    display.setMeasuredSpeed(motor.readSpeed());
    display.setTargetSpeed(motor.getSpeed());
    display.setStarted(hotEnd.isStarted() || motor.isStarted());
    display.update();
    if (!hasPlastic() && hasHadPlastic)
    {
        hotEnd.stop();
        motor.stop();
    }
    if (hasPlastic() && !hasHadPlastic)
        hasHadPlastic = true;
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
    case savePreSetButton:
        preSet.check = 165;
        preSet.temp = hotEnd.getTemperature() + hotEnd.zeroCinK;
        preSet.speed = motor.getRPM();
        EEPROM.put(0, preSet);
        break;
    case tempPresetButton:
        hotEnd.setTemperature(preSet.temp);
        break;
    case speedPreSetButton:
        motor.setRPM(preSet.speed);
        break;
    case tempUpButton:
        hotEnd.incTemp();
        break;

    case tempDownButton:
        hotEnd.decTemp();
        break;

    case speedUpButton:
        motor.incSpeed();
        break;

    case speedDownButton:
        motor.decSpeed();
        break;
    case startButton:
        if (hasPlastic() || !hasHadPlastic)
        {
            motor.start();
            hotEnd.start();
            hasHadPlastic = hasPlastic();
        }
        break;
    case stopButton:
        motor.stop();
        hotEnd.stop();
        break;
    default:
        break;
    }
}

bool hasPlastic()
{
    return digitalRead(PlasticSensorPin) == LOW;
}