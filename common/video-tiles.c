#include "video-tiles.h"
#include "minefield.h"


/* declare draw_single_cell according to tile size */
#ifdef _16X16_METATILES
#include "tiles/16x16.c"
#else
#include "tiles/8x8.c"
#endif /* _16X16_TILES */


void draw_minefield_contents(minefield *mf)
{
	for (uint8_t x = 0; x < mf->width; x++) {
		for (uint8_t y = 0; y < mf->height; y++) {
			draw_single_cell(mf, x, y);
		}
	}

	uint8_t x = CURRENT_CELL_X(mf);
	uint8_t y = CURRENT_CELL_Y(mf);
	highlight_cell(mf, MINEFIELD_X_OFFSET + x * 2 + 1,
	               MINEFIELD_Y_OFFSET + y * 2 + 1);
}


void draw_minefield(minefield *mf)
{
	for (uint8_t x = 0; x <= mf->width; x++) {
		for (uint8_t y = 0; y <= mf->height; y++) {
			uint8_t xx = MINEFIELD_X_OFFSET + x * 2;
			uint8_t yy = MINEFIELD_Y_OFFSET + y * 2 - 1;
			if (y > 0 && y <= mf->height) {
				if (x == 0) {
					set_tile(xx, yy, MINEFIELD_VERTICAL_LEFT);
				} else if (x < mf->width) {
					set_tile(xx, yy, MINEFIELD_VERTICAL_MIDDLE);
				} else {
					set_tile(xx, yy, MINEFIELD_VERTICAL_RIGHT);
				}
			}

			if (x < mf->width - 1 && y < mf->height - 1)
				set_tile(xx + 2, yy + 3, MINEFIELD_CROSS);

			if (x > 0 && x <= mf->width) {
				xx--;
				yy++;
				if (y == 0) {
					set_tile(xx, yy, MINEFIELD_HORIZONTAL_TOP);
				} else if (y < mf->height) {
					set_tile(xx, yy, MINEFIELD_HORIZONTAL_MIDDLE);
				} else {
					set_tile(xx, yy, MINEFIELD_HORIZONTAL_BOTTOM);
				}
			}
		}
	}

	set_tile(MINEFIELD_X_OFFSET, MINEFIELD_Y_OFFSET, MINEFIELD_CORNER_TOP_LEFT);

	set_tile(MINEFIELD_X_OFFSET + mf->width * 2, MINEFIELD_Y_OFFSET,
	         MINEFIELD_CORNER_TOP_RIGHT);

	set_tile(MINEFIELD_X_OFFSET, MINEFIELD_Y_OFFSET + mf->height * 2,
	         MINEFIELD_CORNER_BOTTOM_LEFT);

	set_tile(MINEFIELD_X_OFFSET + mf->width * 2,
	         MINEFIELD_Y_OFFSET + mf->height * 2,
	         MINEFIELD_CORNER_BOTTOM_RIGHT);

	for (uint8_t x = 0; x <= mf->width; x++) {
		if (x > 0 && x < mf->width) {
			set_tile(MINEFIELD_X_OFFSET + x * 2, MINEFIELD_Y_OFFSET,
			         MINEFIELD_TOP_TEE);

			set_tile(MINEFIELD_X_OFFSET + x * 2,
			         MINEFIELD_Y_OFFSET + mf->height * 2, MINEFIELD_BOTTOM_TEE);
		}
	}

	for (uint8_t y = 1; y <= mf->height; y++) {
		if (y < mf->height) {
			set_tile(MINEFIELD_X_OFFSET, MINEFIELD_Y_OFFSET + y * 2,
			         MINEFIELD_LEFT_TEE);

			set_tile(MINEFIELD_X_OFFSET + mf->width * 2,
			         MINEFIELD_Y_OFFSET + y * 2, MINEFIELD_RIGHT_TEE);
		}
	}

	draw_minefield_contents(mf);
}


void draw_scenario()
{
	uint8_t x,y;

	for (x = 1; x < SCREEN_WIDTH - 1; x++) {
		for (y = 1; y < SCREEN_HEIGHT; y++) {
			set_tile(x, y, GROUND);
		}
	}

	set_tile(0, 0, CORNER_TOP_LEFT);
	set_tile(SCREEN_WIDTH - 1, 0, CORNER_TOP_RIGHT);
	set_tile(0, SCREEN_HEIGHT - 1, CORNER_BOTTOM_LEFT);
	set_tile(SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1, CORNER_BOTTOM_RIGHT);

	for (y=1; y<SCREEN_HEIGHT / 2; y++) {
		set_tile(0, y, LEFT_BORDER__TOP);
		set_tile(SCREEN_WIDTH - 1, y, RIGHT_BORDER__TOP);
	}

	for (y=SCREEN_HEIGHT / 2; y<SCREEN_HEIGHT - 1; y++) {
		set_tile(0, y, LEFT_BORDER__BOTTOM);
		set_tile(SCREEN_WIDTH - 1, y, RIGHT_BORDER__BOTTOM);
	}

	for (x=1; x<SCREEN_WIDTH / 2; x++) {
		set_tile(x, 0, TOP_BORDER__LEFT);
		set_tile(x, SCREEN_HEIGHT - 1, BOTTOM_BORDER__LEFT);
	}
	
	for (x=SCREEN_WIDTH / 2; x<SCREEN_WIDTH - 1; x++) {
		set_tile(x, 0, TOP_BORDER__RIGHT);
		set_tile(x, SCREEN_HEIGHT - 1, BOTTOM_BORDER__RIGHT);
	}
}

