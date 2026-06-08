; ---------------------------------------------------------------------------
; Object 4B - giant ring for entry to special stage
; ---------------------------------------------------------------------------

GiantRing:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GRing_Index(pc,d0.w),d1
		jmp	GRing_Index(pc,d1.w)
; ===========================================================================
GRing_Index:	dc.w GRing_Main-GRing_Index
		dc.w GRing_Animate-GRing_Index
		dc.w GRing_Collect-GRing_Index
		dc.w GRing_Delete-GRing_Index
; ===========================================================================

GRing_Main:	; Routine 0
		move.l	#Map_GRing,obMap(a0)
		move.w	#ArtTile_Giant_Ring|Tile_Pal2,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$40,obActWid(a0)
		tst.b	obRender(a0)
		bpl.s	GRing_Animate
		cmpi.b	#6,(v_emeralds).w ; do you have 6 emeralds?
		beq.w	GRing_Delete	; if yes, branch
		cmpi.w	#50,(v_rings).w	; do you have at least 50 rings?
		bhs.s	GRing_Okay	; if yes, branch
		rts
; ===========================================================================

GRing_Okay:
		addq.b	#2,obRoutine(a0)
		move.b	#2,obPriority(a0)
		move.b	#$52,obColType(a0)
		move.w	#$C40,(v_gfxbigring).w	; Signal that Art_BigRing should be loaded ($C40 is the size of Art_BigRing)

GRing_Animate:	; Routine 2
		move.b	(v_ani1_frame).w,obFrame(a0)
		out_of_range.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

GRing_Collect:	; Routine 4
		subq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		bsr.w	FindFreeObj
		bne.w	GRing_PlaySnd
		_move.b	#id_RingFlash,obID(a1) ; load giant ring flash object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	a0,objoff_3C(a1)
		move.w	(v_player+obX).w,d0
		cmp.w	obX(a0),d0	; has Sonic come from the left?
		blo.s	GRing_PlaySnd	; if yes, branch
		bset	#0,obRender(a1)	; reverse flash object

GRing_PlaySnd:
		move.w	#sfx_GiantRing,d0
		jsr	(QueueSound2).l	; play giant ring sound
		bra.s	GRing_Animate
; ===========================================================================

GRing_Delete:	; Routine 6
		bra.w	DeleteObject


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7C - flash effect when you collect the giant ring
; ---------------------------------------------------------------------------

RingFlash:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Flash_Index(pc,d0.w),d1
		jmp	Flash_Index(pc,d1.w)
; ===========================================================================
Flash_Index:	dc.w Flash_Main-Flash_Index
		dc.w Flash_ChkDel-Flash_Index
		dc.w Flash_Delete-Flash_Index
; ===========================================================================

Flash_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Flash,obMap(a0)
		move.w	#ArtTile_Giant_Ring_Flash|Tile_Pal2,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#0,obPriority(a0)
		move.b	#$20,obActWid(a0)
		move.b	#$FF,obFrame(a0)

Flash_ChkDel:	; Routine 2
		bsr.s	Flash_Collect
		out_of_range.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

Flash_Collect:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_9F76
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#8,obFrame(a0)	; has animation finished?
		bhs.s	Flash_End	; if yes, branch
		cmpi.b	#3,obFrame(a0)	; is 3rd frame displayed?
		bne.s	locret_9F76	; if not, branch
		movea.l	objoff_3C(a0),a1	; get parent object address
		move.b	#6,obRoutine(a1) ; delete parent object
		move.b	#id_Null,(v_player+obAnim).w ; make Sonic invisible
		move.b	#1,(f_bigring).w ; stop Sonic getting bonuses
		clr.b	(v_invinc).w	; remove invincibility
		clr.b	(v_shield).w	; remove shield

locret_9F76:
		rts
; ===========================================================================

Flash_End:
		addq.b	#2,obRoutine(a0)
		move.w	#0,(v_player).w ; remove Sonic object
		addq.l	#4,sp
		rts
; End of function Flash_Collect

; ===========================================================================

Flash_Delete:	; Routine 4
		bra.w	DeleteObject
