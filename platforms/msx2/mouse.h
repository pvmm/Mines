#ifndef MOUSE_H
#define MOUSE_H

#include "msx2.h"
#include "game.h"
#include "input.h"
#include <stdint.h>

/* ignore spurious mouse input after this many frames */
#define IGNORE_MOUSE_THRESHOLD 10

/* search for plugged mouse device */
int8_t search_mouse();

/* structure for storing mouse or joystick data */
typedef struct {
    int8_t dx;
    int8_t dy;
    uint8_t l_button; /* 1 = OFF, 2 = ON */
    uint8_t r_button; /* 1 = OFF, 2 = ON */
} joydata;

void read_joyport(joydata* data, uint8_t source) SDCCCALL0;

inline void update_mouse(minefield* mf, uint8_t source);

#endif /* MOUSE_H */
