; ---------------------------------------------------------------------------
; Subroutine to find which tile the object is standing on

; input:
;	d2 = y-position of object's bottom edge
;	d3 = x-position of object

; output:
;	a1 = address within 128x128 mappings where object is standing
;	     (refers to a 16x16 tile number)
; ---------------------------------------------------------------------------

FindNearestTile:
		move.w	d2,d0			; MJ: load Y position
		andi.w	#$780,d0		; MJ: get within 780 (E00 pixels) in multiples of 80
		add.w	d0,d0			; MJ: multiply by 2
		move.w	d3,d1			; MJ: load X position
		lsr.w	#7,d1			; MJ: shift to right side
		andi.w	#$7F,d1			; MJ: get within 7F
		add.w	d1,d0			; MJ: add calc'd Y to calc'd X
		moveq	#-1,d1			; MJ: prepare FFFF in d3
		lea	(v_lvllayout_fg).w,a1	; MJ: load address of Layout to a1
		move.b	(a1,d0.w),d1		; MJ: collect correct chunk ID based on the X and Y position
		andi.w	#$FF,d1			; MJ: keep within FF
		lsl.w	#7,d1			; MJ: multiply by 80
		move.w	d2,d0			; MJ: load Y position
		andi.w	#$70,d0			; MJ: keep Y within 80 pixels
		add.w	d0,d1			; MJ: add to ror'd chunk ID
		move.w	d3,d0			; MJ: load X position
		lsr.w	#3,d0			; MJ: divide by 8
		andi.w	#$E,d0			; MJ: keep X within 10 pixels
		add.w	d0,d1			; MJ: add to ror'd chunk ID

		movea.l	d1,a1			; MJ: set address (Chunk to read)
		rts				; MJ: return
; End of function FindNearestTile


; ---------------------------------------------------------------------------
; Subroutine to find the floor

; input:
;	d2 = y-position of object's bottom edge
;	d3 = x-position of object
;	d5 = bit to test for solidness

; output:
;	d1 = distance to the floor
;	a1 = address within 128x128 mappings where object is standing
;	     (refers to a 16x16 tile number)
;	(a4) = floor angle
; ---------------------------------------------------------------------------

FindFloor:
		bsr.s	FindNearestTile
		move.w	(a1),d0		; get value for solidness, orientation and 16x16 tile number
		move.w	d0,d4
		andi.w	#$3FF,d0	; MJ: ($800/2)-1
		beq.s	.isblank	; branch if tile is blank
		btst	d5,d4		; is the tile solid?
		bne.s	.issolid	; if yes, branch

.isblank:
		add.w	a3,d2
		bsr.w	FindFloor2	; try tile below the nearest
		sub.w	a3,d2
		addi.w	#$10,d1		; return distance to floor
		rts
; ===========================================================================

.issolid:
		movea.w	(v_collindex).w,a2	; MJ: load collision index address
		move.b	(a2,d0.w),d0		; MJ: load correct Collision ID based on the Block ID
		andi.w	#$FF,d0			; MJ: clear the left byte
		beq.s	.isblank		; MJ: if collision ID is 00, branch
		lea	(AngleMap).l,a2		; MJ: load angle map data to a2
		move.b	(a2,d0.w),(a4)		; MJ: collect correct angle based on the collision ID
		lsl.w	#4,d0			; MJ: multiply collision ID by 10
		move.w	d3,d1			; MJ: load X position
		btst	#$A,d4			; MJ: is the block mirrored?
		beq.s	.noflip			; MJ: if not, branch
		not.w	d1			; MJ: reverse bits of the X position
		neg.b	(a4)			; MJ: reverse the angle ID

.noflip:
		btst	#$B,d4			; MJ: is the block flipped?
		beq.s	.noflip2		; MJ: if not, branch
		addi.b	#$40,(a4)		; MJ: increase angle ID by 40..
		neg.b	(a4)			; MJ: ..reverse the angle ID..
		subi.b	#$40,(a4)		; MJ: ..and subtract 40 again

.noflip2:
		andi.w	#$F,d1			; MJ: get only within 10 (d1 is pixel based on the collision block)
		add.w	d0,d1			; MJ: add collision ID (x10) (d0 is the collision block being read)
		lea	(CollArray1).l,a2	; MJ: load collision array
		move.b	(a2,d1.w),d0		; MJ: load solid value
		ext.w	d0			; MJ: clear left byte
		eor.w	d6,d4			; MJ: set ceiling/wall bits
		btst	#$B,d4			; MJ: is sonic walking on the left wall?
		beq.s	.noflip3		; MJ: if not, branch
		neg.w	d0			; MJ: reverse solid value

.noflip3:
		tst.w	d0			; MJ: is the solid data null?
		beq.s	.isblank		; MJ: if so, branch
		bmi.s	.negfloor		; MJ: if it's negative, branch
		cmpi.b	#$10,d0			; MJ: is it 10?
		beq.s	.maxfloor		; MJ: if so, branch
		move.w	d2,d1			; MJ: load Y position
		andi.w	#$F,d1			; MJ: get only within 10 pixels
		add.w	d1,d0			; MJ: add to solid value
		move.w	#$F,d1			; MJ: set F
		sub.w	d0,d1			; MJ: minus solid value from F
		rts
; ===========================================================================

.negfloor:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	.isblank

.maxfloor:
		sub.w	a3,d2
		bsr.w	FindFloor2	; try tile above the nearest
		add.w	a3,d2
		subi.w	#$10,d1		; return distance to floor
		rts
; End of function FindFloor
; ===========================================================================


FindFloor2:
	if FixBugs
		move.w	d4,-(sp)
	endif
		bsr.w	FindNearestTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0	; MJ: ($800/2)-1
		beq.s	.isblank2
		btst	d5,d4
		bne.s	.issolid

.isblank2:
		move.w	#$F,d1
		move.w	d2,d0
		andi.w	#$F,d0
		sub.w	d0,d1
	if FixBugs
		move.w	(sp)+,d4
	endif
		rts
; ===========================================================================

.issolid:
		movea.w	(v_collindex).w,a2	; MJ: load collision index address
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	.isblank2
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$A,d4		; MJ: B to A (because S2 format has two solids)
		beq.s	.noflip
		not.w	d1
		neg.b	(a4)

.noflip:
		btst	#$B,d4		; MJ: C to B (because S2 format has two solids)
		beq.s	.noflip2
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

.noflip2:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(CollArray1).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4		; MJ: C to B (because S2 format has two solids)
		beq.s	.noflip3
		neg.w	d0

.noflip3:
		tst.w	d0
		beq.s	.isblank2
		bmi.s	.negfloor
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
	if FixBugs
		addq.w	#2,sp
	endif
		rts
; ===========================================================================

.negfloor:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	.isblank2
		not.w	d1
	if FixBugs
		addq.w	#2,sp
	endif
		rts
; End of function FindFloor2


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	find a wall

; input:
;	d2.w = y position of object's bottom edge
;	d3.w = x position of object
;	d5.l = bit to test for solidness: $D = top solid; $E = left/right/bottom solid
;	d6.w = eor bitmask for 16x16 tile
;	a3.w = height of 16x16 tiles: $10 or -$10 if object is inverted
;	a4 = RAM address to write angle byte

; output:
;	d1.w = distance to the wall
;	a1 = address within 256x256 mappings where object is standing
;	(a1).w = 16x16 tile number, x/yflip, solidness
;	(a4).b = floor angle

;	uses d0.w, d3.w, d4.w
; ---------------------------------------------------------------------------

FindWall:
		bsr.w	FindNearestTile				; a1 = address within 256x256 mappings of 16x16 tile being stood on
		move.w	(a1),d0					; get value for solidness, orientation and 16x16 tile number
		move.w	d0,d4
		andi.w	#$3FF,d0		; MJ: clear flip/mirror/etc data
		beq.s	.isblank				; branch if tile is blank
		btst	d5,d4					; is the tile solid?
		bne.s	.issolid				; if yes, branch

.isblank:
		add.w	a3,d3
		bsr.w	FindWall2				; try tile to the right
		sub.w	a3,d3
		addi.w	#$10,d1					; return distance to wall
		rts	
; ===========================================================================

.issolid:
		movea.w	(v_collindex).w,a2
		move.b	(a2,d0.w),d0				; get collision heightmap id
		andi.w	#$FF,d0					; heightmap id is 1 byte
		beq.s	.isblank				; branch if 0
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)				; get collision angle value
		lsl.w	#4,d0					; d0 = heightmap id * $10 (the width of a heightmap for 1 tile)
		move.w	d2,d1					; get y pos of object
		btst	#$B,d4			; MJ: is the block ID flipped?
		beq.s	.no_yflip				; if not, branch
		not.w	d1
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)				; yflip angle

	.no_yflip:
		btst	#$A,d4			; MJ: B to A (because S2 format has two solids)
		beq.s	.no_xflip				; if not, branch
		neg.b	(a4)					; xflip angle

	.no_xflip:
		andi.w	#$F,d1					; read only low nybble of x pos (i.e. x pos within 16x16 tile)
		add.w	d0,d1					; (id * $10) + x pos. = place in heightmap data
		lea	(CollArray2).l,a2
		move.b	(a2,d1.w),d0				; get actual height value from heightmap
		ext.w	d0
		eor.w	d6,d4					; apply x/yflip (allows for double-flip cancellation)
		btst	#$A,d4			; MJ: B to A (because S2 format has two solids)
		beq.s	.no_xflip2				; if not, branch
		neg.w	d0

	.no_xflip2:
		tst.w	d0
		beq.s	.isblank				; branch if height is 0
		bmi.s	.negfloor				; branch if height is negative
		cmpi.b	#$10,d0
		beq.s	.maxfloor				; branch if height is $10 (max)
		move.w	d3,d1					; get x pos of object
		andi.w	#$F,d1					; read only low nybble for x pos within 16x16 tile
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1					; return distance to wall
		rts	

.negfloor:
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	.isblank

.maxfloor:
		sub.w	a3,d3
		bsr.w	FindWall2				; try tile to the left
		add.w	a3,d3
		subi.w	#$10,d1					; return distance to wall
		rts
; End of function FindWall

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	find a wall left/right of the current 16x16 tile
; ---------------------------------------------------------------------------

FindWall2:
	if FixBugs
		move.w	d4,-(sp)
	endif
		bsr.w	FindNearestTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0	; MJ: ($800/2)-1
		beq.s	.isblank
		btst	d5,d4
		bne.s	.issolid

.isblank:
		move.w	#$F,d1
		move.w	d3,d0
		andi.w	#$F,d0
		sub.w	d0,d1
	if FixBugs
		move.w	(sp)+,d4
	endif
		rts	
; ===========================================================================

.issolid:
		movea.w	(v_collindex).w,a2
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	.isblank
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d2,d1
		btst	#$B,d4		; MJ: C to B (because S2 format has two solids)
		beq.s	.no_yflip
		not.w	d1
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

	.no_yflip:
		btst	#$A,d4		; MJ: B to A (because S2 format has two solids)
		beq.s	.no_xflip
		neg.b	(a4)

	.no_xflip:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(CollArray2).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$A,d4		; MJ: B to A (because S2 format has two solids)
		beq.s	.no_xflip2
		neg.w	d0

	.no_xflip2:
		tst.w	d0
		beq.s	.isblank
		bmi.s	.negfloor
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
	if FixBugs
		addq.w	#2,sp
	endif
		rts	
; ===========================================================================

.negfloor:
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	.isblank
		not.w	d1
	if FixBugs
		addq.w	#2,sp
	endif
		rts
; End of function FindWall2