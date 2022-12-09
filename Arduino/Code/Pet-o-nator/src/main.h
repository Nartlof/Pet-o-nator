#include <Arduino.h>
#include <config.h>
#include <CharlieKey.h>
#include <Display.h>
#include <HotEnd.h>

CharlieKey keyboard(keboardBits);

Display display();

HotEnd hotEnd();

void treatKeybord(void);
void treatKeyPressed(uint8_t key, bool repeat);