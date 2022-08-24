#include <string.h>
#include <stdbool.h>
#include "msx2.h"
#include "common.h"
#include "game.h"
#include "video.h"
#include "mplayer.h"
#include "mouse.h"
#include "minefield.h"


// Arkos data
extern uint8_t SONG[];
extern uint8_t EFFECTS[];


// sub-songs matching our Arkos song
// configure the song to use MSX AY
enum songs
{
    SONG_SILENCE = 0,
    SONG_IN_GAME,
    SONG_GAME_OVER,
};


void platform_init()
{
    set_random_seed(read_clock());
    video_init();

    // init the player
    mplayer_init(SONG, SONG_SILENCE);
    mplayer_init_effects(EFFECTS);
}


void platform_shutdown()
{
    // Cartridge games can't unload.
    __asm__("jp 0");
}


void start_game()
{
    mplayer_init(SONG, SONG_IN_GAME);
}

void end_game()
{
    mplayer_init(SONG, SONG_SILENCE);
}


//extern inline void update_mouse(minefield* mf, uint8_t source);
void idle_update(minefield* mf)
{
    mf;
    static uint8_t ignore_input = 0;
    static uint8_t mouse1 = 0;
    static uint8_t mouse2 = 0;
    static uint8_t source = 0xff;
    static uint8_t fifth = 0;

    switch (++fifth) {
        case 4: {
            /* count how many times mouse is not found */
            int8_t mouse = search_mouse();
            switch (mouse) {
            case -1:
                ignore_input++;
                break;
            case 1:
                ignore_input = 0;
                if (source == 0xff && mouse1 > IGNORE_MOUSE_THRESHOLD) {
                    debug_msg("mouse1 detected\n");
                    mouse2 = 0;
                    source = 1;
                }
                mouse1++;
                break;
            case 2:
                ignore_input = 0;
                if (source == 0xff && mouse2 > IGNORE_MOUSE_THRESHOLD) {
                    debug_msg("mouse2 detected\n");
                    mouse1 = 0;
                    source = 2;
                }
                mouse2++;
                break;
            default:
                ignore_input = 0;
                break;
            }
        }
        case 5:
            fifth = 0;
            if (ignore_input > IGNORE_MOUSE_THRESHOLD) {
                hide_mouse();
                source = 0xff;
            } else if (source != 0xff) {
                update_mouse(mf, source);
            }
            break;
        default:
            break;
    }

    mplayer_play();
}
