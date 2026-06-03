; ---------------------------------------------------------------------------
; Object 3D - Eggman (GHZ) - part 1
; ---------------------------------------------------------------------------

BossGreenHill:
		moveq	#0,d0
		move.b	obRoutine(a0),d0 			; copy object routine index to d0
		move.w	BGHZ_Index(pc,d0.w),d1 			; use the object routine index and BGHZ_Index to calculate our offset
		jmp	BGHZ_Index(pc,d1.w) 			; jump into the table and use our offset to pick a routine in the index to go to
; ===========================================================================
BGHZ_Index:	dc.w BGHZ_Main-BGHZ_Index
		dc.w BGHZ_ShipMain-BGHZ_Index
		dc.w BGHZ_FaceMain-BGHZ_Index
		dc.w BGHZ_FlameMain-BGHZ_Index

BGHZ_BossReference = objoff_34 					; Pointer to main boss controller
BGHZ_SineCounter = objoff_3F 					; sine counter for bobbing motion
BGHZ_BossGenericTimer = objoff_3C 				; timer for how many frames to do an action, whether its wait for explosions, or to move in a direction

BGHZ_ObjData:	
		dc.b 2,	0					; routine counter, animation
		dc.b 4,	1
		dc.b 6,	7
; ===========================================================================

BGHZ_Main:	; Routine 0
		lea	(BGHZ_ObjData).l,a2 			; load address of object data into a2 for indexing
		movea.l	a0,a1 					; copy boss object address into a1 so that LoadBoss on pass 1 uses the main boss object.
		moveq	#2,d1 					; set the loading loop amount, we have 3 routines so 3 times to loop
		bra.s	BGHZ_LoadBoss
; ===========================================================================

BGHZ_Loop:
		jsr	(FindNextFreeObj).l
		bne.s	BGHZ_Done 				; Are we out of objects? These flags are set in FindNextFreeObj, if Z flag is set, we can keep loading objects (no branch)

BGHZ_LoadBoss:
		move.b	(a2)+,obRoutine(a1) 			; load appropriate routine counter for this slot, then increment a2
		_move.b	#id_BossGreenHill,obID(a1) 		; set object ID for this slot
		move.w	obX(a0),obX(a1) 			; copy boss position out of a0 into a1 for sub-object coordinates so that they start at the same position
		move.w	obY(a0),obY(a1)
		move.l	#Map_Eggman,obMap(a1) 			; point to Eggman's mappings
		move.w	#ArtTile_Eggman,obGfx(a1) 		; point to Eggman's art (VRAM tile index and palette line)
		move.b	#4,obRender(a1) 			; set the object to position based on where it is in the level and not a static position on screen
		move.b	#$20,obActWid(a1) 			; set width to 20 pixel radius (to know when sprite is off screen and should be hidden)
		move.b	#3,obPriority(a1) 			; set sprite priority to 3 (0 is front of screen)
		move.b	(a2)+,obAnim(a1) 			; load appropriate animation index, then increment a2 (now we are one full entry lower in our ObjData table)
; ---------------------------------------------------------------------------
; objoff_34 is used here as a reference back to the main boss controller. 
; This is because when we are in ExecuteObjects, a0 is set to each object and sub objects own slot, so we need a way to find the original boss object.
; On the first loop, this copies the address to itself, but the other loops are what it was intended for.
		move.l	a0,BGHZ_BossReference(a1) 
; ---------------------------------------------------------------------------
		dbf	d1,BGHZ_Loop				; repeat sequence 2 more times

; loc_17772
BGHZ_Done:
		move.w	obX(a0),obBossX(a0) 			; copy to boss position using scratch RAM (objoff_30 and 38 respectively)
		move.w	obY(a0),obBossY(a0)
		move.b	#$F,obColType(a0) 			; set collision type: TTSS SSSS. T bits are for type, S is size of collision using table in sub ReactToItem.asm
		move.b	#8,obBossHits(a0) 			; set number of hits to 8

BGHZ_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0 			; load secondary routine index of current object slot into d0
		move.w	BGHZ_ShipIndex(pc,d0.w),d1 		; use the secondary object routine index and BGHZ_ShipIndex to calculate our offset
		jsr	BGHZ_ShipIndex(pc,d1.w) 		; jump into the table and use our offset to pick a routine in the index to go to
		lea	(Ani_Eggman).l,a1
		jsr	(AnimateSprite).l 			; set up animation
; ---------------------------------------------------------------------------
; obStatus stores the logical bits, but obRender is visual bits, so this simply moves them from one to the other
; ---------------------------------------------------------------------------
		move.b	obStatus(a0),d0 			; move current object status into d0
		andi.b	#3,d0 					; AND with obstatus so now d0 contains X and Y logical flip bits only
		andi.b	#$FC,obRender(a0) 			; clear the x and y flip
		or.b	d0,obRender(a0) 			; OR the two together, so now DisplaySprite has X and Y orientation and above render bits
		jmp	(DisplaySprite).l
; ===========================================================================
BGHZ_ShipIndex:	dc.w BGHZ_ShipStart-BGHZ_ShipIndex
		dc.w BGHZ_MakeBall-BGHZ_ShipIndex
		dc.w BGHZ_ShipMove-BGHZ_ShipIndex
		dc.w BGHZ_ChgDir-BGHZ_ShipIndex
		dc.w BGHZ_Explode-BGHZ_ShipIndex
		dc.w BGHZ_Recover-BGHZ_ShipIndex
		dc.w BGHZ_Escape-BGHZ_ShipIndex
; ===========================================================================

BGHZ_ShipStart:
		move.w	#$100,obVelY(a0) 			; move ship down
		bsr.w	BossMove
		cmpi.w	#boss_ghz_y+$38,obBossY(a0) 		; have we reached the desired screen position? (boss_ghz_y is the y boundary for the boss fight)
		bne.s	BGHZ_ShipUpdate				; if not, calculate bob
		move.w	#0,obVelY(a0)				; stop ship
		addq.b	#2,ob2ndRout(a0) 			; goto next routine

; loc_177E6:
BGHZ_ShipUpdate:
		move.b	BGHZ_SineCounter(a0),d0 		; set up some scratch RAM for a sine counter
		jsr	(CalcSine).l 				; result gets put into d0
		asr.w	#6,d0 					; shift right 6 bits (divide by 64), keeping signed number status
		add.w	obBossY(a0),d0 				; offset Y position with sine value
		move.w	d0,obY(a0) 				; set the Y to the "bob" that was calculated
		move.w	obBossX(a0),obX(a0) 			; sync x positions
		addq.b	#2,BGHZ_SineCounter(a0) 		; increment sine counter by 2 (to iterate through the sine table)
		cmpi.b	#8,ob2ndRout(a0) 			; are we exploding?
		bhs.s	.exit 					; if so, skip hit detection and return
		tst.b	obStatus(a0) 				; has Eggman's defeated flag been set (bit 7)?
		bmi.s	BGHZ_Defeated 				; if yes (negative number) branch
		tst.b	obColType(a0) 				; is the boss hittable?
		bne.s	.exit 					; if not, leave
		tst.b	obBossFlash(a0) 			; is this a non-zero value (collision disabled if so, must mean boss is already flashing)
		bne.s	.flash 					; we are flashing already, skip ahead
		move.b	#$20,obBossFlash(a0)			; set number of times for ship to flash
		move.w	#sfx_HitBoss,d0
		jsr	(QueueSound2).l				; play boss damage sound

; BGHZ_ShipFlash:
.flash:
		lea	(v_palette+$22).w,a1 			; load 2nd palette, 2nd entry
		moveq	#0,d0					; move 0 (black) to d0
		tst.w	(a1)        				; is the color here black? This is a cool trick, since tst will set its flags based on if the value is 0. What color is black? All 0s!
		bne.s	.writeColor   				; if not black, already white, so branch
		move.w	#cWhite,d0				; move 0EEE (white) to d0

; loc_1783C:
.writeColor:
		move.w	d0,(a1)					; load color stored in d0
		subq.b	#1,obBossFlash(a0) 			; subtract 1 from flash timer
		bne.s	.exit 					; keep flashing if obBossFlash is not 0
		move.b	#$F,obColType(a0) 			; restore collision, the timer has hit 0

;locret_1784A:
.exit:
		rts
; ===========================================================================

; loc_1784C:
BGHZ_Defeated:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#8,ob2ndRout(a0) 			; set object routine to BGHZ_Explode
		move.w	#$B3,BGHZ_BossGenericTimer(a0) 		; set the boss timer
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Defeated boss subroutine (shared by all bosses)
; ---------------------------------------------------------------------------

BossDefeated:
		move.b	(v_vblank_byte).w,d0
		andi.b	#7,d0 					; AND with the first 3 bits
		bne.s	.noExplosion 				; don't load an object: this limits explosions to load every 8 frames
		jsr	(FindFreeObj).l
		bne.s	.noExplosion 				; no free objects, exit
		_move.b	#id_Explosion,obID(a1)			; load explosion object
		move.w	obX(a0),obX(a1) 			; set explosion position to boss position
		move.w	obY(a0),obY(a1)
		jsr	(RandomNumber).l 			; generate a random number for position
		move.w	d0,d1 					; copy random number to d1
		moveq	#0,d1 					; ditch the first byte
		move.b	d0,d1 					; copy first byte of d0 to first byte of d1
		lsr.b	#2,d1 					; scale down the random number
		subi.w	#$20,d1 				; shift left by $20 pixels, otherwise all explosions would be on the right side of the boss.
		; No shift is made for the Y position, hard to tell if it was intentional or not, but all explosions are biased downwards due to this.
		add.w	d1,obX(a1) 				; apply random x
		lsr.w	#8,d0 					; shift high byte into low byte
		lsr.b	#3,d0 					; scale down the random number
		add.w	d0,obY(a1) 				; apply random y

; locret_178A2:
.noExplosion:
		rts
; End of function BossDefeated


; ---------------------------------------------------------------------------
; Subroutine to move a boss (shared by all bosses)
; ---------------------------------------------------------------------------

BossMove:
		move.l	obBossX(a0),d2
		move.l	obBossY(a0),d3
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,obBossX(a0)
		move.l	d3,obBossY(a0)
		rts
; End of function BossMove

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3D - Eggman (GHZ) - part 2
; ---------------------------------------------------------------------------

BGHZ_MakeBall:
		move.w	#-$100,obVelX(a0)
		move.w	#-$40,obVelY(a0)
		bsr.w	BossMove
		cmpi.w	#boss_ghz_x+$A0,obBossX(a0) 		; are we in the proper position?
		bne.s	.return 				; no, keep moving boss
		move.w	#0,obVelX(a0) 				; set our velocity to 0
		move.w	#0,obVelY(a0)
		addq.b	#2,ob2ndRout(a0) 			; advance the routine index so that when we are done we go to ShipMove
		jsr	(FindNextFreeObj).l
		bne.s	.skip 					; no free objects? skip loading
		_move.b	#id_BossBall,obID(a1) 			; load swinging ball object
		move.w	obBossX(a0),obX(a1) 			; copy boss position scratch RAM to actual object position
		move.w	obBossY(a0),obY(a1)
		move.l	a0,BGHZ_BossReference(a1) 		; same thing as way up in LoadBoss, store a pointer of the main boss object for future reference

; loc_17910:
.skip:
		move.w	#$77,BGHZ_BossGenericTimer(a0) 		; set a timer to move for 77 frames after ball logic is complete

; loc_17916:
.return:
		bra.w	BGHZ_ShipUpdate
; ===========================================================================

BGHZ_ShipMove:
		subq.w	#1,BGHZ_BossGenericTimer(a0) 		; subtrack 1 from timer
		bpl.s	BGHZ_Reverse 				; are we positive? if so branch
		addq.b	#2,ob2ndRout(a0)			; advance routine so now we are in ChgDir
		move.w	#$40-1,BGHZ_BossGenericTimer(a0)        ; set a new timer
		move.w	#$100,obVelX(a0) 			; move the ship sideways
		cmpi.w	#boss_ghz_x+$A0,obBossX(a0) 		; have we reached the x pos limit?
		bne.s	BGHZ_Reverse 				; if yes, reverse 
		move.w	#($40*2)-1,BGHZ_BossGenericTimer(a0) 	; increase timer to stay put before moving again
		move.w	#$40,obVelX(a0) 			; change velocity

BGHZ_Reverse:
		btst	#0,obStatus(a0) 			; are we facing the right (bit 0 set)
		bne.s	.facingRight 				; if yes, branch
		neg.w	obVelX(a0)				; reverse direction of the ship

; loc_17950:
.facingRight:
		bra.w	BGHZ_ShipUpdate
; ===========================================================================

; loc_17954:
BGHZ_ChgDir:
		subq.w	#1,BGHZ_BossGenericTimer(a0) 		; has the timer gone below 0?
		bmi.s	.flipDirection 				; if so, branch
		bsr.w	BossMove
		bra.s	.return
; ===========================================================================

; loc_17960:
.flipDirection:
		bchg	#0,obStatus(a0) 			; flip bit 0 (flip direction of ship)
		move.w	#$40-1,BGHZ_BossGenericTimer(a0) 	; set timer to 39 frames, slight wait before changing direction
		subq.b	#2,ob2ndRout(a0) 			; go back to ShipMove
		move.w	#0,obVelX(a0) 				; stand still

; loc_17960:
.return
		bra.w	BGHZ_ShipUpdate
; ===========================================================================

; loc_1797A:
BGHZ_Explode:
		subq.w	#1,BGHZ_BossGenericTimer(a0) 		; are we done exploding?
		bmi.s	.stopExplosions 			; yes, stop explosions
		bra.w	BossDefeated
; ===========================================================================

; loc_17984:
.stopExplosions:
		bset	#0,obStatus(a0) 			; set bit 0 to 1 (facing right)
		bclr	#7,obStatus(a0) 			; clear destroyed/defeated flag (flag is set in sub ReactToItem.asm)
		clr.w	obVelX(a0) 				; stop moving vertically (horizontal velocity is not cleared)
		addq.b	#2,ob2ndRout(a0) 			; advance routine to recover
		move.w	#-$26,BGHZ_BossGenericTimer(a0) 	; set negative timer to count up from
		tst.b	(v_bossstatus).w 			; has the boss been marked as defeated?
		bne.s	.exit 					; if yes, leave early
		move.b	#1,(v_bossstatus).w 			; set the boss as defeated

; locret_179AA:
.exit:
		rts
; ===========================================================================

; loc_179AC:
BGHZ_Recover:
		addq.w	#1,BGHZ_BossGenericTimer(a0) 		; increment the timer
		beq.s	.doneFalling 				; if the timer has hit 0, branch here
		bpl.s	.timerPositive 				; if the timer has hit a positive value, branch here
		addi.w	#$18,obVelY(a0) 			; make Eggman fall a little
		bra.s	.exit
; ===========================================================================

; loc_179BC:
.doneFalling:
		clr.w	obVelY(a0) 				; set velocity to 0, we are done falling
		bra.s	.exit
; ===========================================================================

; loc_179C2:
.timerPositive
		cmpi.w	#$30,BGHZ_BossGenericTimer(a0) 		; is the timer below $30?
		blo.s	.rise 					; if yes, start to rise
		beq.s	.playMusic 				; stop and play music
		cmpi.w	#$38,BGHZ_BossGenericTimer(a0) 		; is timer below $38?
		blo.s	.exit					; if yes, do nothing
		addq.b	#2,ob2ndRout(a0) 			; advance to BGHZ_Escape
		bra.s	.exit
; ===========================================================================

; loc_179DA:
.rise:
		subq.w	#8,obVelY(a0) 				; slow down, eventually causing him to rise upwards (gives a smooth motion)
		bra.s	.exit
; ===========================================================================

; loc_179E0:
.playMusic:
		clr.w	obVelY(a0) 				; stop moving
		move.w	#bgm_GHZ,d0
		jsr	(QueueSound1).l				; play GHZ music

; loc_179EE:
.exit:
		bsr.w	BossMove
		bra.w	BGHZ_ShipUpdate
; ===========================================================================

; loc_179F6:
BGHZ_Escape:
		move.w	#$400,obVelX(a0) 			; move to the right quickly
		move.w	#-$40,obVelY(a0) 			; move up a little bit
		cmpi.w	#boss_ghz_end,(v_limitright2).w 	; have we finished scrolling to the right (reached level bounds)?
		beq.s	.checkOffScreen 			; if so, branch
		addq.w	#2,(v_limitright2).w 			; keep unlocking the bounds of the screen by 2 pixels
		bra.s	.flee
; ===========================================================================

; loc_17A10:
.checkOffScreen:
		tst.b	obRender(a0) 				; has Eggman left the screen (is bit 7 clear)?
		bpl.s	BGHZ_ShipDel 				; yes, bit 7 is cleared, so we can delete the object (this is 2's complement related!)

; loc_17A16:
.flee:
		bsr.w	BossMove 				; keep escaping
		bra.w	BGHZ_ShipUpdate
; ===========================================================================

BGHZ_ShipDel:
	if FixBugs
		; We do not want to return to BGHZ_ShipUpdate, as objects
		; should not queue themselves for display while also being
		; deleted.
		addq.l	#4,sp
	endif
		jmp	(DeleteObject).l
; ===========================================================================

BGHZ_FaceMain:	; Routine 4
		moveq	#0,d0
		moveq	#1,d1 					; set facenormal1 animation
		movea.l	BGHZ_BossReference(a0),a1 		; load the main boss controller into a1
		move.b	ob2ndRout(a1),d0 			; load boss phase into d0
		subq.b	#4,d0 					; go back 2 routines
		bne.s	.checkSpecial 				; were we at ShipMove? if not, branch
		cmpi.w	#boss_ghz_x+$A0,obBossX(a1) 		; has the ship reached the starting area?
		bne.s	.checkHitState 				; if not, branch
		moveq	#4,d1 					; set animation to facelaugh, we are at default area

; loc_17A3E:
.checkSpecial:
		subq.b	#6,d0 					; are we in Recover or Escape state (if we looped around, we are negative, so must be in Recover or Escape)
		bmi.s	.checkHitState 				; no, check if we have collided with Sonic
		moveq	#$A,d1 					; set defeated animation
		bra.s	.writeAnim
; ===========================================================================

; loc_17A46:
.checkHitState:
		tst.b	obColType(a1) 				; is the boss currently being hit?
		bne.s	.checkSonicState 			; if not, check Sonic's state
		moveq	#5,d1 					; set animation to facehit
		bra.s	.writeAnim
; ===========================================================================

; loc_17A50:
.checkSonicState:
		cmpi.b	#4,(v_player+obRoutine).w  		; is Sonic currently being hit?
		blo.s	.writeAnim 				; if not, branch
		moveq	#4,d1 					; set animation to facelaugh

; loc_17A5A:
.writeAnim:
		move.b	d1,obAnim(a0) 				; move animation state into obAnim
; ----------------------------------------------------------------------------
; The below line checks: are we in the escape state? 
; 12-4-6-2=0, so if we are in the escape state this is true, any other state would not result in a 0. If all this confuses you, review the _Index code throughout this file.
; ----------------------------------------------------------------------------		
		subq.b	#2,d0 
		bne.s	.skip 					; we are not escaping, display normally
		move.b	#6,obAnim(a0) 				; set animation state to facepanic
		tst.b	obRender(a0) 				; has Eggman's face left the screen?
		bpl.s	BGHZ_FaceDel 				; yes, delete his face

; BGHZ_FaceDisp
.skip:
		bra.s	BGHZ_Display
; ===========================================================================

BGHZ_FaceDel:
		jmp	(DeleteObject).l
; ===========================================================================

BGHZ_FlameMain:	; Routine 6
		move.b	#7,obAnim(a0) 				; set animation state to 7 (default invisible state for flame)
		movea.l	BGHZ_BossReference(a0),a1 		; load main boss controller into a1
		cmpi.b	#$C,ob2ndRout(a1) 			; are we in the Escape state?
		bne.s	.checkMove 				; no, check movement
		move.b	#$B,obAnim(a0) 				; set thruster animation for takeoff
		tst.b	obRender(a0) 				; what is our screen status?
		bpl.s	BGHZ_FlameDel 				; off screen, delete
		bra.s	BGHZ_FlameDisp 				; on screen, display
; ===========================================================================

; loc_17A96:
.checkMove:
		move.w	obVelX(a1),d0 				; are we currently moving?
		beq.s	BGHZ_FlameDisp 				; no, don't display flame
		move.b	#8,obAnim(a0) 				; yes, display flame

BGHZ_FlameDisp:
		bra.s	BGHZ_Display
; ===========================================================================

BGHZ_FlameDel:
		jmp	(DeleteObject).l
; ===========================================================================

BGHZ_Display:
		movea.l	BGHZ_BossReference(a0),a1 		; load main boss controller into a1
		move.w	obX(a1),obX(a0) 			; move positions to rendered positions of boss
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0) 		; move object status to boss object status
		lea	(Ani_Eggman).l,a1
		jsr	(AnimateSprite).l
		move.b	obStatus(a0),d0 			; move current object status into d0
		andi.b	#3,d0 					; AND with obstatus so now d0 contains X and Y logical flip bits only
		andi.b	#$FC,obRender(a0) 			; clear the x and y flip
		or.b	d0,obRender(a0) 			; OR the two together, so now DisplaySprite has X and Y orientation and above render bits
		jmp	(DisplaySprite).l
; ===========================================================================
