; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to show the special stage layout
; ---------------------------------------------------------------------------

SS_ShowLayout:
		bsr.w	SS_AniWallsRings
		bsr.w	SS_AniItems
		move.w	d5,-(sp)
		lea	(v_ssbuffer3).w,a1
		move.b	(v_ssangle).w,d0
		andi.b	#$FC,d0
		jsr	(CalcSine).l
		move.w	d0,d4
		move.w	d1,d5
		muls.w	#$18,d4
		muls.w	#$18,d5
		moveq	#0,d2
		move.w	(v_screenposx).w,d2
		divu.w	#$18,d2
		swap	d2
		neg.w	d2
		addi.w	#-$B4,d2
		moveq	#0,d3
		move.w	(v_screenposy).w,d3
		divu.w	#$18,d3
		swap	d3
		neg.w	d3
		addi.w	#-$B4,d3
		move.w	#$10-1,d7

loc_1B19E:
		movem.w	d0-d2,-(sp)
		movem.w	d0-d1,-(sp)
		neg.w	d0
		muls.w	d2,d1
		muls.w	d3,d0
		move.l	d0,d6
		add.l	d1,d6
		movem.w	(sp)+,d0-d1
		muls.w	d2,d0
		muls.w	d3,d1
		add.l	d0,d1
		move.l	d6,d2
		move.w	#$F,d6

loc_1B1C0:
		move.l	d2,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		move.l	d1,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		add.l	d5,d2
		add.l	d4,d1
		dbf	d6,loc_1B1C0

		movem.w	(sp)+,d0-d2
		addi.w	#$18,d3
		dbf	d7,loc_1B19E

		move.w	(sp)+,d5
		lea	(v_ssbuffer1).l,a0
		moveq	#0,d0
		move.w	(v_screenposy).w,d0
		divu.w	#$18,d0
		mulu.w	#ss_layout_rowlength,d0
		adda.l	d0,a0
		moveq	#0,d0
		move.w	(v_screenposx).w,d0
		divu.w	#$18,d0
		adda.w	d0,a0
		lea	(v_ssbuffer3).w,a4
		move.w	#$10-1,d7

loc_1B20C:
		move.w	#$F,d6

loc_1B210:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	loc_1B268
		cmpi.b	#$4E,d0
		bhi.s	loc_1B268
		move.w	(a4),d3
		addi.w	#$120,d3
		cmpi.w	#$70,d3
		blo.s	loc_1B268
		cmpi.w	#$1D0,d3
		bhs.s	loc_1B268
		move.w	2(a4),d2
		addi.w	#$F0,d2
		cmpi.w	#$70,d2
		blo.s	loc_1B268
		cmpi.w	#$170,d2
		bhs.s	loc_1B268
		lea	(v_ssblocktypes).l,a5
		lsl.w	#3,d0
		lea	(a5,d0.w),a5
		movea.l	(a5)+,a1
		move.w	(a5)+,d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		movea.w	(a5)+,a3
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_1B268
		jsr	(BuildSpr_Normal).l

loc_1B268:
		addq.w	#4,a4
		dbf	d6,loc_1B210

		lea	$70(a0),a0
		dbf	d7,loc_1B20C

		move.b	d5,(v_spritecount).w
		cmpi.b	#$50,d5
		beq.s	loc_1B288
		move.l	#0,(a2)
		rts
; ===========================================================================

loc_1B288:
		move.b	#0,-5(a2)
		rts
; End of function SS_ShowLayout

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to animate walls and rings in the special stage
; ---------------------------------------------------------------------------

SS_AniWallsRings:
		lea	(v_ssblocktypes+$C).l,a1
		moveq	#0,d0
		move.b	(v_ssangle).w,d0
		lsr.b	#2,d0
		andi.w	#$F,d0
		moveq	#$24-1,d1

loc_1B2A4:
		move.w	d0,(a1)
		addq.w	#8,a1
		dbf	d1,loc_1B2A4

		lea	(v_ssblocktypes+5).l,a1
		subq.b	#1,(v_ani1_time).w
		bpl.s	loc_1B2C8
		move.b	#7,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#3,(v_ani1_frame).w

loc_1B2C8:
		move.b	(v_ani1_frame).w,$1D0(a1)
		subq.b	#1,(v_ani2_time).w
		bpl.s	loc_1B2E4
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		andi.b	#1,(v_ani2_frame).w

loc_1B2E4:
		move.b	(v_ani2_frame).w,d0
		move.b	d0,$138(a1)
		move.b	d0,$160(a1)
		move.b	d0,$148(a1)
		move.b	d0,$150(a1)
		move.b	d0,$1D8(a1)
		move.b	d0,$1E0(a1)
		move.b	d0,$1E8(a1)
		move.b	d0,$1F0(a1)
		move.b	d0,$1F8(a1)
		move.b	d0,$200(a1)
		subq.b	#1,(v_ani3_time).w
		bpl.s	loc_1B326
		move.b	#4,(v_ani3_time).w
		addq.b	#1,(v_ani3_frame).w
		andi.b	#3,(v_ani3_frame).w

loc_1B326:
		move.b	(v_ani3_frame).w,d0
		move.b	d0,$168(a1)
		move.b	d0,$170(a1)
		move.b	d0,$178(a1)
		move.b	d0,$180(a1)
		subq.b	#1,(v_ani0_time).w
		bpl.s	loc_1B350
		move.b	#7,(v_ani0_time).w
		subq.b	#1,(v_ani0_frame).w
		andi.b	#7,(v_ani0_frame).w

loc_1B350:
		lea	(v_ssblocktypes+$16).l,a1
		lea	(SS_WaRiVramSet).l,a0
		moveq	#0,d0
		move.b	(v_ani0_frame).w,d0
		add.w	d0,d0
		lea	(a0,d0.w),a0
	
	rept 4
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
	endr
		rts
; End of function SS_AniWallsRings

; ===========================================================================

SS_WaRiVramSet:	dc.w ArtTile_SS_Wall,           ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall,           ArtTile_SS_Wall
		dc.w ArtTile_SS_Wall,           ArtTile_SS_Wall,           ArtTile_SS_Wall,           ArtTile_SS_Wall|Tile_Pal4
		dc.w ArtTile_SS_Wall,           ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall,           ArtTile_SS_Wall
		dc.w ArtTile_SS_Wall,           ArtTile_SS_Wall,           ArtTile_SS_Wall,           ArtTile_SS_Wall|Tile_Pal4
		dc.w ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall,           ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall|Tile_Pal2
		dc.w ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall
		dc.w ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall,           ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall|Tile_Pal2
		dc.w ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall
		dc.w ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal3
		dc.w ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal2
		dc.w ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal2, ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal3
		dc.w ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal2
		dc.w ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall|Tile_Pal4
		dc.w ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall|Tile_Pal3
		dc.w ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall|Tile_Pal3, ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall|Tile_Pal4
		dc.w ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall|Tile_Pal4, ArtTile_SS_Wall|Tile_Pal3

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	find a free slot in the Special Stage sprite update list,
; used to animate blocks collected/touched by Sonic.
; ---------------------------------------------------------------------------

; SS_RemoveCollectedItem: <-- old misnomer
SS_FindFreeAnimationSlot:
		lea	(v_ssitembuffer).l,a2			; address of sprite update list
		move.w	#(v_ssitembuffer_end-v_ssitembuffer)/8-1,d0 ; up to $20 slots

	; loc_1B4C4:
	.loop:
		tst.b	(a2)					; is slot free?
		beq.s	.return					; if yes, exit with it
		addq.w	#8,a2					; go to next slot
		dbf	d0,.loop				; try again

	; locret_1B4CE:
	.return:
		rts						; return with slot in a2
; End of function SS_FindFreeAnimationSlot

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to animate special stage items when you touch them.
; This system uses a buffer of animation events that are added through the
; above SS_FindFreeAnimationSlot subroutine.
; 
; Each slot is 8 bytes in size, broken down like so:
;	0   - animation ID (1-based; zero implies empty slot)
;	1   - (unused)
;	2   - frame delay between animation advancements
;	3   - current index ID in animation script
;	4-7 - RAM location of target block in stage layout
; ---------------------------------------------------------------------------
ss_ani_id:	equ 0
ss_ani_delay:	equ 2
ss_ani_frame:	equ 3
ss_ani_block:	equ 4
; ---------------------------------------------------------------------------

SS_AniItems:
		lea	(v_ssitembuffer).l,a0			; load start address of animation event buffer
		move.w	#(v_ssitembuffer_end-v_ssitembuffer)/8-1,d7 ; set to iterate through all slots

	; loc_1B4DA:
	.loop:
		moveq	#0,d0					; clear d0
		_move.b	ss_ani_id(a0),d0			; get potential animation event
		beq.s	.nextslot				; if slot has none, branch
		lsl.w	#2,d0					; multiply ID by 4 for long-based indexing
		movea.l	SS_AniIndex-4(pc,d0.w),a1		; get animation entry in jump table (-4 because these IDs are 1-based)
		jsr	(a1)					; execute animation and return

	; loc_1B4E8:
	.nextslot:
		addq.w	#8,a0					; go to next animation event slot
		dbf	d7,.loop				; loop until all event slots were checked
		rts						; return
; End of function SS_AniItems

; ===========================================================================
SS_AniIndex:	dc.l SS_AniRingSparks				; animation ID 1
		dc.l SS_AniBumper				; animation ID 2
		dc.l SS_Ani1Up					; animation ID 3
		dc.l SS_AniReverse				; animation ID 4
		dc.l SS_AniEmeraldSparks			; animation ID 5
		dc.l SS_AniGlassBlock				; animation ID 6
; ===========================================================================

SS_AniRingSparks:
		subq.b	#1,ss_ani_delay(a0)			; decrement delay until next animation advancement
		bpl.s	.return					; if time remains, branch
		move.b	#5,ss_ani_delay(a0)			; reset delay

		moveq	#0,d0					; clear d0
		move.b	ss_ani_frame(a0),d0			; get current frame index in animation script
		addq.b	#1,ss_ani_frame(a0)			; advance to next frame index
		movea.l	ss_ani_block(a0),a1			; get location of block in RAM
		move.b	SS_AniRingData(pc,d0.w),d0		; retrieve new block ID from animation script
		move.b	d0,(a1)					; update block in layout
		bne.s	.return					; if animation isn't finished, branch

		clr.l	(a0)					; clear animation event slot
		clr.l	ss_ani_block(a0)			; ''

	.return:
		rts						; return
; ===========================================================================
SS_AniRingData:	dc.b id_SS_Ring_Ani1, id_SS_Ring_Ani2, id_SS_Ring_Ani3, id_SS_Ring_Ani4, 0
		even
; ===========================================================================

SS_AniBumper:
		subq.b	#1,ss_ani_delay(a0)			; decrement delay until next animation advancement
		bpl.s	.return					; if time remains, branch
		move.b	#7,ss_ani_delay(a0)			; reset delay

		moveq	#0,d0					; clear d0
		move.b	ss_ani_frame(a0),d0			; get current frame index in animation script
		addq.b	#1,ss_ani_frame(a0)			; advance to next frame index
		movea.l	ss_ani_block(a0),a1			; get location of block in RAM
		move.b	SS_AniBumpData(pc,d0.w),d0		; retrieve new block ID from animation script
		bne.s	.animating				; if animation isn't finished, branch

		clr.l	(a0)					; clear animation event slot
		clr.l	ss_ani_block(a0)			; ''

		move.b	#id_SS_Bumper,(a1)			; reset bumper block to default idle one
		rts						; return
; ---------------------------------------------------------------------------

	.animating:
		move.b	d0,(a1)					; update block in layout

	.return:
		rts						; return
; ===========================================================================
SS_AniBumpData:	dc.b id_SS_Bumper_Ani1, id_SS_Bumper_Ani2, id_SS_Bumper_Ani1, id_SS_Bumper_Ani2, 0
		even
; ===========================================================================

SS_Ani1Up:
		subq.b	#1,ss_ani_delay(a0)			; decrement delay until next animation advancement
		bpl.s	.return					; if time remains, branch
		move.b	#5,ss_ani_delay(a0)			; reset delay

		moveq	#0,d0					; clear d0
		move.b	ss_ani_frame(a0),d0			; get current frame index in animation script
		addq.b	#1,ss_ani_frame(a0)			; advance to next frame index
		movea.l	ss_ani_block(a0),a1			; get location of block in RAM
		move.b	SS_Ani1UpData(pc,d0.w),d0		; retrieve new block ID from animation script
		move.b	d0,(a1)					; update block in layout
		bne.s	.return					; if animation isn't finished, branch

		clr.l	(a0)					; clear animation event slot
		clr.l	ss_ani_block(a0)			; ''

	.return:
		rts						; return
; ===========================================================================
SS_Ani1UpData:	dc.b id_SS_Emerald_Ani1, id_SS_Emerald_Ani2, id_SS_Emerald_Ani3, id_SS_Emerald_Ani4, 0
		even
; ===========================================================================

SS_AniReverse:
		subq.b	#1,ss_ani_delay(a0)			; decrement delay until next animation advancement
		bpl.s	.return					; if time remains, branch
		move.b	#7,ss_ani_delay(a0)			; reset delay

		moveq	#0,d0					; clear d0
		move.b	ss_ani_frame(a0),d0			; get current frame index in animation script
		addq.b	#1,ss_ani_frame(a0)			; advance to next frame index
		movea.l	ss_ani_block(a0),a1			; get location of block in RAM
		move.b	SS_AniRevData(pc,d0.w),d0		; retrieve new block ID from animation script
		bne.s	.animating				; if animation isn't finished, branch

		clr.l	(a0)					; clear animation event slot
		clr.l	ss_ani_block(a0)			; ''

		move.b	#id_SS_R,(a1)				; reset R block to default idle one
		rts
; ---------------------------------------------------------------------------

	.animating:
		move.b	d0,(a1)					; update block in layout

	.return:
		rts						; return
; ===========================================================================
SS_AniRevData:	dc.b id_SS_R, id_SS_R_Ani, id_SS_R, id_SS_R_Ani, 0
		even
; ===========================================================================

SS_AniEmeraldSparks:
		subq.b	#1,ss_ani_delay(a0)			; decrement delay until next animation advancement
		bpl.s	.return					; if time remains, branch
		move.b	#5,ss_ani_delay(a0)			; reset delay

		moveq	#0,d0					; clear d0
		move.b	ss_ani_frame(a0),d0			; get current frame index in animation script
		addq.b	#1,ss_ani_frame(a0)			; advance to next frame index
		movea.l	ss_ani_block(a0),a1			; get location of block in RAM
		move.b	SS_AniEmerData(pc,d0.w),d0		; retrieve new block ID from animation script
		move.b	d0,(a1)					; update block in layout
		bne.s	.return					; if animation isn't finished, branch

		clr.l	(a0)					; clear animation event slot
		clr.l	ss_ani_block(a0)			; ''

		move.b	#4,(v_player+obRoutine).w		; set object 09 to SonicSS_ExitStage (this triggers the actual exit)
		move.w	#sfx_SSGoal,d0				; set special stage GOAL sound
		jsr	(QueueSound2).l				; play it

	.return:
		rts						; return
; ===========================================================================
SS_AniEmerData:	dc.b id_SS_Emerald_Ani1, id_SS_Emerald_Ani2, id_SS_Emerald_Ani3, id_SS_Emerald_Ani4, 0
		even
; ===========================================================================

SS_AniGlassBlock:
		subq.b	#1,ss_ani_delay(a0)			; decrement delay until next animation advancement
		bpl.s	.return					; if time remains, branch
		move.b	#1,ss_ani_delay(a0)			; reset delay

		moveq	#0,d0					; clear d0
		move.b	ss_ani_frame(a0),d0			; get current frame index in animation script
		addq.b	#1,ss_ani_frame(a0)			; advance to next frame index
		movea.l	ss_ani_block(a0),a1			; get location of block in RAM
		move.b	SS_AniGlassData(pc,d0.w),d0		; retrieve new block ID from animation script
		move.b	d0,(a1)					; update block in layout
		bne.s	.return					; if animation isn't finished, branch

		move.b	ss_ani_block(a0),(a1)			; update glass with weaker version (see SonicSS_GlassUpdate)

		clr.l	(a0)					; clear animation event slot
		clr.l	ss_ani_block(a0)			; ''

	.return:
		rts						; return
; ===========================================================================
SS_AniGlassData:dc.b id_SS_Glass_Ani1, id_SS_Glass_Ani2, id_SS_Glass_Ani3, id_SS_Glass_Ani4
		dc.b id_SS_Glass_Ani1, id_SS_Glass_Ani2, id_SS_Glass_Ani3, id_SS_Glass_Ani4, 0
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Special stage layout pointers
; ---------------------------------------------------------------------------
SS_LayoutIndex:
		dc.l SS_1
		dc.l SS_2
		dc.l SS_3
		dc.l SS_4
		dc.l SS_5
		dc.l SS_6
		even

; ---------------------------------------------------------------------------
; Special stage start locations
; (Previously separated into "_inc/Start Location Array - Special Stages.asm")
; ---------------------------------------------------------------------------

SS_StartLoc:
		binclude	"startpos/Special Stages/ss1.bin"
		binclude	"startpos/Special Stages/ss2.bin"
		binclude	"startpos/Special Stages/ss3.bin"
		binclude	"startpos/Special Stages/ss4.bin"
		binclude	"startpos/Special Stages/ss5.bin"
		binclude	"startpos/Special Stages/ss6.bin"
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load special stage layout
; ---------------------------------------------------------------------------

SS_Load:
		moveq	#0,d0
		move.b	(v_lastspecial).w,d0 ; load number of last special stage entered
		addq.b	#1,(v_lastspecial).w
		cmpi.b	#6,(v_lastspecial).w
		blo.s	SS_ChkEmldNum
		move.b	#0,(v_lastspecial).w ; reset if higher than 6

SS_ChkEmldNum:
		cmpi.b	#6,(v_emeralds).w ; do you have all emeralds?
		beq.s	SS_LoadData	; if yes, branch
		moveq	#0,d1
		move.b	(v_emeralds).w,d1
		subq.b	#1,d1
		blo.s	SS_LoadData
		lea	(v_emldlist).w,a3 ; check which emeralds you have

SS_ChkEmldLoop:	
		cmp.b	(a3,d1.w),d0
		bne.s	SS_ChkEmldRepeat
		bra.s	SS_Load
; ===========================================================================

SS_ChkEmldRepeat:
		dbf	d1,SS_ChkEmldLoop

SS_LoadData:
		; Load player position data
		lsl.w	#2,d0
		lea	SS_StartLoc(pc,d0.w),a1
		move.w	(a1)+,(v_player+obX).w
		move.w	(a1)+,(v_player+obY).w

		; Load layout data
		movea.l	SS_LayoutIndex(pc,d0.w),a0
		lea	(v_ssbuffer2).l,a1
		move.w	#ArtTile_SS_Background_Clouds,d0
		jsr	(EniDec).l

		; Clear everything from v_ssbuffer1 to v_ssbuffer2
		lea	(v_ssbuffer1).l,a1
		move.w	#(v_ssbuffer2-v_ssbuffer1)/4-1,d0

SS_ClrRAM3:
		clr.l	(a1)+
		dbf	d0,SS_ClrRAM3

		; Copy $1000 of data from v_ssbuffer2 to v_ssblockbuffer,
		; inserting $40 bytes of padding for every $40 bytes copied.
		lea	(v_ssblockbuffer).l,a1
		lea	(v_ssbuffer2).l,a0
		moveq	#(v_ssblockbuffer_end-v_ssblockbuffer)/ss_layout_rowlength-1,d1

loc_1B6F6:
		moveq	#(ss_layout_rowlength/2)-1,d2

loc_1B6F8:
		move.b	(a0)+,(a1)+
		dbf	d2,loc_1B6F8

		lea	ss_layout_rowlength/2(a1),a1
		dbf	d1,loc_1B6F6

		lea	(v_ssblocktypes+8).l,a1
		lea	(SS_MapIndex).l,a0
		moveq	#(SS_MapIndex_End-SS_MapIndex)/6-1,d1

loc_1B714:
		move.l	(a0)+,(a1)+
		move.w	#0,(a1)+
		move.b	-4(a0),-1(a1)
		move.w	(a0)+,(a1)+
		dbf	d1,loc_1B714

		lea	(v_ssitembuffer).l,a1
		move.w	#(v_ssitembuffer_end-v_ssitembuffer)/4-1,d1

loc_1B730:

		clr.l	(a1)+
		dbf	d1,loc_1B730

		rts
; End of function SS_Load