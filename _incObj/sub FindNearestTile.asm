; ---------------------------------------------------------------------------
; Subroutine to find which tile the object is standing on

; input:
;	d2 = y-position of object's bottom edge
;	d3 = x-position of object

; output:
;	a1 = address within 256x256 mappings where object is standing
;	     (refers to a 16x16 tile number)
; ---------------------------------------------------------------------------

FindNearestTile:
		move.w	d2,d0		; get y-pos. of bottom edge of object
		lsr.w	#1,d0
		andi.w	#$380,d0
		move.w	d3,d1		; get x-pos. of object
		lsr.w	#8,d1
		andi.w	#$7F,d1
		add.w	d1,d0		; combine
		moveq	#$FFFFFFFF,d1	; = -1 (prefill to prepare creating a RAM address)
		lea	(v_lvllayout_fg).w,a1
		move.b	(a1,d0.w),d1	; get 256x256 tile number
		beq.s	.blanktile	; branch if 0 (blank chunk)
		bmi.s	.specialtile	; branch if >$7F
		subq.b	#1,d1
		ext.w	d1
		ror.w	#7,d1
		move.w	d2,d0
		add.w	d0,d0
		andi.w	#$1E0,d0
		add.w	d0,d1
		move.w	d3,d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		add.w	d0,d1

    if FixBugs
		movea.l	d1,a1
		rts

		; The regular branch to .blanktile will result in d1 being set to $FFFFFF00,
		; which will be returned in a1 and subsequently be used as the RAM location
		; for blank chunk collision. By luck, that address (v_chunk0collision) is
		; never changed from 0, so it doesn't cause any trouble in the final game,
		; but it is still incredibly dangerous and requires RAM to be laid out in a
		; specific way so it doesn't break, which is why it has an assembly check.
		; With this fix, blank chunks instead use a fixed ROM location that always
		; contains a 0 word. This will also remove the need for that assembly check.

	.blanktile:
		lea	.chunk0(pc),a1
		rts

	.chunk0:
		dc.w 0
    else
	.blanktile:
		movea.l	d1,a1
		rts
    endif

; ===========================================================================

.specialtile:
		andi.w	#$7F,d1
		btst	#6,obRender(a0) ; is object "behind a loop"?
		beq.s	.treatasnormal	; if not, branch
		addq.w	#1,d1
		cmpi.w	#$29,d1
		bne.s	.treatasnormal
		move.w	#$51,d1

.treatasnormal:
		subq.b	#1,d1
		ror.w	#7,d1
		move.w	d2,d0
		add.w	d0,d0
		andi.w	#$1E0,d0
		add.w	d0,d1
		move.w	d3,d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		add.w	d0,d1
		movea.l	d1,a1
		rts
; End of function FindNearestTile
