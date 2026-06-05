; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to convert mappings (etc) to proper Mega Drive sprites
; ---------------------------------------------------------------------------

BldSpr_ScrPos:	dc.l 0					; blank
		dc.l v_screenposx&$FFFFFF		; main screen X-position
		dc.l v_bgscreenposx&$FFFFFF		; background X-position 1 (unused)
		dc.l v_bg3screenposx&$FFFFFF		; background X-position 2 (unused)

; ---------------------------------------------------------------------------

BuildSprites:
		lea	(v_spritetablebuffer).w,a2	; set address for sprite table
		moveq	#0,d5				; reset sprite counter to 0
		lea	(v_spritequeue).w,a4		; load sprite queue priority layers
		moveq	#spritequeue_layers-1,d7	; iterate through all eight layers

.priorityLoop:
		tst.w	(a4)				; are there objects left to draw in current priority layer?
		beq.w	.nextPriority			; if not, go to next priority layer

		moveq	#spritequeue_counter,d6		; initialize offset pointer to first object after entry counter (2 bytes)
	.objectLoop:
		movea.w	(a4,d6.w),a0			; load object ID
		tst.b	(a0)				; has an object been queued for display but deleted?
		beq.w	.skipObject			; if yes, skip (this appears to be an effort to fix display-and-delete bugs)
		bclr	#7,obRender(a0)			; set object as not visible

	; --- Coordinate system ---
		move.b	obRender(a0),d0			; get object's render flags
		move.b	d0,d4				; backup for later
		andi.w	#%1100,d0			; get drawing coordinate system (bit 2-3)
		beq.s	.screenCoords			; branch if 0 (screen-positioning coordinate system)
		movea.l	BldSpr_ScrPos(pc,d0.w),a1	; get relative screen position (in practice, only v_screenposx is ever used)

	; --- Screen bounds check for X-position ---
		moveq	#0,d0				; clear d0
		move.b	obActWid(a0),d0			; get object display width
		move.w	obX(a0),d3			; get object's X-position
		sub.w	(a1),d3				; subtract relative screen X-position
		move.w	d3,d1				; remember difference result
		add.w	d0,d1				; add object display width
		bmi.w	.skipObject			; if underflowed, left edge is out of bounds
		move.w	d3,d1				; restore difference result
		sub.w	d0,d1				; subtract object display width
		cmpi.w	#320,d1				; is result greater than the screen width? (320px)
		bge.s	.skipObject			; if yes, right edge is out of bounds
		addi.w	#sprites_basepos,d3		; VDP sprites start at 128px

	; --- Screen bounds check for Y-position ---
		btst	#4,d4				; is custom height flag set?
		beq.s	.assumeHeight			; if not, assume height instead

		moveq	#0,d0				; clear d0
		move.b	obHeight(a0),d0			; get custom object height
		move.w	obY(a0),d2			; get object's Y-position
		sub.w	4(a1),d2			; subtract relative screen Y-position
		move.w	d2,d1				; remember result
		add.w	d0,d1				; add object display height
		bmi.s	.skipObject			; if underflowed, top edge is out of bounds
		move.w	d2,d1				; restore difference result
		sub.w	d0,d1				; subtract object display height
		cmpi.w	#224,d1				; is result greater than the screen height? (224px)
		bge.s	.skipObject			; if yes, bottom edge is out of bounds
		addi.w	#sprites_basepos,d2		; VDP sprites start at 128px
		bra.s	.drawObject			; skip over
; ---------------------------------------------------------------------------

	.screenCoords:
		move.w	obScreenY(a0),d2		; special variable for screen Y
		move.w	obX(a0),d3			; get object's X-position
		bra.s	.drawObject			; skip over
; ---------------------------------------------------------------------------

	.assumeHeight:
		.ah:	equ 32				; assumed height is 32px ($20)
		move.w	obY(a0),d2			; get object's Y-position
		sub.w	4(a1),d2			; subtract relative screen Y-position (v_screenposy)
		addi.w	#sprites_basepos,d2		; VDP sprites start at 128px
		cmpi.w	#sprites_basepos-.ah,d2		; is top Y-position more than 32px out of bounds?
		blo.s	.skipObject			; if yes, assumed height top edge is out of bounds
		cmpi.w	#sprites_basepos+224+.ah,d2	; is bottom Y-position more than 32px out of bounds?
		bhs.s	.skipObject			; if yes, assumed height bottom edge is out of bounds

	; --- Load sprite mappings ---
	.drawObject:
		movea.l	obMap(a0),a1			; get absolute object mappings pointer

		moveq	#1-1,d1				; write only one sprite for raw-mappings
		btst	#5,d4				; is "raw-mappings" flag on?
		bne.s	.drawFrame			; if yes, branch (assume mappings point to a single sprite piece)

		move.b	obFrame(a0),d1			; get current object frame ID
		add.b	d1,d1				; double it for word-based indexing
		adda.w	(a1,d1.w),a1			; get mappings frame address
		move.b	(a1)+,d1			; get number of sprite pieces in frame
		subq.b	#1,d1				; subtract 1 for dbf
		bmi.s	.setVisible			; if result underflowed, this is was blank frame mapping, branch

	; --- Do the actual sprite mapping rendering ---
	.drawFrame:
		bsr.w	BuildSpr_Draw			; write data from sprite pieces to buffer, potentially flipped

	.setVisible:
		bset	#7,obRender(a0)			; set object as visible

	.skipObject:
		addq.w	#2,d6				; advance to next entry in sprite priority layer
		subq.w	#2,(a4)				; decrement number of objects left in sprite priority layer
		bne.w	.objectLoop			; if more objects are left to render, loop

.nextPriority:
		lea	spritequeue_layersize(a4),a4	; advance to next sprite priority layer (each layer is $80 bytes)
		dbf	d7,.priorityLoop		; loop for all 8 layers

		move.b	d5,(v_spritecount).w		; write total number of rendered sprites to debug value

		cmpi.b	#sprites_max,d5			; check sprite limit (Mega Drive can only handle 80 at a time)
	if FixBugs
		bhs.s	.spriteLimit			; if all sprite slots are taken up (or more), abort process
	else
		; See notes below.
		beq.s	.spriteLimit			; if all sprite slots are taken up (exactly), abort process
	endif

		move.l	#0,(a2)				; unlink last sprite
		rts					; return
; ---------------------------------------------------------------------------

	.spriteLimit:
		move.b	#0,-5(a2)			; unlink penultimate sprite
		rts					; return
; End of function BuildSprites


; ===========================================================================
; ---------------------------------------------------------------------------
; Each sprite piece is exactly 5 bytes long. Broken down into bits,
; they have the format "TTTTTTTT ----WWHH PCCYXAAA AAAAAAAA LLLLLLLL":
; 
; Value | Size    | Description
; -----------------------------
; T     | Byte    | Top relative coordinate of where the piece appears
; -     | 4 bits  | Always null/unused
; W     | 2 bits  | Width of the piece, in tiles minus one:
;       |         |   0 => 8 pixels wide
;       |         |   1 => 16 pixels wide
;       |         |   2 => 24 pixels wide
;       |         |   3 => 32 pixels wide
; H     | 2 bits  | Height of the piece, in the same format as the width WW
; P     | 1 bit   | Priority flag. If set, the piece will appear above everything else
; C     | 2 bits  | Palette line number
; X     | 1 bit   | X-flip-flag. If set, the piece will be flipped horizontally
; Y     | 1 bit   | Y-flip-flag. If set, the piece will be flipped vertically
; A     | 11 bits | Relative art tile index, spread across two bytes
; L     | Byte    | Left relative coordinate of where the piece appears
; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for BuildSpr_Draw, to visualize the differences between the flips.
; All four variants work on the same basic principle, only coming with
; modifications for the flipping.
; 
; input:
;	d1 = number of sprite pieces in mapping minus 1
;	d2 = base Y-position
;	d3 = base X-position
;	d5 = total rendered sprites so far (max 80)
;	a1 = pointer to starting sprite piece in sprite mappings (see breakdown above)
;	a2 = pointer to sprite link buffer (v_spritetablebuffer)
;	a3 = art tile / VRAM setting (obGfx)
;
; 	uses d0.w, d4.w
; ---------------------------------------------------------------------------

buildsprite:	macro xflip,yflip

.loopSpritePieces:
	; --- Sprite limit check ---
		cmpi.b	#sprites_max,d5			; check sprite limit (Mega Drive can only handle 80 at a time)
	if FixBugs
		bhs.s	.return				; if all sprite slots are taken up (or more), abort process
	else
		; This checks if the sprite buffer contains EXACTLY 80 entries, but
		; it will still continue should it somehow end up with MORE, which
		; is very dangerous. The above fix introduces no additional overhead.
		beq.s	.return				; if all sprite slots are taken up (exactly), abort process
	endif

	; --- Y-position ---
		move.b	(a1)+,d0			; get relative y-offset
		if yflip
			move.b	(a1),d4			; get width and height dimensions of sprite piece (WWHH)
			ext.w	d0			; extend y-offset to word
			neg.w	d0			; negate y-offset
			lsl.b	#3,d4			; multiply height dimension (HH) to multiple of 8px
			andi.w	#%11000,d4		; mask out non-height bits
			addq.w	#8,d4			; account of HH=0 being treated as a single 8px tile
			sub.w	d4,d0			; subtract result from negated Y position to get flipped Y position
		else
			ext.w	d0			; extend y-offset to word
		endif
		add.w	d2,d0				; add base Y-position
		move.w	d0,(a2)+			; write to buffer

	; --- Sprite width/height ---
		if xflip
			move.b	(a1)+,d4		; get width and height dimensions of sprite piece (backup for later)
			move.b	d4,(a2)+		; write dimension
		else
			move.b	(a1)+,(a2)+		; write width and height dimensions of sprite piece
		endif

	; --- Sprite link ---
		addq.b	#1,d5				; increase total sprites counter
		move.b	d5,(a2)+			; set sprites counter as sprite link

	; --- VRAM settings / art tile / flipping ---
		move.b	(a1)+,d0			; get first half of VRAM settings (flag and three bits of tile offset)
		lsl.w	#8,d0				; shift it to upper byte
		move.b	(a1)+,d0			; get second half of VRAM settings (remaining eight bits of tile offset)
		add.w	a3,d0				; add base art tile offset of object
		if xflip|yflip
			eori.w	#xflip<<11|yflip<<12,d0	; toggle X-flip ($800) and/or Y-flip ($1000) in VDP
		endif
		move.w	d0,(a2)+			; write sprite art tile and flags to buffer

	; --- X-position ---
		move.b	(a1)+,d0			; get relative x-offset
		ext.w	d0				; extend x-offset to word
		if xflip
			neg.w	d0			; negate x-offset
			add.b	d4,d4			; multiply width dimension (WW) to multiple of 8px
			andi.w	#%11000,d4		; mask out non-width bits
			addq.w	#8,d4			; account of WW=0 being treated as a single 8px tile
			sub.w	d4,d0			; subtract result from negated X-position to get flipped X-position
		endif
		add.w	d3,d0				; add X-position
		andi.w	#$1FF,d0			; keep within 512px (screen wrap)
		bne.s	.x				; is X-position zero? if not, branch
		addq.w	#1,d0				; force non-zero X-position to avoid unwanted sprite masking
	.x:	move.w	d0,(a2)+			; write to buffer

	; --- Loop for all pieces in mapping ---
		dbf	d1,.loopSpritePieces		; process next sprite piece

	.return:
		rts					; sprite rendering for this object done

	endm


; ---------------------------------------------------------------------------
; Subroutine to convert a object mapping frame (with multiple sprite pieces)
; into valid, linked Mega Drive sprites and buffer them, with flipping.
; ---------------------------------------------------------------------------

BuildSpr_Draw:
		movea.w	obGfx(a0),a3			; get art tile / VRAM settings for object

		btst	#0,d4				; is X-flip flag set?
		bne.s	BuildSpr_FlipX			; if yes, branch
		btst	#1,d4				; is Y-flip flag set?
		bne.w	BuildSpr_FlipY			; if yes, branch

BuildSpr_Normal:
		buildsprite	0,0			; draw sprite (no X-flip or Y-flip)
; ---------------------------------------------------------------------------

BuildSpr_FlipX:
		btst	#1,d4				; is object Y-flipped as well?
		bne.w	BuildSpr_FlipXY			; if yes, branch

		buildsprite	1,0			; draw sprite (X-flip, no Y-flip)
; ---------------------------------------------------------------------------

BuildSpr_FlipY:
		buildsprite	0,1			; draw sprite (no X-flip, Y-flip)
; ---------------------------------------------------------------------------

BuildSpr_FlipXY:
		buildsprite	1,1			; draw sprite (both X-flip and Y-flip)
; End of function BuildSpr_Draw
