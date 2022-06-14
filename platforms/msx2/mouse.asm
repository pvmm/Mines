; uint16_t read_any_mouse() SDCCCALL0
.globl _read_any_mouse

GTPAD = 0x00db
PORT1 = 12
PORT2 = 16

_read_any_mouse::
	ld a, #PORT1            ; check joy port 1
	call _read_port
	push hl                 ; save result
	ld a, #PORT2            ; check joy port 2
	call _read_port
	pop de
	add hl, de              ; add offsets as one

	ret

_read_port:
	push af
    call GTPAD
	inc a
	jr z, _read_input       ; found
	pop af
	ld hl, #0               ; no input, no offset
	ret

_read_input:
	pop bc                  ; use joy port specified in b
	inc b
	push bc
	ld a, b                 ; x offset
    call GTPAD
	pop bc
	inc b
	ld a, b                 ; y offset
    call GTPAD

	ret                     ; result in hl
