#ifndef VIDEO_TILES_H
#define VIDEO_TILES_H

#include <stdint.h>
#include "minefield.h"

/**
 * Required. Set the tile at (`x`, `y`) board coordinates to the tile defined
 * by `tile` index.
 *
 * Implementation details
 * ----------------------
 *
 * See [tile_index](#tile_index) for tile index values.
 */
void set_tile(uint8_t x, uint8_t y, uint8_t tile);

/* define cell size */
#ifdef _2X2_CELLS
#define CELL_W 2
#define CELL_H 2
#else
#define CELL_W 1
#define CELL_H 1
#endif /* _2X2_CELLS */

/**
 * Optional. Set the metatile at (`x` .. `x + 1`, `y` .. `y + 1`) board
 * coordinates starting with the `tile` index that represents the upper left
 * tile if `_2x2_CELLS` is defined.
 *
 * Implementation details
 * ----------------------
 *
 * See [tile_index](#tile_index) for tile index values.
 */
void set_group(uint8_t x, uint8_t y, uint8_t tile);

/**
 * Draws a cell identified by `tile` index on the board.
 *
 * Implementation details
 * ----------------------
 *
 * if `_2x2_CELLS` is defined `draw_single_cell()` draws a group of tiles or
 * ("metatiles") on the board at position (`x` .. `x + 1`, `y` .. `y + 1`)
 * starting with the `tile` index that represents the upper left tile.
 *
 * Otherwise, a cell has the same size of a single tile.
 *
 * See [tile_index](#tile_index) for tile index values.
 */
void draw_single_cell(minefield* mf, uint8_t x, uint8_t y);

/**
 * Provided. Draw the background image that lays around the board.
 *
 * Note: some platforms use the `GROUND` tile to cover the whole background
 * area.
 *
 * See [tile_index](#tile_index) for the index value of the `GROUND` tile.
 */
void draw_scenario();

/**
 * Required. Draw a tile or sprite cursor on the specified board position
 * defined by the (`x`, `y`) coordinates.
 *
 * Implementation details
 * ----------------------
 * 
 * If game status is `GAME_OVER`, the current cursor should be replaced by
 * (or drawn together with) an `EXPLOSION` tile.
 *
 * See [tile_index](#tile_index) for the index value of the `EXPLOSION` tile.
 */
void highlight_cell(minefield* mf, int x, int y);


enum tile_index {
	/*	NOTE:
		The tile codes for the number
		of bombs *MUST* be sequential
		because the video code assumes
		that to be the case.	*/
    ONE_BOMB,
    TWO_BOMBS,
    THREE_BOMBS,
    FOUR_BOMBS,
    FIVE_BOMBS,
    SIX_BOMBS,
    SEVEN_BOMBS,
    EIGHT_BOMBS,
    
    BLANK,
    CURSOR,
    BOMB,
    FLAG,
    QUESTION_MARK,
    EXPLOSION,
    GROUND,
    MINEFIELD_CORNER_TOP_LEFT,
    MINEFIELD_TOP_TEE,
    MINEFIELD_HORIZONTAL_TOP,
    MINEFIELD_CORNER_TOP_RIGHT,

    CORNER_TOP_LEFT,
    TOP_BORDER__LEFT,
    TOP_BORDER__RIGHT,
    CORNER_TOP_RIGHT,
    LEFT_BORDER__TOP,
    RIGHT_BORDER__TOP,
    LEFT_BORDER__BOTTOM,
    RIGHT_BORDER__BOTTOM,
    CORNER_BOTTOM_LEFT,
    BOTTOM_BORDER__LEFT,
    BOTTOM_BORDER__RIGHT,
    CORNER_BOTTOM_RIGHT,

    MINEFIELD_LEFT_TEE,
    MINEFIELD_CROSS,
    MINEFIELD_HORIZONTAL_MIDDLE,
    MINEFIELD_VERTICAL_MIDDLE,
    MINEFIELD_RIGHT_TEE,
    MINEFIELD_VERTICAL_LEFT,
    CLOSED_CELL,
    MINEFIELD_VERTICAL_RIGHT,
    MINEFIELD_CORNER_BOTTOM_LEFT,
    MINEFIELD_BOTTOM_TEE,
    MINEFIELD_HORIZONTAL_BOTTOM,
    MINEFIELD_CORNER_BOTTOM_RIGHT,

    /* Insert new tiles here */

    MAX_VIDEO_TILES,
};

#endif /* VIDEO_TILES_H */
