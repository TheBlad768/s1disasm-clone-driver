; ===========================================================================
; ---------------------------------------------------------------------------
; Object 22 - Buzz Bomber enemy (GHZ, MZ, SYZ)
; ---------------------------------------------------------------------------

BuzzBomber:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Buzz_Index(pc,d0.w),d1
		jmp	Buzz_Index(pc,d1.w)
; ===========================================================================
Buzz_Index:	dc.w Buzz_Main-Buzz_Index
		dc.w Buzz_Action-Buzz_Index
		dc.w Buzz_Delete-Buzz_Index

buzz_timedelay = objoff_32
buzz_buzzstatus = objoff_34
buzz_parent = objoff_3C
; ===========================================================================

Buzz_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Buzz,obMap(a0)
		move.w	#ArtTile_Buzz_Bomber,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#8,obColType(a0)
		move.b	#48/2,obActWid(a0)

Buzz_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	.index(pc,d0.w),d1
		jsr	.index(pc,d1.w)
		lea	(Ani_Buzz).l,a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================
.index:		dc.w .move-.index
		dc.w .chknearsonic-.index
; ===========================================================================

.move:
		subq.w	#1,buzz_timedelay(a0) ; subtract 1 from time delay
		bpl.s	.noflip		; if time remains, branch
		btst	#1,buzz_buzzstatus(a0) ; is Buzz Bomber near Sonic?
		bne.s	.fire		; if yes, branch
		addq.b	#2,ob2ndRout(a0)
		move.w	#127,buzz_timedelay(a0) ; set time delay to just over 2 seconds
		move.w	#$400,obVelX(a0) ; move Buzz Bomber to the right
		move.b	#1,obAnim(a0)	; use "flying" animation
		btst	#0,obStatus(a0)	; is Buzz Bomber facing left?
		bne.s	.noflip		; if not, branch
		neg.w	obVelX(a0)	; move Buzz Bomber to the left

.noflip:
		rts
; ===========================================================================

.fire:
		bsr.w	FindFreeObj
		bne.s	.fail
		_move.b	#id_Missile,obID(a1) ; load missile object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		addi.w	#$1C,obY(a1)
		move.w	#$200,obVelY(a1) ; move missile downwards
		move.w	#$200,obVelX(a1) ; move missile to the right
	if FixBugs
		moveq	#$18-4,d0
	else
		move.w	#$18,d0
	endif
		btst	#0,obStatus(a0)	; is Buzz Bomber facing left?
		bne.s	.noflip2	; if not, branch
		neg.w	d0
		neg.w	obVelX(a1)	; move missile to the left

.noflip2:
		add.w	d0,obX(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.w	#$E,buzz_timedelay(a1)
		move.l	a0,buzz_parent(a1)
		move.b	#1,buzz_buzzstatus(a0) ; set to "already fired" to prevent refiring
		move.w	#59,buzz_timedelay(a0)
		move.b	#2,obAnim(a0)	; use "firing" animation

.fail:
		rts
; ===========================================================================

.chknearsonic:
		subq.w	#1,buzz_timedelay(a0) ; subtract 1 from time delay
		bmi.s	.chgdirection
		bsr.w	SpeedToPos
		tst.b	buzz_buzzstatus(a0)
		bne.s	.keepgoing
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bpl.s	.isleft
		neg.w	d0

.isleft:
		cmpi.w	#$60,d0		; is Buzz Bomber within $60 pixels of Sonic?
		bhs.s	.keepgoing	; if not, branch
		tst.b	obRender(a0)
		bpl.s	.keepgoing
		move.b	#2,buzz_buzzstatus(a0) ; set Buzz Bomber to "near Sonic"
		move.w	#29,buzz_timedelay(a0) ; set time delay to half a second
		bra.s	.stop
; ===========================================================================

.chgdirection:
		move.b	#0,buzz_buzzstatus(a0) ; set Buzz Bomber to "normal"
		bchg	#0,obStatus(a0)	; change direction
		move.w	#59,buzz_timedelay(a0)

.stop:
		subq.b	#2,ob2ndRout(a0)
		move.w	#0,obVelX(a0)	; stop Buzz Bomber moving
		move.b	#0,obAnim(a0)	; use "hovering" animation

.keepgoing:
		rts
; ===========================================================================

Buzz_Delete:	; Routine 4
		bsr.w	DeleteObject
		rts


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 23 - missile that Buzz Bomber throws
; ---------------------------------------------------------------------------

Missile:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Msl_Index(pc,d0.w),d1
		jmp	Msl_Index(pc,d1.w)
; ===========================================================================
Msl_Index:	dc.w Msl_Main-Msl_Index
		dc.w Msl_Animate-Msl_Index
		dc.w Msl_FromBuzz-Msl_Index
		dc.w Msl_Delete-Msl_Index
		dc.w Msl_FromNewt-Msl_Index

msl_parent = objoff_3C
; ===========================================================================

Msl_Main:	; Routine 0
		subq.w	#1,objoff_32(a0)
		bpl.s	Msl_ChkCancel
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Missile,obMap(a0)
		move.w	#ArtTile_Buzz_Bomber|Tile_Pal2,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#16/2,obActWid(a0)
		andi.b	#3,obStatus(a0)
		tst.b	obSubtype(a0)	; was object created by a Newtron?
		beq.s	Msl_Animate	; if not, branch

		move.b	#8,obRoutine(a0) ; run "Msl_FromNewt" routine
		move.b	#$87,obColType(a0)
		move.b	#1,obAnim(a0)
		bra.s	Msl_Animate2
; ===========================================================================

Msl_Animate:	; Routine 2
		bsr.s	Msl_ChkCancel
	if FixBugs
		; Msl_ChkCancel can call DeleteObject, so we shouldn't queue
		; this object for display or update the animation state.
		; Failing to account for this results in a null pointer
		; dereference, which is harmless in Sonic 1 but will crash
		; Sonic 2. Fun fact: Sonic 2 REV00 has some leftover debug
		; code in its BuildSprites function for detecting this type
		; of bug.
		bne.s	.notgone
		rts
.notgone:
	endif
		lea	(Ani_Missile).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to check if the Buzz Bomber which fired the missile has been
; destroyed, and if it has, then cancel the missile
; ---------------------------------------------------------------------------

Msl_ChkCancel:
		movea.l	msl_parent(a0),a1
		_cmpi.b	#id_ExplosionItem,obID(a1) ; has Buzz Bomber been destroyed?
	if FixBugs
		; This adds a return value so that we know if the object has
		; been freed.
		bne.s	.return
		bsr.s	Msl_Delete
		moveq	#0,d0

.return:
	else
		beq.s	Msl_Delete	; if yes, branch
	endif
		rts
; End of function Msl_ChkCancel

Msl_ChkCancel.return:	equ	.return	; emulates local label access from AS disassembly

; ===========================================================================

Msl_FromBuzz:	; Routine 4
		; This check most likely used to work at some point, but was abandoned
		; in favor of simply deleting the missile after destroying the Buzz Bomber.
		; There is nothing that sets the required flag, so the branch to the below
		; missile dissolve object spawner is never run (and would be broken anyway).
		btst	#7,obStatus(a0)		; has bit 7 of status flags been set? (impossible condition)
		bne.s	.explode		; if yes, dissolve missile

		move.b	#$87,obColType(a0)
		move.b	#1,obAnim(a0)
		bsr.w	SpeedToPos

	if FixBugs=0
		; Object should not call DisplaySprite and DeleteObject on
		; the same frame, or else cause a null-pointer dereference.
		lea	(Ani_Missile).l,a1
		bsr.w	AnimateSprite
		bsr.w	DisplaySprite
	endif

		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0	; has object moved below the level boundary?
		blo.s	Msl_Delete	; if yes, branch

	if FixBugs
		lea	(Ani_Missile).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
	else
		rts
	endif
; ===========================================================================

.explode:
		; This section is unreachable because bit 7 in obStatus is never set.
		; The relevant small explosion object doesn't even have graphics
		; loaded into VRAM (the same space is occupied by the Crabmeat).
		_move.b	#id_UnusedExplosion,obID(a0)	; change object to a small explosion ($24)
		move.b	#0,obRoutine(a0)		; reset routine counter
		bra.w	UnusedExplosion			; jump to unused explosion code
; ===========================================================================

Msl_Delete:	; Routine 6
		bsr.w	DeleteObject
		rts
; ===========================================================================

Msl_FromNewt:	; Routine 8
		tst.b	obRender(a0)
		bpl.s	Msl_Delete
		bsr.w	SpeedToPos

Msl_Animate2:
		lea	(Ani_Missile).l,a1
		bsr.w	AnimateSprite
		bsr.w	DisplaySprite
		rts
; ===========================================================================

		include	"_anim/Buzz Bomber.asm"
		include	"_anim/Buzz Bomber Missile.asm"
Map_Buzz:	include	"_maps/Buzz Bomber.asm"
Map_Missile:	include	"_maps/Buzz Bomber Missile.asm"
