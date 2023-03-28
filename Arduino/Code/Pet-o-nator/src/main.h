#include <Arduino.h>
#include <config.h>
#include <CharlieKey.h>
#include <Display.h>
#include <HotEnd.h>
#include <Motor.h>

CharlieKey keyboard(keboardBits);

Display display(DisplayRefreshTime);

HotEnd hotEnd(HotEndPwmPin, HotEndNtcRead, HotEndRSelection,
              HotEndKp, HotEndKi, HotEndKd, HotEndSenseResistor1, HotEndSenseResistor2);

Motor motor(MotorPwmPin, MotorFeedbackPin, MotorSpeedToRpm,
            MotorKp, MotorKi, MotorKd, MotorPulsesPerRevolution, MotorTimeOut);

void treatKeybord(void);
void treatKeyPressed(uint8_t key, bool repeat);
bool hasPlastic();
bool hasHadPlastic;