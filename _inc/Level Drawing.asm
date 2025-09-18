; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_6886:
LoadTilesAsYouMove_BGOnly:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_bg1_scroll_flags).w,a2
		lea	(v_bgscreenposx).w,a3
		lea	(v_lvllayout+$40).w,a4
		move.w	#$6000,d2
		bsr.w	DrawBGScrollBlock1
		lea	(v_bg2_scroll_flags).w,a2
		lea	(v_bg2screenposx).w,a3
		bra.w	DrawBGScrollBlock2
; End of function sub_6886

; ---------------------------------------------------------------------------
; Subroutine to display correct tiles as you move
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesAsYouMove:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		; First, update the background
		lea	(v_bg1_scroll_flags_dup).w,a2	; Scroll block 1 scroll flags
		lea	(v_bgscreenposx_dup).w,a3	; Scroll block 1 X coordinate
		lea	(v_lvllayout+$40).w,a4
		move.w	#$6000,d2			; VRAM thing for selecting Plane B
		bsr.w	DrawBGScrollBlock1
		lea	(v_bg2_scroll_flags_dup).w,a2	; Scroll block 2 scroll flags
		lea	(v_bg2screenposx_dup).w,a3	; Scroll block 2 X coordinate
		bsr.w	DrawBGScrollBlock2
		; Then, update the foreground
		lea	(v_fg_scroll_flags_dup).w,a2	; Foreground scroll flags
		lea	(v_screenposx_dup).w,a3		; Foreground X coordinate
		lea	(v_lvllayout).w,a4
		move.w	#$4000,d2			; VRAM thing for selecting Plane A
		; The FG's update function is inlined here
		tst.b	(a2)
		beq.s	locret_6952	; If there are no flags set, nothing needs updating
		bclr	#0,(a2)
		beq.s	loc_6908
		; Draw new tiles at the top
		moveq	#-16,d4	; Y coordinate. Note that 16 is the size of a block in pixels
		moveq	#-16,d5 ; X coordinate
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4 ; Y coordinate
		moveq	#-16,d5 ; X coordinate
		bsr.w	DrawBlocks_LR

loc_6908:
		bclr	#1,(a2)
		beq.s	loc_6922
		; Draw new tiles at the bottom
		move.w	#224,d4	; Start at bottom of the screen. Since this draws from top to bottom, we don't need 224+16
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_LR

loc_6922:
		bclr	#2,(a2)
		beq.s	loc_6938
		; Draw new tiles on the left
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_TB

loc_6938:
		bclr	#3,(a2)
		beq.s	locret_6952
		; Draw new tiles on the right
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	DrawBlocks_TB

locret_6952:
		rts
; End of function LoadTilesAsYouMove


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_6954:
DrawBGScrollBlock1:
		tst.b	(a2)
		beq.w	locret_69F2
		bclr	#0,(a2)
		beq.s	loc_6972
		; Draw new tiles at the top
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		moveq	#(512/16)-1,d6	 ; Draw entire row of plane
		bsr.w	DrawBlocks_LR_2

loc_6972:
		bclr	#1,(a2)
		beq.s	loc_698E
		; Draw new tiles at the top
		move.w	#224,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224,d4
		moveq	#-16,d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_2

loc_698E:
		bclr	#2,(a2)
		beq.s	loc_69BE
		; Draw new tiles on the left
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		move.w	(v_scroll_block_1_size).w,d6
		move.w	4(a3),d1
		andi.w	#-16,d1		; Floor camera Y coordinate to the nearest block
		sub.w	d1,d6
		blt.s	loc_69BE	; If scroll block 1 is offscreen, skip loading its tiles
		lsr.w	#4,d6		; Get number of rows not above the screen
		cmpi.w	#((224+16+16)/16)-1,d6
		blo.s	loc_69BA
		moveq	#((224+16+16)/16)-1,d6	; Cap at height of screen

loc_69BA:
		bsr.w	DrawBlocks_TB_2

loc_69BE:
		bclr	#3,(a2)
		beq.s	locret_69F2
		; Draw new tiles on the right
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		move.w	#320,d5
		move.w	(v_scroll_block_1_size).w,d6
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d6
		blt.s	locret_69F2
		lsr.w	#4,d6
		cmpi.w	#((224+16+16)/16)-1,d6
		blo.s	loc_69EE
		moveq	#((224+16+16)/16)-1,d6

loc_69EE:
		bsr.w	DrawBlocks_TB_2

locret_69F2:
		rts
; End of function DrawBGScrollBlock1


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Essentially, this draws everything that isn't scroll block 1
; sub_69F4:
DrawBGScrollBlock2:
		tst.b	(a2)
		beq.w	locret_6A80
		bclr	#2,(a2)
		beq.s	loc_6A3E
		; Draw new tiles on the left
		cmpi.w	#16,(a3)
		blo.s	loc_6A3E
		move.w	(v_scroll_block_1_size).w,d4
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d4	; Get remaining coverage of screen that isn't scroll block 1
		move.w	d4,-(sp)
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	(sp)+,d4
		moveq	#-16,d5
		move.w	(v_scroll_block_1_size).w,d6
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d6
		blt.s	loc_6A3E	; If scroll block 1 is completely offscreen, branch?
		lsr.w	#4,d6
		subi.w	#((224+16)/16)-1,d6	; Get however many of the rows on screen are not scroll block 1
		bhs.s	loc_6A3E
		neg.w	d6
		bsr.w	DrawBlocks_TB_2

loc_6A3E:
		bclr	#3,(a2)
		beq.s	locret_6A80
		; Draw new tiles on the right
		move.w	(v_scroll_block_1_size).w,d4
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos
		move.w	(sp)+,d4
		move.w	#320,d5
		move.w	(v_scroll_block_1_size).w,d6
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d6
		blt.s	locret_6A80
		lsr.w	#4,d6
		subi.w	#((224+16)/16)-1,d6
		bhs.s	locret_6A80
		neg.w	d6
		bsr.w	DrawBlocks_TB_2

locret_6A80:
		rts
; End of function DrawBGScrollBlock2

; ===========================================================================

; Abandoned unused scroll block code.
; This would have drawn a scroll block that started at 208 pixels down, and was 48 pixels long.
		tst.b	(a2)
		beq.s	locret_6AD6
		bclr	#2,(a2)
		beq.s	loc_6AAC
		; Draw new tiles on the left
		move.w	#224-16,d4	; Note that full screen coverage is normally 224+16+16. This is exactly three blocks less.
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos_Unknown
		move.w	(sp)+,d4
		moveq	#-16,d5
		moveq	#3-1,d6	; Draw only three rows
		bsr.w	DrawBlocks_TB_2

loc_6AAC:
		bclr	#3,(a2)
		beq.s	locret_6AD6
		; Draw new tiles on the right
		move.w	#224-16,d4
		move.w	4(a3),d1
		andi.w	#-16,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos_Unknown
		move.w	(sp)+,d4
		move.w	#320,d5
		moveq	#3-1,d6
		bsr.w	DrawBlocks_TB_2

locret_6AD6:
		rts


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Don't be fooled by the name: this function's for drawing from left to right
; when the camera's moving up or down
; DrawTiles_LR:
DrawBlocks_LR:
		moveq	#((320+16+16)/16)-1,d6	; Draw the entire width of the screen + two extra columns
; DrawTiles_LR_2:
DrawBlocks_LR_2:
		move.l	#$800000,d7	; Delta between rows of tiles
		move.l	d0,d1

.loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData
		move.l	d1,d0
		bsr.w	DrawBlock
		addq.b	#4,d1		; Two tiles ahead
		andi.b	#$7F,d1		; Wrap around row
		movem.l	(sp)+,d4-d5
		addi.w	#16,d5		; Move X coordinate one block ahead
		dbf	d6,.loop
		rts
; End of function DrawBlocks_LR


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Don't be fooled by the name: this function's for drawing from top to bottom
; when the camera's moving left or right
; DrawTiles_TB:
DrawBlocks_TB:
		moveq	#((224+16+16)/16)-1,d6	; Draw the entire height of the screen + two extra rows
; DrawTiles_TB_2:
DrawBlocks_TB_2:
		move.l	#$800000,d7	; Delta between rows of tiles
		move.l	d0,d1

.loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData
		move.l	d1,d0
		bsr.w	DrawBlock
		addi.w	#$100,d1	; Two rows ahead
		andi.w	#$FFF,d1	; Wrap around plane
		movem.l	(sp)+,d4-d5
		addi.w	#16,d4		; Move X coordinate one block ahead
		dbf	d6,.loop
		rts
; End of function DrawBlocks_TB_2


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Draws a block's worth of tiles
; Parameters:
; a0 = Pointer to block metadata (block index and X/Y flip)
; a1 = Pointer to block
; a5 = Pointer to VDP command port
; a6 = Pointer to VDP data port
; d0 = VRAM command to access plane
; d2 = VRAM plane A/B specifier
; d7 = Plane row delta
; DrawTiles:
DrawBlock:
		or.w	d2,d0	; OR in that plane A/B specifier to the VRAM command
		swap	d0
		btst	#4,(a0)	; Check Y-flip bit
		bne.s	DrawFlipY
		btst	#3,(a0)	; Check X-flip bit
		bne.s	DrawFlipX
		move.l	d0,(a5)
		move.l	(a1)+,(a6)	; Write top two tiles
		add.l	d7,d0		; Next row
		move.l	d0,(a5)
		move.l	(a1)+,(a6)	; Write bottom two tiles
		rts
; ===========================================================================

DrawFlipX:
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4	; Invert X-flip bits of each tile
		swap	d4		; Swap the tiles around
		move.l	d4,(a6)		; Write top two tiles
		add.l	d7,d0		; Next row
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4
		swap	d4
		move.l	d4,(a6)		; Write bottom two tiles
		rts
; ===========================================================================

DrawFlipY:
		btst	#3,(a0)
		bne.s	DrawFlipXY
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$10001000,d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$10001000,d5
		move.l	d5,(a6)
		rts
; ===========================================================================

DrawFlipXY:
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$18001800,d4
		swap	d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$18001800,d5
		swap	d5
		move.l	d5,(a6)
		rts
; End of function DrawBlocks

; ===========================================================================
; unused garbage
; This is interesting. It draws a block, but not before
; incrementing its palette lines by 1. This may have been
; a debug function to discolour mirrored tiles, to test
; if they're loading properly.
		rts
		move.l	d0,(a5)
		move.w	#$2000,d5
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Gets address of block at a certain coordinate
; Parameters:
; a4 = Pointer to level layout
; d4 = Relative Y coordinate
; d5 = Relative X coordinate
; Returns:
; a0 = Address of block metadata
; a1 = Address of block
; DrawBlocks:
GetBlockData:
		lea	(v_16x16).w,a1
		add.w	4(a3),d4	; Add camera Y coordinate to relative coordinate
		add.w	(a3),d5		; Add camera X coordinate to relative coordinate
		; Turn Y coordinate into index into level layout
		move.w	d4,d3
		lsr.w	#1,d3
		andi.w	#$380,d3
		; Turn X coordinate into index into level layout
		lsr.w	#3,d5
		move.w	d5,d0
		lsr.w	#5,d0
		andi.w	#$7F,d0
		; Get chunk from level layout
		add.w	d3,d0
		moveq	#-1,d3
		move.b	(a4,d0.w),d3
		beq.s	locret_6C1E	; If chunk 00, just return a pointer to the first block (expected to be empty)
		; Turn chunk ID into index into chunk table
		subq.b	#1,d3
		andi.w	#$7F,d3
		ror.w	#7,d3
		; Turn Y coordinate into index into chunk
		add.w	d4,d4
		andi.w	#$1E0,d4
		; Turn X coordinate into index into chunk
		andi.w	#$1E,d5
		; Get block metadata from chunk
		add.w	d4,d3
		add.w	d5,d3
		movea.l	d3,a0
		move.w	(a0),d3
		; Turn block ID into address
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		adda.w	d3,a1

locret_6C1E:
		rts
; End of function GetBlockData


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Produces a VRAM plane access command from coordinates
; Parameters:
; d4 = Relative Y coordinate
; d5 = Relative X coordinate
; Returns VDP command in d0
Calc_VRAM_Pos:
		add.w	4(a3),d4	; Add camera Y coordinate
		add.w	(a3),d5		; Add camera X coordinate
		; Floor the coordinates to the nearest pair of tiles (the size of a block).
		; Also note that this wraps the value to the size of the plane:
		; The plane is 64*8 wide, so wrap at $100, and it's 32*8 tall, so wrap at $200
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		; Transform the adjusted coordinates into a VDP command
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#3,d0	; Highest bits of plane VRAM address
		swap	d0
		move.w	d4,d0
		rts
; End of function Calc_VRAM_Pos


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; not used

; This is just like Calc_VRAM_Pos, but seemingly for an earlier
; VRAM layout: the only difference is the high bits of the
; plane's VRAM address, which are 10 instead of 11.
; Both the foreground and background are at $C000 and $E000
; respectively, so this one starting at $8000 makes no sense.
; sub_6C3C:
Calc_VRAM_Pos_Unknown:
		add.w	4(a3),d4
		add.w	(a3),d5
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#2,d0
		swap	d0
		move.w	d4,d0
		rts
; End of function Calc_VRAM_Pos_Unknown

; ---------------------------------------------------------------------------
; Subroutine to load tiles as soon as the level appears
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesFromStart:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_screenposx).w,a3
		lea	(v_lvllayout).w,a4
		move.w	#$4000,d2
		bsr.s	DrawChunks
		lea	(v_bgscreenposx).w,a3
		lea	(v_lvllayout+$40).w,a4
		move.w	#$6000,d2
; End of function LoadTilesFromStart


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

DrawChunks:
		moveq	#-16,d4
		moveq	#((224+16+16)/16)-1,d6

.loop:
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	Calc_VRAM_Pos
		move.w	d1,d4
		moveq	#0,d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_2
		movem.l	(sp)+,d4-d6
		addi.w	#16,d4
		dbf	d6,.loop
		rts
; End of function DrawChunks
