#include <Arduino.h>
#include <config.h>
#include <CharlieKey.h>
#include <Display.h>
#include <HotEnd.h>
#include <Motor.h>

CharlieKey keyboard(keboardBits);

Display display;

// HotEnd hotEnd(HotEndPwmPin, HotEndFeedBack1, HotEndFeedBack2);

// Motor motor(MotorPwmPin, MotorFeedbackPin);

void treatKeybord(void);
void treatKeyPressed(uint8_t key, bool repeat);