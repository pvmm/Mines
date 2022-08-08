#ifndef INPUT_H
#define INPUT_H

#include "msx2.h"
#include "game.h"
#include <stdint.h>

/* joystick bitmask */
#define JOY_INPUT_UP                (1 << 0)
#define JOY_INPUT_DOWN              (1 << 1)
#define JOY_INPUT_LEFT              (1 << 2)
#define JOY_INPUT_RIGHT             (1 << 3)
#define JOY_INPUT_BUTTON1           (1 << 4)
#define JOY_INPUT_BUTTON2           (1 << 5)

uint8_t read_raw_joyport(uint8_t source) __z88dk_fastcall;

inline void update_joystick(uint8_t source);

extern uint16_t seed;

void set_random_seed(uint16_t value) SDCCCALL0;

uint16_t xorshift() SDCCCALL0;

uint32_t read_clock() SDCCCALL0;

#endif /* INPUT_H */
