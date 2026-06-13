; ---------------------------------------------------------------------------
; Object 72 - teleporter (SBZ)
; ---------------------------------------------------------------------------

Teleport:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Tele_Index(pc,d0.w),d1
		jsr	Tele_Index(pc,d1.w)
		out_of_range.s	.delete
		rts

.delete:
		jmp	(DeleteObject).l
; ===========================================================================
Tele_Index:	dc.w Tele_Main-Tele_Index
		dc.w Tele_Action-Tele_Index
		dc.w Tele_Bump-Tele_Index
		dc.w Tele_Bend-Tele_Index
; ===========================================================================

Tele_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		andi.w	#$1E,d0
		lea	Tele_Data(pc),a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,objoff_3A(a0)
		move.l	a2,objoff_3C(a0)
		move.w	(a2)+,objoff_36(a0)
		move.w	(a2)+,objoff_38(a0)

; loc_166C8:
Tele_Action:	; Routine 2
		lea	(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		btst	#0,obStatus(a0)
		beq.s	loc_166E0
		addi.w	#$F,d0

loc_166E0:
		cmpi.w	#$10,d0
		bhs.s	locret_1675C
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		addi.w	#$20,d1
		cmpi.w	#$40,d1
		bhs.s	locret_1675C
	if FixBugs
		; Fix being able to activate teleporters while in debug mode
		tst.w	(v_debuguse).w		; is debug mode active?
		bne.s	locret_1675C		; if yes, branch
	endif
		tst.b	(f_playerctrl).w
		bne.s	locret_1675C
		cmpi.b	#7,obSubtype(a0)
		bne.s	loc_1670E
		cmpi.w	#50,(v_rings).w
		blo.s	locret_1675C

loc_1670E:
		addq.b	#2,obRoutine(a0)
		move.b	#$81,(f_playerctrl).w ; lock controls and disable object interaction
		move.b	#id_Roll,obAnim(a1) ; use Sonic's rolling animation
		move.w	#$800,obInertia(a1)
		move.w	#0,obVelX(a1)
		move.w	#0,obVelY(a1)
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)
		bset	#1,obStatus(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		clr.b	objoff_32(a0)
		move.w	#sfx_Roll,d0
		jsr	(QueueSound2).l	; play Sonic rolling sound

locret_1675C:
		rts
; ===========================================================================

; loc_1675E:
Tele_Bump:	; Routine 4
		lea	(v_player).w,a1
		move.b	objoff_32(a0),d0
		addq.b	#2,objoff_32(a0)
		jsr	(CalcSine).l
		asr.w	#5,d0
		move.w	obY(a0),d2
		sub.w	d0,d2
		move.w	d2,obY(a1)
		cmpi.b	#$80,objoff_32(a0)
		bne.s	locret_16796
		bsr.w	Tele_Move
		addq.b	#2,obRoutine(a0)
		move.w	#sfx_Teleport,d0
		jsr	(QueueSound2).l	; play teleport sound

locret_16796:
		rts
; ===========================================================================

; loc_16798:
Tele_Bend:	; Routine 6
		addq.l	#4,sp
		lea	(v_player).w,a1
		subq.b	#1,objoff_2E(a0)
		bpl.s	loc_167DA
		move.w	objoff_36(a0),obX(a1)
		move.w	objoff_38(a0),obY(a1)
		moveq	#0,d1
		move.b	objoff_3A(a0),d1
		addq.b	#4,d1
		cmp.b	objoff_3B(a0),d1
		blo.s	loc_167C2
		moveq	#0,d1
		bra.s	loc_16800
; ===========================================================================

loc_167C2:
		move.b	d1,objoff_3A(a0)
		movea.l	objoff_3C(a0),a2
		move.w	(a2,d1.w),objoff_36(a0)
		move.w	2(a2,d1.w),objoff_38(a0)
		bra.w	Tele_Move
; ===========================================================================

loc_167DA:
		move.l	obX(a1),d2
		move.l	obY(a1),d3
		move.w	obVelX(a1),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	obVelY(a1),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,obX(a1)
		move.l	d3,obY(a1)
		rts
; ===========================================================================

loc_16800:
		andi.w	#$7FF,obY(a1)
		clr.b	obRoutine(a0)
		clr.b	(f_playerctrl).w
		move.w	#0,obVelX(a1)
		move.w	#$200,obVelY(a1)
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to set Sonic's speed & direction in a teleport pipe
; ---------------------------------------------------------------------------

; sub_1681C:
Tele_Move:
		moveq	#0,d0
		move.w	#$1000,d2
		move.w	objoff_36(a0),d0
		sub.w	obX(a1),d0				; d0 = x distance between Sonic and next target (-ve if Sonic is to the right)
		bge.s	.sonic_is_left				; branch if +ve
		neg.w	d0
		neg.w	d2

	.sonic_is_left:
		moveq	#0,d1
		move.w	#$1000,d3
		move.w	objoff_38(a0),d1
		sub.w	obY(a1),d1				; d1 = y distance between Sonic and next target (-ve if Sonic is below)
		bge.s	.sonic_is_above				; branch if +ve
		neg.w	d1
		neg.w	d3

	.sonic_is_above:
		cmp.w	d0,d1					; is x distance > y distance?
		bcs.s	Tele_Move_X				; if yes, branch

		moveq	#0,d1
		move.w	objoff_38(a0),d1
		sub.w	obY(a1),d1				; d1 = y distance between Sonic and next target (-ve if Sonic is below)
		swap	d1					; move into high word
		divs.w	d3,d1					; divide by $1000 or -$1000
		moveq	#0,d0
		move.w	objoff_36(a0),d0
		sub.w	obX(a1),d0				; d0 = x distance between Sonic and next target (-ve if Sonic is to the right)
		beq.s	.x_match				; branch if 0
		swap	d0					; move into high word
		divs.w	d1,d0					; divide by d1

	.x_match:
		move.w	d0,obVelX(a1)
		move.w	d3,obVelY(a1)
		tst.w	d1
		bpl.s	.abs_time
		neg.w	d1

	.abs_time:
		move.w	d1,objoff_2E(a0)			; set travel time for current direction
		rts	
; ===========================================================================

Tele_Move_X:
		moveq	#0,d0
		move.w	objoff_36(a0),d0
		sub.w	obX(a1),d0				; d0 = x distance between Sonic and next target (-ve if Sonic is to the right)
		swap	d0
		divs.w	d2,d0
		moveq	#0,d1
		move.w	objoff_38(a0),d1
		sub.w	obY(a1),d1				; d1 = y distance between Sonic and next target (-ve if Sonic is below)
		beq.s	.y_match				; branch if 0
		swap	d1
		divs.w	d0,d1

	.y_match:
		move.w	d1,obVelY(a1)
		move.w	d2,obVelX(a1)
		tst.w	d0
		bpl.s	.abs_time
		neg.w	d0

	.abs_time:
		move.w	d0,objoff_2E(a0)			; set travel time for current direction
		rts
; End of function Tele_Move

; ===========================================================================
Tele_Data:	dc.w .type00-Tele_Data
		dc.w .type01-Tele_Data
		dc.w .type02-Tele_Data
		dc.w .type03-Tele_Data
		dc.w .type04-Tele_Data
		dc.w .type05-Tele_Data
		dc.w .type06-Tele_Data
		dc.w .type07-Tele_Data

.type00:	dc.w 4,	$794, $98C

.type01:	dc.w 4,	$94, $38C

.type02:	dc.w $1C, $794,	$2E8
		dc.w $7A4, $2C0, $7D0
		dc.w $2AC, $858, $2AC
		dc.w $884, $298, $894
		dc.w $270, $894, $190

.type03:	dc.w 4,	$894, $690

.type04:	dc.w $1C, $1194, $470
		dc.w $1184, $498, $1158
		dc.w $4AC, $FD0, $4AC
		dc.w $FA4, $4C0, $F94
		dc.w $4E8, $F94, $590

.type05:	dc.w 4,	$1294, $490

.type06:	dc.w $1C, $1594, $FFE8
		dc.w $1584, $FFC0, $1560
		dc.w $FFAC, $14D0, $FFAC
		dc.w $14A4, $FF98, $1494
		dc.w $FF70, $1494, $FD90

.type07:	dc.w 4,	$894, $90
