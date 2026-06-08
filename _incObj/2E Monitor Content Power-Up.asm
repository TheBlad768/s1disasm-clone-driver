; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------

PowerUp:
		moveq	#0,d0				; clear d0
		move.b	obRoutine(a0),d0		; get routine number
		move.w	Pow_Index(pc,d0.w),d1		; find entry in offset table
		jsr	Pow_Index(pc,d1.w)		; jump to current routine and return
		bra.w	DisplaySprite			; display monitor icon sprite
; ===========================================================================
Pow_Index:	dc.w Pow_Main-Pow_Index			; 0 - init
		dc.w Pow_Move-Pow_Index			; 2 - icon is moving up
		dc.w Pow_Delete-Pow_Index		; 4 - wait and delete
; ===========================================================================

Pow_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)		; advance to Pow_Move
		move.w	#ArtTile_Monitor,obGfx(a0)	; set art tile
		move.b	#$24,obRender(a0)		; set "raw-mappings" flag and playfield positioning mode
		move.b	#3,obPriority(a0)		; set sprite priority to 3
		move.b	#8,obActWid(a0)			; set display width
		move.w	#-$300,obVelY(a0)		; set initial upwards momentum of the icon

		; Raw Mappings: Set mappings pointer to point directly to the icon sprite piece
		moveq	#0,d0				; clear d0
		move.b	obAnim(a0),d0			; get monitor subtype
		addq.b	#2,d0				; skip over the two extra static frames
		move.b	d0,obFrame(a0)			; set frame (redundant for raw mappings)
		movea.l	#Map_Monitor,a1			; load monitor mappings
		add.b	d0,d0				; double frame ID for word-based indexing
		adda.w	(a1,d0.w),a1			; go to relevant mapping for monitor type
		addq.w	#1,a1				; skip over the sprite header
		move.l	a1,obMap(a0)			; use first sprite piece of mapping for raw mappings pointer

Pow_Move:	; Routine 2
		tst.w	obVelY(a0)			; is icon still moving upwards?
		bpl.w	Pow_Checks			; if not, branch to give monitor reward now
		bsr.w	SpeedToPos			; update icon position
		addi.w	#$18,obVelY(a0)			; reduce icon's upward speed
		rts					; wait until it has stopped moving
; ===========================================================================

Pow_Checks:
		addq.b	#2,obRoutine(a0)		; advance to Pow_Delete
		move.w	#30-1,obTimeFrame(a0)		; display icon for half a second
		move.b	obAnim(a0),d0			; get animation ID to use as check for the monitor type

Pow_ChkEggman:
		cmpi.b	#1,d0				; does monitor contain Eggman?
		bne.s	Pow_ChkSonic			; if not, branch
	if FixBugs
		; Fix the Eggman monitor
		; https://info.sonicretro.org/SCHG_How-to:Have_a_functional_Eggman_monitor_in_Sonic_1
		move.w	obX(a0),spikes_origX(a0)	; needed to display the icon properly
		jmp	(Spikes_Hurt).l			; use imaginary spikes to hurt Sonic
	else
		rts					; Eggman monitor does nothing by default
	endif
; ===========================================================================

Pow_ChkSonic:
		cmpi.b	#2,d0				; does monitor contain Sonic?
		bne.s	Pow_ChkShoes			; if not, branch

ExtraLife:
		addq.b	#1,(v_lives).w			; add 1 to the number of lives you have
		addq.b	#1,(f_lifecount).w		; update the lives counter
		move.w	#bgm_ExtraLife,d0		; set extra life music
		jmp	(QueueSound1).l			; play it
; ===========================================================================

Pow_ChkShoes:
		cmpi.b	#3,d0				; does monitor contain speed shoes?
		bne.s	Pow_ChkShield			; if not, branch

		move.b	#1,(v_shoes).w			; set speed shoes flag (used for reverting when time ran out)
		move.w	#20*60,(v_player+shoetime).w	; set time limit for speed shoes to 20 seconds
		move.w	#$C00,(v_sonspeedmax).w		; change Sonic's top speed
		move.w	#$18,(v_sonspeedacc).w		; change Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w		; change Sonic's deceleration
		move.w	#bgm_Speedup,d0			; set music speed-up command
		jmp	(QueueSound1).l			; play it
; ===========================================================================

Pow_ChkShield:
		cmpi.b	#4,d0				; does monitor contain a shield?
		bne.s	Pow_ChkInvinc			; if not, branch

		move.b	#1,(v_shield).w			; give Sonic a shield
		move.b	#id_ShieldItem,(v_shieldobj).w	; load shield object ($38)
		move.w	#sfx_Shield,d0			; set shield sound effect
		jmp	(QueueSound1).l			; play it
; ===========================================================================

Pow_ChkInvinc:
		cmpi.b	#5,d0				; does monitor contain invincibility?
		bne.s	Pow_ChkRings			; if not, branch

		move.b	#1,(v_invinc).w			; make Sonic invincible
		move.w	#20*60,(v_player+invtime).w	; set time limit for invincibility to 20 seconds

		move.b	#id_ShieldItem,(v_starsobj1).w	; load 1st stars object
		move.b	#1,(v_starsobj1+obAnim).w	; set shortest travel delay
		move.b	#id_ShieldItem,(v_starsobj2).w	; load 2nd stars object
		move.b	#2,(v_starsobj2+obAnim).w	; set short travel delay
		move.b	#id_ShieldItem,(v_starsobj3).w	; load 3rd stars object
		move.b	#3,(v_starsobj3+obAnim).w	; set long travel delay
		move.b	#id_ShieldItem,(v_starsobj4).w	; load 4th stars object
		move.b	#4,(v_starsobj4+obAnim).w	; set longest travel delay

		tst.b	(f_lockscreen).w		; is boss mode on?
		bne.s	Pow_NoMusic			; if yes, don't change music
	if Revision<>0
		cmpi.w	#12,(v_air).w			; is Sonic close to drowning? (countdown music playing)
		bls.s	Pow_NoMusic			; if yes, don't change music
	endif
		move.w	#bgm_Invincible,d0		; set invincibility music
		jmp	(QueueSound1).l			; play it

Pow_NoMusic:
		rts					; don't play music
; ===========================================================================

Pow_ChkRings:
		cmpi.b	#6,d0				; does monitor contain 10 rings?
		bne.s	Pow_ChkS			; if not, branch

		addi.w	#10,(v_rings).w			; add 10 rings to the number of rings you have
	if FixBugs
		; There isn't any limit to how many rings the player can
		; collect, which bugs out the ring counter at 999+ rings.
		; Sonic 2 REV00 only fixed this for regular rings, while
		; monitors were not fixed until REV01.
		cmpi.w	#999,(v_rings).w		; does the player have 999 rings?
		blo.s	.belowmax			; if not, branch
		move.w	#999,(v_rings).w		; cap at 999 rings

.belowmax:
	endif
		ori.b	#1,(f_ringcount).w		; update the ring counter
		cmpi.w	#100,(v_rings).w		; check if you have at least 100 rings now
		blo.s	Pow_RingSound			; if not, branch
		bset	#1,(v_lifecount).w		; set 100 rings extra life flag
		beq.w	ExtraLife			; if it wasn't already set, award an extra life
		cmpi.w	#200,(v_rings).w		; check if you have at least 200 rings now
		blo.s	Pow_RingSound			; if not, branch
		bset	#2,(v_lifecount).w		; set 200 rings extra life flag
		beq.w	ExtraLife			; if it wasn't already set, award an extra life

Pow_RingSound:
		move.w	#sfx_Ring,d0			; set ring sound collection effect
		jmp	(QueueSound1).l			; play it
; ===========================================================================

Pow_ChkS:
		cmpi.b	#7,d0				; does monitor contain 'S'?
		bne.s	Pow_ChkGoggles			; if not, branch
		nop					; 'S' does nothing by default
; ===========================================================================

Pow_ChkGoggles:
; Uncomment these lines to set up the goggles monitor to work with it
	;	cmpi.b	#8,d0				; does monitor contain goggles?
	;	bne.s	Pow_ChkEnd			; if not, branch
	;	nop					; goggles do nothing by default
; ===========================================================================
	
Pow_ChkEnd:
		rts					; subtype isn't any valid monitor ID
; ===========================================================================

Pow_Delete:	; Routine 4
		subq.w	#1,obTimeFrame(a0)		; deduct 1 from final delay (half a second by default)
	if FixBugs
		; Avoid returning to PowerUp to prevent display-and-delete
		; and double-delete bugs.
		bmi.s	.return				; if time remains, branch
		addq.l	#4,sp				; tamper return value to not return to PowerUp
		bra.w	DeleteObject			; delete icon object
	else
		bmi.w	DeleteObject			; delete icon object after half a second
	endif

.return:
		rts					; return to PowerUp to keep displaying icon

