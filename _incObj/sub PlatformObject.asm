; ---------------------------------------------------------------------------
; Platform subroutine
; ---------------------------------------------------------------------------

PlatformObject:
		lea	(v_player).w,a1
		tst.w	obVelY(a1)	; is Sonic moving up/jumping?
		bmi.w	Plat_Exit	; if yes, branch

		; perform x-axis range check
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	Plat_Exit

Plat_NoXCheck:
		move.w	obY(a0),d0
		subq.w	#8,d0

Platform3:
		; perform y-axis range check
		move.w	obY(a1),d2
		move.b	obHeight(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	Plat_Exit
		cmpi.w	#-$10,d0
		blo.w	Plat_Exit

		tst.b	(f_playerctrl).w
		bmi.w	Plat_Exit
		cmpi.b	#6,obRoutine(a1)
		bhs.w	Plat_Exit
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,obY(a1)
		addq.b	#2,obRoutine(a0)

; loc_74AE:
Plat_NoCheck:
		btst	#3,obStatus(a1)
		beq.s	loc_74DC
		moveq	#0,d0
		move.b	standonobject(a1),d0
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace&$FFFFFF,d0
		movea.l	d0,a2
		bclr	#3,obStatus(a2)
		clr.b	ob2ndRout(a2)
		cmpi.b	#4,obRoutine(a2)
		bne.s	loc_74DC
		subq.b	#2,obRoutine(a2)

loc_74DC:
		move.w	a0,d0
		subi.w	#v_objspace&$FFFF,d0
		lsr.w	#object_size_bits,d0
		andi.w	#$7F,d0
		move.b	d0,standonobject(a1)
		move.b	#0,obAngle(a1)
		move.w	#0,obVelY(a1)
		move.w	obVelX(a1),obInertia(a1)
		btst	#1,obStatus(a1)
		beq.s	loc_7512
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	(Sonic_ResetOnFloor).l
		movea.l	(sp)+,a0

loc_7512:
		bset	#3,obStatus(a1)
		bset	#3,obStatus(a0)

Plat_Exit:
		rts
; End of function PlatformObject

; ===========================================================================
; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and SLZ seesaws)
; ---------------------------------------------------------------------------

SlopeObject:
		lea	(v_player).w,a1
		tst.w	obVelY(a1)
		bmi.w	Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	Plat_Exit
		btst	#0,obRender(a0)
		beq.s	loc_754A
		not.w	d0
		add.w	d1,d0

loc_754A:
		lsr.w	#1,d0
		moveq	#0,d3
		move.b	(a2,d0.w),d3
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function SlopeObject
; ===========================================================================

Swing_Solid:
		lea	(v_player).w,a1
		tst.w	obVelY(a1)
		bmi.w	Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	Plat_Exit
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function Swing_Solid
