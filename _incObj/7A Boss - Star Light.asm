; ---------------------------------------------------------------------------
; Object 7A - Eggman (SLZ)
; ---------------------------------------------------------------------------

BossStarLight_Delete:
		jmp	(DeleteObject).l
; ===========================================================================

BossStarLight:
		moveq	#0,d0
		move.b	obRoutine(a0),d0 			; copy object routine to d0
		move.w	BossStarLight_Index(pc,d0.w),d1 	; use the object routine index and BossStarLight_Index to calculate our offset
		jmp	BossStarLight_Index(pc,d1.w) 		; jump into the table and use our offset to pick a routine in the index to go to
; ===========================================================================
BossStarLight_Index:
		dc.w BossStarLight_Main-BossStarLight_Index
		dc.w BossStarLight_ShipMain-BossStarLight_Index
		dc.w BossStarLight_FaceMain-BossStarLight_Index
		dc.w BossStarLight_FlameMain-BossStarLight_Index
		dc.w BossStarLight_PipeMain-BossStarLight_Index

BossStarLight_Reference = objoff_34 				; Pointer to main boss controller
BossStarLight_SineCounter = objoff_3F 				; sine counter for bobbing motion
BossStarLight_GenericTimer = objoff_3C 				; timer for how many frames to do an action, whether its wait for explosions, or to move in a direction
BossStarLight_SeesawList = objoff_2A 				; location within boss object to store a list of all seesaw objects

BossStarLight_ObjData:	dc.b 2,	0, 4				; routine number, animation, priority
		dc.b 4,	1, 4
		dc.b 6,	7, 4
		dc.b 8,	0, 3
; ===========================================================================

BossStarLight_Main:
		move.w	#boss_slz_x+$188,obX(a0) 		; set render position based on screen position + offset
		move.w	#boss_slz_y+$18,obY(a0)
		move.w	obX(a0),obBossX(a0) 			; set actual boss position using scratch RAM (objoff_30 and 38 respectively)
		move.w	obY(a0),obBossY(a0)
		move.b	#$F,obColType(a0) 			; set collision type: TTSS SSSS. T bits are for type, S is size of collision using table in sub ReactToItem.asm
		move.b	#8,obBossHits(a0) 			; set number of hits to 8
		lea	BossStarLight_ObjData(pc),a2 		; load routine data address into a2
		movea.l	a0,a1 					; copy boss object address into a1 so that LoadBoss on pass 1 uses the main boss object.
		moveq	#3,d1 					; 4 slots of ObjData, so to load properly we must loop 4 times
		bra.s	BossStarLight_LoadBoss
; ===========================================================================

BossStarLight_Loop:
		jsr	(FindNextFreeObj).l 			; are there any free objects?
		bne.s	BossStarLight_Done			; no, leave early
		_move.b	#id_BossStarLight,obID(a1) 		; set object ID for this slot
		move.w	obX(a0),obX(a1) 			; set object position to boss position
		move.w	obY(a0),obY(a1)

BossStarLight_LoadBoss:
		bclr	#0,obStatus(a0) 			; clear the X orientation bit
		clr.b	ob2ndRout(a1) 				; clear second routine status (ShipIndex below)
		move.b	(a2)+,obRoutine(a1) 			; load first objData byte and increment
		move.b	(a2)+,obAnim(a1)
		move.b	(a2)+,obPriority(a1)
		move.l	#Map_Eggman,obMap(a1) 			; load mappings and graphics for the object
		move.w	#ArtTile_Eggman,obGfx(a1)
		move.b	#4,obRender(a1) 			; set the object to position based on where it is in the level and not a static position on screen
		move.b	#$20,obActWid(a1) 			; set collision to 20 pixel radius box
; ---------------------------------------------------------------------------
; objoff_34 is used here as a reference back to the main boss controller. 
; This is because when we are in ExecuteObjects, a0 is set to each object and sub objects own slot, so we need a way to find the original boss object.
; On the first loop, this copies the address to itself, but the other loops are what it was intended for.
		move.l	a0,BossStarLight_Reference(a1) 
; ---------------------------------------------------------------------------
		dbf	d1,BossStarLight_Loop			; repeat sequence 3 more times

BossStarLight_Done:
	if FixBugs
		lea	(v_lvlobjspace).w,a1 			; load level object space address into a1
	else
		lea	(v_objspace+object_size*1).w,a1 	; Nonsensical starting point, since dynamic object allocations begin at v_lvlobjspace.
	endif
		lea	BossStarLight_SeesawList(a0),a2 	; load some scratch RAM from the boss object into a2 to keep track of seesaws
		moveq	#id_Seesaw,d0
	if FixBugs
		moveq	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d1
	else
		moveq	#(v_objspace_end-(v_objspace+object_size*1))/object_size/2-1,d1	; Nonsensical length, it only covers the first half of object RAM.
	endif

BossStarLight_CheckSaws:
		cmp.b	obID(a1),d0 				; is the object a seesaw?
		bne.s	.skip 					; no, skip
		tst.b	obSubtype(a1) 				; does the seesaw have a ball on it? (object subtype 00 contains a ball)
		beq.s	.skip 					; yes, skip  
		move.w	a1,(a2)+ 				; no ball, so move object address into the scratch RAM and increment, we are storing pointers to seesaws with no balls

.skip:
		adda.w	#object_size,a1 			; move the pointer forward one object size ($40 bytes, this means scanning all of the lvlobjspace to look for seesaws)
		dbf	d1,BossStarLight_CheckSaws 		; keep looking for saws

BossStarLight_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0 			; load secondary routine index of current object slot into d0
		move.w	BossStarLight_ShipIndex(pc,d0.w),d0 	; use the secondary object routine index and ShipIndex to calculate our offset
		jsr	BossStarLight_ShipIndex(pc,d0.w) 	; jump into the table and use our offset to pick a routine in the index to go to
		lea	(Ani_Eggman).l,a1
		jsr	(AnimateSprite).l
; ---------------------------------------------------------------------------
; obStatus stores the logical bits, but obRender is visual bits, so this simply moves them from one to the other
; ---------------------------------------------------------------------------
		moveq	#3,d0 					; move first 2 bits into d0
		and.b	obStatus(a0),d0 			; AND with obstatus so now d0 contains X and Y logical flip bits only
		andi.b	#$FC,obRender(a0) 			; clear the x and y flip
		or.b	d0,obRender(a0) 			; OR the two together, so now DisplaySprite has X and Y orientation and above render bits
		jmp	(DisplaySprite).l
; ===========================================================================
BossStarLight_ShipIndex:
		dc.w BSLZ_ShipStart-BossStarLight_ShipIndex
		dc.w BSLZ_ShipMove-BossStarLight_ShipIndex
		dc.w BSLZ_MakeBall-BossStarLight_ShipIndex
		dc.w BSLZ_Explode-BossStarLight_ShipIndex
		dc.w BSLZ_Recover-BossStarLight_ShipIndex
		dc.w BSLZ_Escape-BossStarLight_ShipIndex
; ===========================================================================

; loc_189B8:
BSLZ_ShipStart:
		move.w	#-$100,obVelX(a0) 			; start moving to the left
		cmpi.w	#boss_slz_x+$120,obBossX(a0) 		; have we reached our left bound?
		bhs.s	BSLZ_ShipUpdate 			; no, keep moving
		addq.b	#2,ob2ndRout(a0) 			; advance object routine index, so now we go to ShipMove

BSLZ_ShipUpdate:
		bsr.w	BossMove
		move.b	BossStarLight_SineCounter(a0),d0
		addq.b	#2,BossStarLight_SineCounter(a0) 	; increment sine counter by 2 (to iterate through the sine table)
		jsr	(CalcSine).l 				; unlike GHZ, this starts at 2 instead of 0
		asr.w	#6,d0 					; shift right 6 bits (divide by 64), keeping signed number status
		add.w	obBossY(a0),d0 				; offset Y position with sine value
		move.w	d0,obY(a0) 				; set the Y to the "bob" that was calculated
		move.w	obBossX(a0),obX(a0)			; copy X position
		bra.s	BSLZ_StatusUpdate
; ===========================================================================

BSLZ_MoveUpdate:
		bsr.w	BossMove
		move.w	obBossY(a0),obY(a0)
		move.w	obBossX(a0),obX(a0)

BSLZ_StatusUpdate:
		cmpi.b	#6,ob2ndRout(a0) 			; are we exploding?
		bhs.s	.exit 					; yes, exit
		tst.b	obStatus(a0)				; has Eggman's defeated flag been set (bit 7)?
		bmi.s	BSLZ_Defeated				; if yes (negative number) branch
		tst.b	obColType(a0)				; is the boss hittable?
		bne.s	.exit					; if not, leave
		tst.b	obBossFlash(a0)				; is this a non-zero value (collision disabled if so, must mean boss is already flashing)
		bne.s	.flash					; we are flashing already, skip ahead
		move.b	#$20,obBossFlash(a0)			; set number of times to flash
		move.w	#sfx_HitBoss,d0
		jsr	(QueueSound2).l				; play boss damage sound

.flash:
		lea	(v_palette+$22).w,a1 			; load 2nd palette, 2nd entry
		moveq	#0,d0					; move 0 (black) to d0
		tst.w	(a1)        				; is the color here black? This is a cool trick, since tst will set its flags based on if the value is 0. What color is black? All 0s!
		bne.s	.writeColor   				; if not black, already white, so branch
		move.w	#cWhite,d0				; move 0EEE (white) to d0

.writeColor:
		move.w	d0,(a1)					; load color stored in d0
		subq.b	#1,obBossFlash(a0) 			; subtrack 1 from flash timer
		bne.s	.exit 					; keep flashing if obBossFlash is not 0
		move.b	#$F,obColType(a0) 			; restore collision, the timer has hit 0

.exit:
		rts
; ===========================================================================

BSLZ_Defeated:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#6,ob2ndRout(a0)			; set object routine to BSLZ_Recover
		move.b	#$78,BossStarLight_GenericTimer(a0)     ; set the boss timer
		clr.w	obVelX(a0)				; stop moving horizontally
		rts
; ===========================================================================

; loc_18A5E:
BSLZ_ShipMove:
		move.w	obBossX(a0),d0 				; move boss position for later comparison 
		move.w	#$200,obVelX(a0)			; set X velocity (moving right)
		btst	#0,obStatus(a0)				; is our X flipped?
		bne.s	.checkRight				; if yes, branch
		neg.w	obVelX(a0)				; reverse direction
		cmpi.w	#boss_slz_x+8,d0			; have we reached the left bound?
		bgt.s	.dropSetup				; no, keep moving
		bra.s	.flip				; yes, flip
; ===========================================================================

.checkRight:
		cmpi.w	#boss_slz_x+$138,d0			; have we reached this right bound?
		blt.s	.dropSetup				; no, keep moving to the right

.flip:
		bchg	#0,obStatus(a0)				; set X flip bit to 0

.dropSetup:
		move.w	obX(a0),d0				; get current X position
;-----------------------------------------------------------------------------
; This line sets d1 to $FFFFFFFF (2s complement). The reason they do this is because when we looked through the object RAM for the level
; and found seesaws, we only stored their addresses as words, meaning the top 2 bytes were not stored. This may have been to save some RAM, or some cycles, or out of habit. Maybe it was even a macro they had.
; Now, the full address can be rebuilt by adding $FFFF with the lower two bytes that were stored in a2, since that is where it lives in RAM. Up in BossStarLight_CheckSaws, you can store all 32 bits of the address
; using move.l instead of move.w a1,(a2)+ and get rid of some of the lines below if you choose.
; ----------------------------------------------------------------------------
		moveq	#-1,d1					
		moveq	#2,d2					; set number of seesaws to 3
		lea	BossStarLight_SeesawList(a0),a2		; load seesaw list
		moveq	#$28,d4					; set up seesaw pixel offset
		tst.w	obVelX(a0)				; are we moving to the right?
		bpl.s	.findSeesaw				; if yes, skip ahead
		neg.w	d4					; if no, flip to negative. this is the logic that determines what side of the seesaw the ball is dropped on depending on direction

.findSeesaw:
		move.w	(a2)+,d1				; grab seesaw address and put it into d1
		movea.l	d1,a3					; move seesaw into a3 as a full address
		btst	#3,obStatus(a3)				; is Sonic on this object?
		bne.s	.skip					; if yes, branch
		move.w	obX(a3),d3				; get the x position of the seesaw
		add.w	d4,d3					; add the offset to the seesaw
		sub.w	d0,d3					; remove the boss x
		beq.s	.prepDrop				; are we aligned over the drop point of the seesaw? if yes, branch

.skip:
		dbf	d2,.findSeesaw

		move.b	d2,obSubtype(a0)			; fell through, no seesaw met the conditions, d2 is $FF so store it
		bra.w	BSLZ_ShipUpdate
; ===========================================================================

.prepDrop:
		move.b	d2,obSubtype(a0)			; store whichever seesaw we are over and is valid in a0
		addq.b	#2,ob2ndRout(a0)			; increment routine to MakeBall
		move.b	#$28,BossStarLight_GenericTimer(a0)	; wait $28 frames
		bra.w	BSLZ_ShipUpdate
; ===========================================================================

; BossStarLight_MakeBall:
BSLZ_MakeBall:
		cmpi.b	#$28,BossStarLight_GenericTimer(a0)	; have we waited $28 frames?
		bne.s	.subtractTime				; no, come back later
		moveq	#-1,d0					; set d0 to $FFFFFFFF
		move.b	obSubtype(a0),d0			; move seesaw subtype into d0
		ext.w	d0					; sign extend lower byte of d0 into upper byte (the word)
		bmi.s	.abortDrop				; check bit 15. is there a seesaw here? if so, it would be a non negative value. (potential failsafe?)
		subq.w	#2,d0					; subtract 2 from d0
		neg.w	d0					; negate d0 to get back to a positive value
		add.w	d0,d0					; multiply by 2 to get the correct offset in the seesaw list (since each entry is a word)	
		lea	BossStarLight_SeesawList(a0),a1		; load lists of found and valid seesaws into a1
		move.w	(a1,d0.w),d0				; get the address of the seesaw number we are over by using the index we just made in d0, and put it back in d0
		movea.l	d0,a2					; move the address of the seesaw into a2
	if FixBugs
		lea	(v_lvlobjspace).w,a1			; load level object space address into a1
		moveq	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d1 ; number of objects to scan
	else
		lea	(v_objspace+object_size*1).w,a1 ; Nonsensical starting point, since dynamic object allocations begin at v_lvlobjspace.
		moveq	#(v_objspace_end-(v_objspace+object_size*1))/object_size/2-1,d1	; Nonsensical length, it only covers the first half of object RAM.
	endif

.checkForBall:
		cmp.l	BossStarLight_GenericTimer(a1),d0 	; use same scratch RAM location as timer, however this is for a1 which is level object space and not a0 which is the boss object
		beq.s	.abortDrop				; has any previously scanned object already point to this seesaw address? (on first loop, no! so this won't be true)
		adda.w	#object_size,a1				; move the pointer forward one object size ($40 bytes, this means scanning all of the lvlobjspace to look for seesaws with balls)
		dbf	d1,.checkForBall

		move.l	a0,-(sp)				; store boss object pointer on the stack and decrement (stack goes backwards!)
		lea	(a2),a0					; move seesaw into a0
		jsr	(FindNextFreeObj).l			; now look for a free slot after the seesaw object
		movea.l	(sp)+,a0				; restore boss object pointer and increment stack
		bne.s	.abortDrop				; did we find a free slot from FindNextFreeObj? was the Z flag set by NFree_Loop (beq)? if not, branch
		move.b	#id_BossSpikeball,obID(a1) 		; load spiked ball object
		move.w	obX(a0),obX(a1)				; set x and y of object to x and y of boss
		move.w	obY(a0),obY(a1)
		addi.w	#$20,obY(a1)				; offset y so that it comes out of the ball launcher
		move.b	obStatus(a2),obStatus(a1)		; copy seesaw status to ball
		move.l	a2,BossStarLight_GenericTimer(a1)	; store seesaw's address so that seesaw and ball are now linked

.subtractTime:
		subq.b	#1,BossStarLight_GenericTimer(a0)	; subtract time
		beq.s	.abortDrop				; are we 0? time to start moving again
		bra.w	BSLZ_StatusUpdate
; ===========================================================================

.abortDrop:
		subq.b	#2,ob2ndRout(a0)			; go back in the routine index to ShipMove
		bra.w	BSLZ_ShipUpdate
; ===========================================================================

; loc_18B48:
BSLZ_Explode:
		subq.b	#1,BossStarLight_GenericTimer(a0)	; are we done exploding?
		bmi.s	.transition				; yes, start transitioning to next routine/state (Recover)
		bra.w	BossDefeated
; ===========================================================================

.transition:
		addq.b	#2,ob2ndRout(a0)			; advance routine to Recover
		clr.w	obVelY(a0)				; stop vertical movement
		bset	#0,obStatus(a0)				; set the X flip bit so we are facing right
		bclr	#7,obStatus(a0)				; clear the defeated flag 
		clr.w	obVelX(a0)				; stop horizontal movement
		move.b	#-$18,BossStarLight_GenericTimer(a0)	; set a timer for $18
		tst.b	(v_bossstatus).w			; has boss been marked as defeated?
		bne.s	.skip					; yes, skip
		move.b	#1,(v_bossstatus).w			; no, mark it as defeated but not capsule opened

.skip:
		bra.w	BSLZ_StatusUpdate
; ===========================================================================

; loc_18B80:
BSLZ_Recover:
		addq.b	#1,BossStarLight_GenericTimer(a0)	; increment timer
		beq.s	.doneFalling				; if the timer has hit 0, branch here
		bpl.s	.timerPositive				; if the timer has hit a positive value, branch here
		addi.w	#$18,obVelY(a0)				; make Eggman fall a little faster
		bra.s	.exit					
; ===========================================================================

.doneFalling:
		clr.w	obVelY(a0)				; set velocity to 0, we are done falling
		bra.s	.exit
; ===========================================================================

.timerPositive:
		cmpi.b	#$20,BossStarLight_GenericTimer(a0)	; is the timer below $20?
		blo.s	.rise					; if yes, start to rise
		beq.s	.playMusic				; stop and play music
		cmpi.b	#$2A,BossStarLight_GenericTimer(a0)	; is the timer below $2A
		blo.s	.exit					; if yes, come back later (we are still going to recover)
		addq.b	#2,ob2ndRout(a0)			; increment routine to Escape
		bra.s	.exit					
; ===========================================================================

.rise:
		subq.w	#8,obVelY(a0)				; slow down, eventually causing him to rise upwards (gives a smooth motion)
		bra.s	.exit
; ===========================================================================

.playMusic:
		clr.w	obVelY(a0)				; stop rising
		move.w	#bgm_SLZ,d0
		jsr	(QueueSound1).l				; play SLZ music

.exit:
		bra.w	BSLZ_MoveUpdate
; ===========================================================================

; loc_18BC6:
BSLZ_Escape:
		move.w	#$400,obVelX(a0)			; move to the right quickly
		move.w	#-$40,obVelY(a0)			; move up a little bit
		cmpi.w	#boss_slz_end,(v_limitright2).w		; have we finished scrolling to the right (reached level bounds)?
		bhs.s	.checkOffScreen				; if yes, branch
		addq.w	#2,(v_limitright2).w			; keep unlocking the bounds of the screen by 2 pixels
		bra.s	.flee
; ===========================================================================

.checkOffScreen:
		tst.b	obRender(a0)				; has Eggman left the screen (is bit 7 clear)?
	if FixBugs
		bpl.s	BossStarLight_PopAndDelete		; yes, bit 7 is cleared, so we can delete the object (this is 2's complement related!)
	else
		bpl.w	BossStarLight_Delete			; yes, bit 7 is cleared, so we can delete the object (this is 2's complement related!)
	endif

.flee:
		bsr.w	BossMove
		bra.w	BSLZ_ShipUpdate

	if FixBugs
BossStarLight_PopAndDelete:
		; Avoid returning to BossStarLight_ShipMain to prevent a
		; display-and-delete bug.
		addq.l	#4,sp
		bra.w	BossStarLight_Delete
	endif
; ===========================================================================

BossStarLight_FaceMain:	; Routine 4
		moveq	#0,d0
		moveq	#1,d1					; set facenormal1 animation
		movea.l	BossStarLight_Reference(a0),a1		; load the main boss controller into a1
		move.b	ob2ndRout(a1),d0			; load boss phase into d0
		cmpi.b	#6,d0					; are we in routine Explode or beyond?
		bmi.s	.checkHitState				; if not, boss is active, so branch
		moveq	#$A,d1					; set defeated animation
		bra.s	.writeAnim
; ===========================================================================

.checkHitState:
		tst.b	obColType(a1)				; is the boss currently being hit?
		bne.s	.checkSonicState			; if not, check Sonic's state
		moveq	#5,d1					; set animation to facehit
		bra.s	.writeAnim
; ===========================================================================

.checkSonicState:
		cmpi.b	#4,(v_player+obRoutine).w		; is Sonic currently being hit?
		blo.s	.writeAnim				; if not, branch
		moveq	#4,d1					; set animation to facelaugh

.writeAnim:
		move.b	d1,obAnim(a0)				; move animation state into obAnim
		cmpi.b	#$A,d0					; are we currently in Escape state (d0 contains ob2ndRout from above)?
		bne.s	.skip					; if not, branch
		move.b	#6,obAnim(a0)				; set animation state to facepanic
		tst.b	obRender(a0)				; has Eggman's face left the screen?
		bpl.w	BossStarLight_Delete			; if so, branch

.skip:
		bra.s	BossStarLight_Animate
; ===========================================================================

BossStarLight_FlameMain:; Routine 6
		move.b	#8,obAnim(a0)
		movea.l	BossStarLight_Reference(a0),a1
		cmpi.b	#$A,ob2ndRout(a1)
		bne.s	loc_18C56
		tst.b	obRender(a0)
		bpl.w	BossStarLight_Delete
		move.b	#$B,obAnim(a0)
		bra.s	BossStarLight_Animate
; ===========================================================================

loc_18C56:
		cmpi.b	#8,ob2ndRout(a1)
		bgt.s	BossStarLight_Animate
		cmpi.b	#4,ob2ndRout(a1)
		blt.s	BossStarLight_Animate
		move.b	#7,obAnim(a0)

BossStarLight_Animate:
		lea	(Ani_Eggman).l,a1
		jsr	(AnimateSprite).l

BossStarLight_Display:
		movea.l	BossStarLight_Reference(a0),a1 		; load main boss controller into a1
		move.w	obX(a1),obX(a0)				; move positions to rendered positions of boss
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)		; move object status to boss object status
		moveq	#3,d0 					; move first 2 bits into d0
		and.b	obStatus(a0),d0 			; AND with obstatus so now d0 contains X and Y logical flip bits only
		andi.b	#$FC,obRender(a0) 			; clear the x and y flip
		or.b	d0,obRender(a0) 			; OR the two together, so now DisplaySprite has X and Y orientation and above render bits
		jmp	(DisplaySprite).l
; ===========================================================================

BossStarLight_PipeMain:	; Routine 8
		movea.l	BossStarLight_Reference(a0),a1		; load main boss controller into a1
		cmpi.b	#$A,ob2ndRout(a1)			; are we currently in Escape state?
		bne.s	.skip					; if not, branch
		tst.b	obRender(a0)				; has the widepipe left the screen?
		bpl.w	BossStarLight_Delete			; if so, branch

.skip:
		move.l	#Map_BossItems,obMap(a0)		; load item mappings
		move.w	#ArtTile_Eggman_Weapons|Tile_Pal2,obGfx(a0)	; load weapons and pick the palette line
		move.b	#3,obFrame(a0)				; set frame to widepipe (SLZ boss weapon, found in Boss Items.asm)
		bra.s	BossStarLight_Display
