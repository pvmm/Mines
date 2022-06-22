#include "../tiles.h"
#include "../minefield.h"


void draw_single_cell(minefield* mf, uint8_t x, uint8_t y)
{
	if (CELL(mf, x, y) & ISOPEN) {
		if (CELL(mf, x, y) & HASBOMB) {
			set_tile(MINEFIELD_X_OFFSET + x * 2 + 1,
					 MINEFIELD_Y_OFFSET + y * 2 + 1,
					 BOMB);
		} else {
			uint8_t tile_number = 0;
			uint8_t count = CELL(mf, x, y) & 0x0F;

			if (count > 0 && count < 9) {
				tile_number = ONE_BOMB + count - 1;
				set_tile(MINEFIELD_X_OFFSET + x * 2 + 1, 
				         MINEFIELD_Y_OFFSET + y * 2 + 1,
				         tile_number);
			} else {
				set_tile(MINEFIELD_X_OFFSET + x * 2 + 1,
				         MINEFIELD_Y_OFFSET + y * 2 + 1,
				         BLANK);
			}
		}
	} else {
		if (CELL(mf, x, y) & HASFLAG) {
			set_tile(MINEFIELD_X_OFFSET + x * 2 + 1,
					 MINEFIELD_Y_OFFSET + y * 2 + 1,
					 FLAG);
		} else if (CELL(mf, x, y) & HASQUESTIONMARK) {
			set_tile(MINEFIELD_X_OFFSET + x * 2 + 1,
					 MINEFIELD_Y_OFFSET + y * 2 + 1,
					 QUESTION_MARK);
		} else {
			set_tile(MINEFIELD_X_OFFSET + x * 2 + 1,
					 MINEFIELD_Y_OFFSET + y * 2 + 1,
					 CLOSED_CELL);
		}
	}
}
