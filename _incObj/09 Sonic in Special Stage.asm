; ---------------------------------------------------------------------------
; Object 09 - Sonic (special stage)
; ---------------------------------------------------------------------------

SonicSpecial:
		tst.w	(v_debuguse).w	; is debug mode being used?
		beq.s	SonicSS_Normal	; if not, branch
		bsr.w	SS_FixCamera
		bra.w	DebugMode
; ===========================================================================

; Obj09_Normal:
SonicSS_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SonicSS_Index(pc,d0.w),d1
		jmp	SonicSS_Index(pc,d1.w)
; ===========================================================================
; Obj09_Index:
SonicSS_Index:	dc.w SonicSS_Main-SonicSS_Index
		dc.w SonicSS_ChkDebug-SonicSS_Index
		dc.w SonicSS_ExitStage-SonicSS_Index
		dc.w SonicSS_Exit2-SonicSS_Index
; ===========================================================================

; Obj09_Main:
SonicSS_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#sonic_roll_height,obHeight(a0)
		move.b	#sonic_roll_width,obWidth(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#ArtTile_Sonic,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#0,obPriority(a0)
		move.b	#id_Roll,obAnim(a0)
		bset	#2,obStatus(a0)
		bset	#1,obStatus(a0)

; Obj09_ChkDebug:
SonicSS_ChkDebug:	; Routine 2
		tst.w	(f_debugmode).w	; is debug mode cheat enabled?
		beq.s	SonicSS_NoDebug	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	SonicSS_NoDebug	; if not, branch
		move.w	#1,(v_debuguse).w ; change Sonic into a ring

; Obj09_NoDebug:
SonicSS_NoDebug:
		move.b	#0,objoff_30(a0)
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#2,d0
		move.w	SonicSS_Modes(pc,d0.w),d1
		jsr	SonicSS_Modes(pc,d1.w)
		jsr	(Sonic_LoadGfx).l
		jmp	(DisplaySprite).l
; ===========================================================================
; Obj09_Modes:
SonicSS_Modes:	dc.w SonicSS_OnWall-SonicSS_Modes
		dc.w SonicSS_InAir-SonicSS_Modes
; ===========================================================================

; Obj09_OnWall:
SonicSS_OnWall:
		bsr.w	SonicSS_Jump
		bsr.w	SonicSS_Move
		bsr.w	SonicSS_Fall
		bra.s	SonicSS_Display
; ===========================================================================

; Obj09_InAir:
SonicSS_InAir:
		bsr.w	nullsub_2
		bsr.w	SonicSS_Move
		bsr.w	SonicSS_Fall

; Obj09_Display:
SonicSS_Display:
		bsr.w	SonicSS_ChkItems
		bsr.w	SonicSS_ChkItems2
		jsr	(SpeedToPos).l
		bsr.w	SS_FixCamera
		move.w	(v_ssangle).w,d0
		add.w	(v_ssrotate).w,d0
		move.w	d0,(v_ssangle).w
		jsr	(Sonic_Animate).l
		rts
; ===========================================================================

; Obj09_Move:
SonicSS_Move:
		btst	#bitL,(v_jpadhold2).w ; is left being held?
		beq.s	SonicSS_ChkRight	; if not, branch
		bsr.w	SonicSS_MoveLeft

; Obj09_ChkRight:
SonicSS_ChkRight:
		btst	#bitR,(v_jpadhold2).w ; is right being held?
		beq.s	loc_1BA78	; if not, branch
		bsr.w	SonicSS_MoveRight

loc_1BA78:
		move.b	(v_jpadhold2).w,d0 ; get held buttons
		andi.b	#btnL+btnR,d0	; is left or right being held?
		bne.s	loc_1BAA8	; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	loc_1BAA8
		bmi.s	loc_1BA9A
		subi.w	#$C,d0
		bcc.s	loc_1BA94
		move.w	#0,d0

loc_1BA94:
		move.w	d0,obInertia(a0)
		bra.s	loc_1BAA8
; ===========================================================================

loc_1BA9A:
		addi.w	#$C,d0
		bcc.s	loc_1BAA4
		move.w	#0,d0

loc_1BAA4:
		move.w	d0,obInertia(a0)

loc_1BAA8:
		move.b	(v_ssangle).w,d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		neg.b	d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		add.l	d1,obX(a0)
		muls.w	obInertia(a0),d0
		add.l	d0,obY(a0)
		movem.l	d0-d1,-(sp)
		move.l	obY(a0),d2
		move.l	obX(a0),d3
		bsr.w	sub_1BCE8
		beq.s	loc_1BAF2
		movem.l	(sp)+,d0-d1
		sub.l	d1,obX(a0)
		sub.l	d0,obY(a0)
		move.w	#0,obInertia(a0)
		rts
; ===========================================================================

loc_1BAF2:
		movem.l	(sp)+,d0-d1
		rts
; End of function SonicSS_Move
; ===========================================================================

; Obj09_MoveLeft:
SonicSS_MoveLeft:
		bset	#0,obStatus(a0)
		move.w	obInertia(a0),d0
		beq.s	loc_1BB06
		bpl.s	loc_1BB1A

loc_1BB06:
		subi.w	#$C,d0
		cmpi.w	#-$800,d0
		bgt.s	loc_1BB14
		move.w	#-$800,d0

loc_1BB14:
		move.w	d0,obInertia(a0)
		rts
; ===========================================================================

loc_1BB1A:
		subi.w	#$40,d0
		bcc.s	loc_1BB22
		nop	

loc_1BB22:
		move.w	d0,obInertia(a0)
		rts
; End of function SonicSS_MoveLeft
; ===========================================================================

; Obj09_MoveRight:
SonicSS_MoveRight:
		bclr	#0,obStatus(a0)
		move.w	obInertia(a0),d0
		bmi.s	loc_1BB48
		addi.w	#$C,d0
		cmpi.w	#$800,d0
		blt.s	loc_1BB42
		move.w	#$800,d0

loc_1BB42:
		move.w	d0,obInertia(a0)
		bra.s	locret_1BB54
; ===========================================================================

loc_1BB48:
		addi.w	#$40,d0
		bcc.s	loc_1BB50
		nop	

loc_1BB50:
		move.w	d0,obInertia(a0)

locret_1BB54:
		rts
; End of function SonicSS_MoveRight
; ===========================================================================

; Obj09_Jump:
SonicSS_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.s	SonicSS_NoJump	; if not, branch
		move.b	(v_ssangle).w,d0
		andi.b	#$FC,d0
		neg.b	d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	#$680,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	#$680,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bset	#1,obStatus(a0)
		move.w	#sfx_Jump,d0
		jsr	(QueueSound2).l	; play jumping sound

; Obj09_NoJump:
SonicSS_NoJump:
		rts
; End of function SonicSS_Jump

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused subroutine to limit Sonic's upward vertical speed depending on
; how long the jump button was held after the initial jump. This likely got
; removed as it doesn't work (it doesn't account for the stage rotation).
; ---------------------------------------------------------------------------

nullsub_2:
		rts

		; dead code
		move.w	#-$400,d1		; set maximum jump speed
		cmp.w	obVelY(a0),d1		; is Sonic already below the cap?
		ble.s	.return			; if yes, branch
		move.b	(v_jpadhold2).w,d0	; get held buttons
		andi.b	#btnABC,d0		; is A, B, or C being held?
		bne.s	.return			; if yes, branch
		move.w	d1,obVelY(a0)		; cap vertical speed if not holding ABC

; locret_1BBB4:
.return:
		rts
; End of function nullsub_2

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to fix the camera on Sonic's position (special stage)
; ---------------------------------------------------------------------------

SS_FixCamera:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		move.w	(v_screenposx).w,d0
		subi.w	#$A0,d3
		bcs.s	loc_1BBCE
		sub.w	d3,d0
		sub.w	d0,(v_screenposx).w

loc_1BBCE:
		move.w	(v_screenposy).w,d0
		subi.w	#$70,d2
		bcs.s	locret_1BBDE
		sub.w	d2,d0
		sub.w	d0,(v_screenposy).w

locret_1BBDE:
		rts
; End of function SS_FixCamera

; ===========================================================================

; Obj09_ExitStage:
SonicSS_ExitStage:
		addi.w	#$40,(v_ssrotate).w
		cmpi.w	#$1800,(v_ssrotate).w
		bne.s	loc_1BBF4
		move.b	#id_Level,(v_gamemode).w

loc_1BBF4:
		cmpi.w	#$3000,(v_ssrotate).w
		blt.s	loc_1BC12
		move.w	#0,(v_ssrotate).w
		move.w	#$4000,(v_ssangle).w
		addq.b	#2,obRoutine(a0)
		move.w	#$3C,objoff_38(a0)

loc_1BC12:
		move.w	(v_ssangle).w,d0
		add.w	(v_ssrotate).w,d0
		move.w	d0,(v_ssangle).w
		jsr	(Sonic_Animate).l
		jsr	(Sonic_LoadGfx).l
		bsr.w	SS_FixCamera
		jmp	(DisplaySprite).l
; ===========================================================================

; Obj09_Exit2:
SonicSS_Exit2:
		subq.w	#1,objoff_38(a0)
		bne.s	loc_1BC40
		move.b	#id_Level,(v_gamemode).w

loc_1BC40:
		jsr	(Sonic_Animate).l
		jsr	(Sonic_LoadGfx).l
		bsr.w	SS_FixCamera
		jmp	(DisplaySprite).l
; ===========================================================================

; Obj09_Fall:
SonicSS_Fall:
		move.l	obY(a0),d2
		move.l	obX(a0),d3
		move.b	(v_ssangle).w,d0
		andi.b	#$FC,d0
		jsr	(CalcSine).l
		move.w	obVelX(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d0
		add.l	d4,d0
		move.w	obVelY(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d1
		add.l	d4,d1
		add.l	d0,d3
		bsr.w	sub_1BCE8
		beq.s	loc_1BCB0
		sub.l	d0,d3
		moveq	#0,d0
		move.w	d0,obVelX(a0)
		bclr	#1,obStatus(a0)
		add.l	d1,d2
		bsr.w	sub_1BCE8
		beq.s	loc_1BCC6
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,obVelY(a0)
		rts
; ===========================================================================

loc_1BCB0:
		add.l	d1,d2
		bsr.w	sub_1BCE8
		beq.s	loc_1BCD4
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,obVelY(a0)
		bclr	#1,obStatus(a0)

loc_1BCC6:
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,obVelX(a0)
		move.w	d1,obVelY(a0)
		rts
; ===========================================================================

loc_1BCD4:
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,obVelX(a0)
		move.w	d1,obVelY(a0)
		bset	#1,obStatus(a0)
		rts
; End of function SonicSS_Fall
; ===========================================================================

sub_1BCE8:
		lea	(v_ssbuffer1).l,a1
		moveq	#0,d4
		swap	d2
		move.w	d2,d4
		swap	d2
		addi.w	#$44,d4
		divu.w	#$18,d4
		mulu.w	#$80,d4
		adda.l	d4,a1
		moveq	#0,d4
		swap	d3
		move.w	d3,d4
		swap	d3
		addi.w	#$14,d4
		divu.w	#$18,d4
		adda.w	d4,a1
		moveq	#0,d5
		move.b	(a1)+,d4
		bsr.s	sub_1BD30
		move.b	(a1)+,d4
		bsr.s	sub_1BD30
		adda.w	#$7E,a1
		move.b	(a1)+,d4
		bsr.s	sub_1BD30
		move.b	(a1)+,d4
		bsr.s	sub_1BD30
		tst.b	d5
		rts
; End of function sub_1BCE8
; ===========================================================================

sub_1BD30:
		beq.s	locret_1BD44
		cmpi.b	#$28,d4
		beq.s	locret_1BD44
		cmpi.b	#$3A,d4
		blo.s	loc_1BD46
		cmpi.b	#$4B,d4
		bhs.s	loc_1BD46

locret_1BD44:
		rts
; ===========================================================================

loc_1BD46:
		move.b	d4,objoff_30(a0)
		move.l	a1,objoff_32(a0)
		moveq	#-1,d5
		rts
; End of function sub_1BD30
; ===========================================================================

; Obj09_ChkItems:
SonicSS_ChkItems:
		lea	(v_ssbuffer1).l,a1
		moveq	#0,d4
		move.w	obY(a0),d4
		addi.w	#$50,d4
		divu.w	#$18,d4
		mulu.w	#$80,d4
		adda.l	d4,a1
		moveq	#0,d4
		move.w	obX(a0),d4
		addi.w	#$20,d4
		divu.w	#$18,d4
		adda.w	d4,a1
		move.b	(a1),d4
		bne.s	SonicSS_ChkCont
		tst.b	objoff_3A(a0)
		bne.w	SonicSS_MakeGhostSolid
		moveq	#0,d4
		rts
; ===========================================================================

; Obj09_ChkCont:
SonicSS_ChkCont:
		cmpi.b	#$3A,d4		; is the item a ring?
		bne.s	SonicSS_Chk1Up
		bsr.w	SS_RemoveCollectedItem
		bne.s	SonicSS_GetCont
		move.b	#1,(a2)
		move.l	a1,4(a2)

; Obj09_GetCont:
SonicSS_GetCont:
		jsr	(CollectRing).l
		cmpi.w	#50,(v_rings).w	; check if you have 50 rings
		blo.s	SonicSS_NoCont
		bset	#0,(v_lifecount).w
		bne.s	SonicSS_NoCont
		addq.b	#1,(v_continues).w ; add 1 to number of continues
		move.w	#sfx_Continue,d0
		jsr	(QueueSound1).l	; play extra continue sound

; Obj09_NoCont:
SonicSS_NoCont:
		moveq	#0,d4
		rts
; ===========================================================================

; Obj09_Chk1Up:
SonicSS_Chk1Up:
		cmpi.b	#$28,d4		; is the item an extra life?
		bne.s	SonicSS_ChkEmer
		bsr.w	SS_RemoveCollectedItem
		bne.s	SonicSS_Get1Up
		move.b	#3,(a2)
		move.l	a1,4(a2)

; Obj09_Get1Up:
SonicSS_Get1Up:
		addq.b	#1,(v_lives).w	; add 1 to number of lives
		addq.b	#1,(f_lifecount).w ; update the lives counter
		move.w	#bgm_ExtraLife,d0
		jsr	(QueueSound1).l	; play extra life music
		moveq	#0,d4
		rts
; ===========================================================================

; Obj09_ChkEmer:
SonicSS_ChkEmer:
		cmpi.b	#$3B,d4		; is the item an emerald?
		blo.s	SonicSS_ChkGhost
		cmpi.b	#$40,d4
		bhi.s	SonicSS_ChkGhost
		bsr.w	SS_RemoveCollectedItem
		bne.s	SonicSS_GetEmer
		move.b	#5,(a2)
		move.l	a1,4(a2)

; Obj09_GetEmer:
SonicSS_GetEmer:
		cmpi.b	#6,(v_emeralds).w ; do you have all the emeralds?
		beq.s	SonicSS_NoEmer	; if yes, branch
		subi.b	#$3B,d4
		moveq	#0,d0
		move.b	(v_emeralds).w,d0
		lea	(v_emldlist).w,a2
		move.b	d4,(a2,d0.w)
		addq.b	#1,(v_emeralds).w ; add 1 to number of emeralds

; Obj09_NoEmer:
SonicSS_NoEmer:
		move.w	#bgm_Emerald,d0
		jsr	(QueueSound2).l ; play emerald music
		moveq	#0,d4
		rts
; ===========================================================================

; Obj09_ChkGhost:
SonicSS_ChkGhost:
		cmpi.b	#$41,d4		; is the item a ghost block?
		bne.s	SonicSS_ChkGhostTag
		move.b	#1,objoff_3A(a0)	; mark the ghost block as "passed"

; Obj09_ChkGhostTag:
SonicSS_ChkGhostTag:
		cmpi.b	#$4A,d4		; is the item a switch for ghost blocks?
		bne.s	SonicSS_NoGhost
		cmpi.b	#1,objoff_3A(a0)	; have the ghost blocks been passed?
		bne.s	SonicSS_NoGhost	; if not, branch
		move.b	#2,objoff_3A(a0)	; mark the ghost blocks as "solid"

; Obj09_NoGhost:
SonicSS_NoGhost:
		moveq	#-1,d4
		rts
; ===========================================================================

; Obj09_MakeGhostSolid:
SonicSS_MakeGhostSolid:
		cmpi.b	#2,objoff_3A(a0)	; is the ghost marked as "solid"?
		bne.s	SonicSS_GhostNotSolid ; if not, branch
		lea	(v_ssblockbuffer).l,a1
		moveq	#(v_ssblockbuffer_end-v_ssblockbuffer)/$80-1,d1

; Obj09_GhostLoop2:
SonicSS_GhostLoop2:
		moveq	#$40-1,d2

; Obj09_GhostLoop:
SonicSS_GhostLoop:
		cmpi.b	#$41,(a1)	; is the item a ghost block?
		bne.s	SonicSS_NoReplace	; if not, branch
		move.b	#$2C,(a1)	; replace ghost block with a solid block

; Obj09_NoReplace:
SonicSS_NoReplace:
		addq.w	#1,a1
		dbf	d2,SonicSS_GhostLoop
		lea	$40(a1),a1
		dbf	d1,SonicSS_GhostLoop2

; Obj09_GhostNotSolid:
SonicSS_GhostNotSolid:
		clr.b	objoff_3A(a0)
		moveq	#0,d4
		rts
; End of function SonicSS_ChkItems
; ===========================================================================

; Obj09_ChkItems2:
SonicSS_ChkItems2:
		move.b	objoff_30(a0),d0
		bne.s	SonicSS_ChkBumper
		subq.b	#1,objoff_36(a0)
		bpl.s	loc_1BEA0
		move.b	#0,objoff_36(a0)

loc_1BEA0:
		subq.b	#1,objoff_37(a0)
		bpl.s	locret_1BEAC
		move.b	#0,objoff_37(a0)

locret_1BEAC:
		rts
; ===========================================================================

; Obj09_ChkBumper:
SonicSS_ChkBumper:
		cmpi.b	#$25,d0		; is the item a bumper?
		bne.s	SonicSS_GOAL
		move.l	objoff_32(a0),d1
		subi.l	#$FF0001,d1
		move.w	d1,d2
		andi.w	#$7F,d1
		mulu.w	#$18,d1
		subi.w	#$14,d1
		lsr.w	#7,d2
		andi.w	#$7F,d2
		mulu.w	#$18,d2
		subi.w	#$44,d2
		sub.w	obX(a0),d1
		sub.w	obY(a0),d2
		jsr	(CalcAngle).l
		jsr	(CalcSine).l
		muls.w	#-$700,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	#-$700,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bset	#1,obStatus(a0)
		bsr.w	SS_RemoveCollectedItem
		bne.s	SonicSS_BumpSnd
		move.b	#2,(a2)
		move.l	objoff_32(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)

; Obj09_BumpSnd:
SonicSS_BumpSnd:
		move.w	#sfx_Bumper,d0
		jmp	(QueueSound2).l	; play bumper sound
; ===========================================================================

; Obj09_GOAL:
SonicSS_GOAL:
		cmpi.b	#$27,d0		; is the item a "GOAL"?
		bne.s	SonicSS_UPblock
		addq.b	#2,obRoutine(a0) ; run routine "SonicSS_ExitStage"
		move.w	#sfx_SSGoal,d0
		jsr	(QueueSound2).l	; play "GOAL" sound
		rts
; ===========================================================================

; Obj09_UPblock:
SonicSS_UPblock:
		cmpi.b	#$29,d0		; is the item an "UP" block?
		bne.s	SonicSS_DOWNblock
		tst.b	objoff_36(a0)
		bne.w	SonicSS_NoGlass
		move.b	#$1E,objoff_36(a0)
		btst	#6,(v_ssrotate+1).w
		beq.s	SonicSS_UPsnd
		asl.w	(v_ssrotate).w	; increase stage rotation speed
		movea.l	objoff_32(a0),a1
		subq.l	#1,a1
		move.b	#$2A,(a1)	; change item to a "DOWN" block

; Obj09_UPsnd:
SonicSS_UPsnd:
		move.w	#sfx_SSItem,d0
		jmp	(QueueSound2).l	; play up/down sound
; ===========================================================================

; Obj09_DOWNblock:
SonicSS_DOWNblock:
		cmpi.b	#$2A,d0		; is the item a "DOWN" block?
		bne.s	SonicSS_Rblock
		tst.b	objoff_36(a0)
		bne.w	SonicSS_NoGlass
		move.b	#$1E,objoff_36(a0)
		btst	#6,(v_ssrotate+1).w
		bne.s	SonicSS_DOWNsnd
		asr.w	(v_ssrotate).w	; reduce stage rotation speed
		movea.l	objoff_32(a0),a1
		subq.l	#1,a1
		move.b	#$29,(a1)	; change item to an "UP" block

; Obj09_DOWNsnd:
SonicSS_DOWNsnd:
		move.w	#sfx_SSItem,d0
		jmp	(QueueSound2).l	; play up/down sound
; ===========================================================================

; Obj09_Rblock:
SonicSS_Rblock:
		cmpi.b	#$2B,d0		; is the item an "R" block?
		bne.s	SonicSS_ChkGlass
		tst.b	objoff_37(a0)
		bne.w	SonicSS_NoGlass
		move.b	#$1E,objoff_37(a0)
		bsr.w	SS_RemoveCollectedItem
		bne.s	SonicSS_RevStage
		move.b	#4,(a2)
		move.l	objoff_32(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)

; Obj09_RevStage:
SonicSS_RevStage:
		neg.w	(v_ssrotate).w	; reverse stage rotation
		move.w	#sfx_SSItem,d0
		jmp	(QueueSound2).l	; play sound
; ===========================================================================

; Obj09_ChkGlass:
SonicSS_ChkGlass:
		cmpi.b	#$2D,d0		; is the item a glass block?
		beq.s	SonicSS_Glass	; if yes, branch
		cmpi.b	#$2E,d0
		beq.s	SonicSS_Glass
		cmpi.b	#$2F,d0
		beq.s	SonicSS_Glass
		cmpi.b	#$30,d0
		bne.s	SonicSS_NoGlass	; if not, branch

; Obj09_Glass:
SonicSS_Glass:
		bsr.w	SS_RemoveCollectedItem
		bne.s	SonicSS_GlassSnd
		move.b	#6,(a2)
		movea.l	objoff_32(a0),a1
		subq.l	#1,a1
		move.l	a1,4(a2)
		move.b	(a1),d0
		addq.b	#1,d0		; change glass type when touched
		cmpi.b	#$30,d0
		bls.s	SonicSS_GlassUpdate ; if glass is still there, branch
		clr.b	d0		; remove the glass block when it's destroyed

; Obj09_GlassUpdate:
SonicSS_GlassUpdate:
		move.b	d0,4(a2)	; update the stage layout

; Obj09_GlassSnd:
SonicSS_GlassSnd:
		move.w	#sfx_SSGlass,d0
		jmp	(QueueSound2).l	; play glass block sound
; ===========================================================================

; Obj09_NoGlass:
SonicSS_NoGlass:
		rts
; End of function SonicSS_ChkItems2
