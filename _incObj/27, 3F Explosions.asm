; ===========================================================================
; ---------------------------------------------------------------------------
; Object 27 - Gray explosion from a destroyed enemy or monitor
; ---------------------------------------------------------------------------

ExplosionItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	ExItem_Index(pc,d0.w),d1
		jmp	ExItem_Index(pc,d1.w)
; ===========================================================================
ExItem_Index:	dc.w ExItem_Animal-ExItem_Index
		dc.w ExItem_Main-ExItem_Index
		dc.w ExItem_Animate-ExItem_Index
; ===========================================================================

ExItem_Animal:	; Routine 0
		addq.b	#2,obRoutine(a0)
		bsr.w	FindFreeObj
		bne.s	ExItem_Main
		_move.b	#id_Animals,obID(a1) ; load animal object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	objoff_3E(a0),objoff_3E(a1)

ExItem_Main:	; Routine 2
		addq.b	#2,obRoutine(a0)
		move.l	#Map_ExplodeItem,obMap(a0)
		move.w	#ArtTile_Explosion,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#24/2,obActWid(a0)
		move.b	#7,obTimeFrame(a0) ; set frame duration to 7 frames
		move.b	#0,obFrame(a0)
		move.w	#sfx_BreakItem,d0
		jsr	(QueueSound2).l	; play breaking enemy sound

ExItem_Animate:	; Routine 4 (2 for Explosion)
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	.display
		move.b	#7,obTimeFrame(a0) ; set frame duration to 7 frames
		addq.b	#1,obFrame(a0)	; next frame
		cmpi.b	#5,obFrame(a0)	; is the final frame (05) displayed?
		beq.w	DeleteObject	; if yes, branch

.display:
		bra.w	DisplaySprite


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3F - Fiery explosion from a destroyed boss, bomb badnik, or cannonball
; ---------------------------------------------------------------------------

; ExplosionBomb: <--- old misnomer, this is used for more than just bombs
Explosion:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Expl_Index(pc,d0.w),d1
		jmp	Expl_Index(pc,d1.w)
; ===========================================================================
Expl_Index:	dc.w Expl_Main-Expl_Index
		dc.w ExItem_Animate-Expl_Index	; <-- this branches to a different object!
; ===========================================================================

Expl_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_ExplodeBomb,obMap(a0)
		move.w	#ArtTile_Explosion,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#24/2,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		move.w	#sfx_Bomb,d0
		jmp	(QueueSound2).l	; play exploding bomb sound
