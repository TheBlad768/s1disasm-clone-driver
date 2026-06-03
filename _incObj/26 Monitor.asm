; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------

Monitor:
		moveq	#0,d0				; clear d0
		move.b	obRoutine(a0),d0		; get routine number
		move.w	Mon_Index(pc,d0.w),d1		; find entry in offset table
		jmp	Mon_Index(pc,d1.w)		; jump to current routine
; ===========================================================================
Mon_Index:	dc.w Mon_Main-Mon_Index			; 0 - init
		dc.w Mon_Solid-Mon_Index		; 2 - idle and unbroken
		dc.w Mon_BreakOpen-Mon_Index		; 4 - break triggered from ReactToItem
		dc.w Mon_Animate-Mon_Index		; 6 - idle and broken
		dc.w Mon_Display-Mon_Index		; 8 - if spawned already broken
; ===========================================================================

Mon_Main:	; Routine 0
	if FixBugs
		; Convert monitors with invalid subtypes (above 8) into solid barriers,
		; preserving the subtype as width and height setting for the barrier.
		; SBZ2 has a handful of these broken monitors hidden in walls, all
		; of which match to properly sized invisible solid barriers, likely
		; originating from improper data conversion late into development.
		cmpi.b	#8,obSubtype(a0)		; is monitor subtype valid? i.e. no higher than goggles monitor (ID 8)
		bls.s	.valid				; if yes, branch
		move.b	#id_Invisibarrier,obID(a0)	; otherwise, convert this monitor to an invisible solid barrier
		jmp	(Invisibarrier).l		; execute barrier logic
.valid:
	endif

		addq.b	#2,obRoutine(a0)		; go to "Mon_Solid" next
		move.b	#$E,obHeight(a0)		; set height
		move.b	#$E,obWidth(a0)			; set width
		move.l	#Map_Monitor,obMap(a0)		; set mappings
		move.w	#ArtTile_Monitor,obGfx(a0)	; set art tile
		move.b	#4,obRender(a0)			; set render mode to playfield-positioned
		move.b	#3,obPriority(a0)		; set sprite priority to 3
		move.b	#$F,obActWid(a0)		; set render width

		lea	(v_objstate).w,a2		; get object respawn table
		moveq	#0,d0				; clear d0
		move.b	obRespawnNo(a0),d0		; get monitor's respawn table index number
		bclr	#7,2(a2,d0.w)			; immediately clear the respawn flag (...why?)
		btst	#0,2(a2,d0.w)			; has monitor already been broken?
		beq.s	.notbroken			; if not, branch

		move.b	#8,obRoutine(a0)		; run "Mon_Display" routine
		move.b	#$B,obFrame(a0)			; use broken monitor frame
		rts					; only start displaying next frame
; ===========================================================================

.notbroken:
		move.b	#$46,obColType(a0)		; set collision size to 16x16 and type to item
		move.b	obSubtype(a0),obAnim(a0)	; use subtype as animation ID

Mon_Solid:	; Routine 2
		move.b	ob2ndRout(a0),d0		; is monitor set to fall or being stood on?
		beq.s	.normal				; if not, branch
		subq.b	#2,d0				; is monitor specifically set to fall?
		bne.s	.fall				; if yes, branch

		; 2nd Routine 2
		moveq	#0,d1				; clear d1
		move.b	obActWid(a0),d1			; get monitor's display width
		addi.w	#sonic_solid_width,d1		; add Sonic's collision width for solids ($B)
		bsr.w	ExitPlatform			; clear platform flags if Sonic was standing on the monitor
		btst	#3,obStatus(a1)			; is Sonic still on top of the monitor?
		bne.w	.ontop				; if yes, branch
		clr.b	ob2ndRout(a0)			; clear special monitor subroutines
		bra.w	Mon_Animate			; process monitor normally
; ===========================================================================

.ontop:
		move.w	#$10,d3				; set solid width
		move.w	obX(a0),d2			; get monitor's X position
		bsr.w	MvSonicOnPtfm			; make Sonic run along the monitor like a platform
		bra.w	Mon_Animate			; process monitor normally
; ===========================================================================

.fall:		; 2nd Routine 4
		bsr.w	ObjectFall			; apply gravity and update monitor position
		jsr	(ObjFloorDist).l		; get distance from monitor to floor
		tst.w	d1				; has monitor hit the floor?
		bpl.w	Mon_Animate			; if not, branch
		add.w	d1,obY(a0)			; align monitor with surface
		clr.w	obVelY(a0)			; stop monitor from falling
		clr.b	ob2ndRout(a0)			; clear special monitor subroutines
		bra.w	Mon_Animate			; process monitor normally
; ===========================================================================

.normal:	; 2nd Routine 0
		move.w	#$F+sonic_solid_width,d1	; width/2
		move.w	#$F,d2				; height/2
		bsr.w	Mon_SolidSides			; check collision (0 = none; 1 = side; -1 = top/bottom)
		beq.w	.checkpush			; if not, branch

		tst.w	obVelY(a1)			; is Sonic moving upwards?
		bmi.s	.dontbreak			; if yes, branch
		cmpi.b	#id_Roll,obAnim(a1)		; is Sonic rolling?
		beq.s	.checkpush			; if yes, branch

; loc_A20A:
.dontbreak:
		tst.w	d1				; has Sonic touched the monitor from the sides?
		bpl.s	.sidetouch			; if yes, branch
		sub.w	d3,obY(a1)			; align Sonic to the top of the monitor
		bsr.w	Plat_NoCheck			; update platform status flags for Sonic and monitor
		move.b	#2,ob2ndRout(a0)		; set secondary monitor state to ".ontop"
		bra.w	Mon_Animate			; process monitor normally
; ===========================================================================

; loc_A220:
.sidetouch:
		tst.w	d0				; check Sonic's horizontal distance to the monitor
		beq.w	.push				; if exactly the same, branch
		bmi.s	.sonicleft			; if to the left of the monitor, branch

.sonicright:
		tst.w	obVelX(a1)			; is Sonic moving to the left?
		bmi.s	.push				; if yes, branch
		bra.s	.stopsonic			; otherwise, keep Sonic in place
; ===========================================================================

; loc_A230:
.sonicleft:
		tst.w	obVelX(a1)			; is Sonic moving to the right or still?
		bpl.s	.push				; if yes, branch

; loc_A236:
.stopsonic:
		sub.w	d0,obX(a1)			; horizontally align Sonic to monitor
		move.w	#0,obInertia(a1)		; stop Sonic moving
		move.w	#0,obVelX(a1)			; ''

; loc_A246:
.push:
		btst	#1,obStatus(a1)			; is Sonic airborne?
		bne.s	.stoppushing			; if yes, branch
		bset	#5,obStatus(a1)			; set Sonic's pushing flag
		bset	#5,obStatus(a0)			; set monitor's flag that it's being pushed
		bra.s	Mon_Animate			; process monitor normally
; ===========================================================================

; loc_A25C:
.checkpush:
		btst	#5,obStatus(a0)			; is Sonic still pushing against the monitor?
		beq.s	Mon_Animate			; if not, branch
	if FixBugs=0
		; This causes the infamous "walk-jump bug"
		move.w	#id_Run,obAnim(a1)		; clear obAnim and set obNextAni to 1
	endif

; loc_A26A:
.stoppushing:
		bclr	#5,obStatus(a0)			; clear pushing flag for monitor
		bclr	#5,obStatus(a1)			; clear pushing flag for Sonic

Mon_Animate:	; Routine 6
		lea	(Ani_Monitor).l,a1		; get animation script for monitor
		bsr.w	AnimateSprite			; animate monitor

Mon_Display:	; Routine 8
	if FixBugs
		; Objects shouldn't call DisplaySprite and DeleteObject in
		; the same frame or else cause a null-pointer dereference.
		out_of_range.w	DeleteObject		; check if monitor has gone offscreen and delete it if so
		bra.w	DisplaySprite			; otherwise, display it
	else
		bsr.w	DisplaySprite			; display monitor
		out_of_range.w	DeleteObject		; check if monitor has gone offscreen and delete it if so
		rts					; return
	endif
; ===========================================================================

Mon_BreakOpen:	; Routine 4 (set from ReactToItem)
		addq.b	#2,obRoutine(a0)		; advance to "Mon_Animate"
		move.b	#0,obColType(a0)		; prevent further collision with monitor

		bsr.w	FindFreeObj			; find a free object slot
		bne.s	Mon_Explode			; if object RAM is full, branch
		_move.b	#id_PowerUp,obID(a1)		; load monitor contents object
		move.w	obX(a0),obX(a1)			; copy X position
		move.w	obY(a0),obY(a1)			; copy Y position
		move.b	obAnim(a0),obAnim(a1)		; copy animation (which also handles the power-up)

Mon_Explode:
		bsr.w	FindFreeObj			; find another free object slot
		bne.s	Mon_RememberBroken		; if object RAM is full, branch
		_move.b	#id_ExplosionItem,obID(a1)	; load explosion object
		addq.b	#2,obRoutine(a1)		; skip over ExItem_Animal so no animal is spawned
		move.w	obX(a0),obX(a1)			; copy X position
		move.w	obY(a0),obY(a1)			; copy Y position

; .fail:
Mon_RememberBroken:
		lea	(v_objstate).w,a2		; get object respawn table
		moveq	#0,d0				; clear d0
		move.b	obRespawnNo(a0),d0		; get monitor's respawn table index number
		bset	#0,2(a2,d0.w)			; remember that this monitor has been broken in respawn table

		move.b	#9,obAnim(a0)			; set monitor animation to broken
		bra.w	DisplaySprite			; keep displaying broken monitor

