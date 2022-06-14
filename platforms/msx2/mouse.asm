.globl _search_mouse
.globl _read_mouse
.globl _has_mouse
.globl _mouse_x_offset
.globl _mouse_y_offset
.globl _mouse_button1
.globl _mouse_button2

GTPAD = 0x00db
GTTRIG = 0x00d8
PORT1 = 12
PORT2 = 16

_search_mouse::
	ld b, #60

search_mouse_loop:
	ei
	halt
	push bc
	call check_mouse
	pop bc

	ld a, (_has_mouse)
	jr nz, search_mouse_done
	djnz search_mouse_loop

search_mouse_done:
	ld a, (_has_mouse)
	ld l, a
	ret

check_mouse:
	ld a, #1
	ld (_has_mouse), a      ; is it mouse in port 1?

	ld b, #PORT1
	call read_mouse_dir

	ld a, (_mouse_x_offset)
	cp #1
	ret nz
	ld a, (_mouse_y_offset)
	cp #1
	ret nz

	ld a, #2                ; is it mouse in port 2?
	ld (_has_mouse), a

	ld b, #PORT2
	call read_mouse_dir

	ld a, (_mouse_x_offset)
	cp #1
	ret nz
	ld a, (_mouse_y_offset)
	cp #1
	ret nz
	xor a
	ld (_has_mouse), a

	ret

_read_mouse::
	xor a
	ld (_mouse_x_offset), a
	ld (_mouse_y_offset), a
	ld (_mouse_button1), a
	ld (_mouse_button2), a  ; clean position variables

	ld a, (_has_mouse)
	or a
	ret z                   ; no mouse detected

	ld b, #PORT1
	cp #1
	jr z, read_mouse_0      ; read mouse port #1

	ld b, #PORT2            ; read mouse port #2

read_mouse_0:
	call read_mouse_dir
	ld a, (_has_mouse)
	jp read_mouse_button

read_mouse_dir:
	ld a, b
	push bc                 ; save control index
	call GTPAD              ; first request
	pop bc                  ; restore control

	inc b                   ; x offset parameter
	ld a, b
	push bc
	call GTPAD              ; get x offset
	ld (_mouse_x_offset), a ; save value

	pop bc
	inc b                   ; y offset parameter
	ld a, b
	call GTPAD              ; get y offset
	ld (_mouse_y_offset), a ; save value

	ret

read_mouse_button:
	push af
	call GTTRIG
	ld (_mouse_button1), a 
	pop af

	inc a
	inc a
	call GTTRIG
	ld (_mouse_button2), a

	ret

.area _DATA

_has_mouse:
	.ds 1                   ; current mouse index, 0 = none

_mouse_x_offset:
	.ds 2

_mouse_y_offset:
	.ds 2

_mouse_button1:
	.ds 1

_mouse_button2:
	.ds 1

