#include <Arduino.h>
#include <config.h>
#include <CharlieKey.h>

CharlieKey keyboard(keboardBits);

void treatKeybord(void);
void treatKeyPressed(uint8_t key, bool repeat);