; ===========================================================================
; ---------------------------------------------------------------------------
; When Debug Mode is currently in use (entered from Sonic objects)
; ---------------------------------------------------------------------------
debug_movedelay:  equ 12	; frames to wait when holding down D-Pad before starting to move
debug_startspeed: equ 15	; inital movement speed when first holding D-Pad
; ---------------------------------------------------------------------------

DebugMode:
		moveq	#0,d0					; clear d0
		move.b	(v_debuguse).w,d0			; get debug mode state (0 if just launched, 2 if already active)
		move.w	Debug_Index(pc,d0.w),d1			; find relevant section in offset table
		jmp	Debug_Index(pc,d1.w)			; jump to that label
; ===========================================================================
Debug_Index:	dc.w Debug_Init-Debug_Index			; 0 - init
		dc.w Debug_Action-Debug_Index			; 2 - main mode
; ===========================================================================

; Debug_Main:
Debug_Init:	; Routine 0
		addq.b	#2,(v_debuguse).w			; set to Debug_Action

		move.w	(v_limittop2).w,(v_limittopdb).w	; buffer level x-boundary
		move.w	(v_limitbtm1).w,(v_limitbtmdb).w	; buffer level y-boundary
		move.w	#0,(v_limittop2).w			; unlock top screen boundary
		move.w	#$800-224,(v_limitbtm1).w		; unlock bottom level boundary, minus screen height

		; Do vertical wrapping in LZ3 and SBZ2
		andi.w	#$7FF,(v_player+obY).w			; wrap Sonic's Y-position
		andi.w	#$7FF,(v_screenposy).w			; wrap screen Y-position
		andi.w	#$3FF,(v_bgscreenposy).w		; wrap background Y-position

		move.b	#fr_Null,obFrame(a0)			; set Sonic's frame to null (blank)
		move.b	#id_Walk,obAnim(a0)			; set Sonic's animation to null (walk)

		cmpi.b	#id_Special,(v_gamemode).w		; is game mode $10 (special stage)?
		bne.s	.isLevel				; if not, branch
		move.w	#0,(v_ssrotate).w			; stop special stage rotating
		move.w	#0,(v_ssangle).w			; make special stage "upright"
		moveq	#id_EndZ,d0				; use 6th debug item list (which is actually the ending sequence)
		bra.s	.loadDebugList				; ignore actual Zone ID
; ===========================================================================

	.isLevel:
		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; get current Zone ID
	.loadDebugList:
		lea	(DebugList).l,a2			; load debug item index list
		add.w	d0,d0					; double for word-based indexing
		adda.w	(a2,d0.w),a2				; go to debug item list for Zone ID
		move.w	(a2)+,d6				; load number of entries in debug item list
		cmp.b	(v_debugitem).w,d6			; is currently selected item index past end of list?
		bhi.s	.finishDebugSetup			; if not, branch
		move.b	#0,(v_debugitem).w			; go back to start of list

	.finishDebugSetup:
		bsr.w	Debug_ShowItem				; load selected item graphics when entering debug mode
		move.b	#debug_movedelay,(v_debugspeedtimer).w	; set initial move delay (12 frames)
	if FixBugs
		; If the D-Pad is held while entering debug mode, the initial move speed
		; is incredibly slow. The cause is this value getting set to just a 1,
		; instead of the normal 15 when no D-Pad button is pressed in Debug_Control.
		move.b	#debug_startspeed,(v_debugspeed).w	; set inital move speed (normal 15)
	else
		move.b	#1,(v_debugspeed).w			; set inital move speed (just 1)
	endif
; ---------------------------------------------------------------------------

Debug_Action:	; Routine 2
		moveq	#id_EndZ,d0				; use 6th debug item list (which is actually the ending sequence)
		cmpi.b	#id_Special,(v_gamemode).w		; are we in a special stage?
		beq.s	.loadDebugList				; if yes, branch

		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; use Zone ID as debug list
	.loadDebugList:
		lea	(DebugList).l,a2			; load debug item index list
		add.w	d0,d0					; double for word-based indexing
		adda.w	(a2,d0.w),a2				; go to debug item list for Zone ID
		move.w	(a2)+,d6				; load number of entries in debug item list

		bsr.w	Debug_Control				; allow movement and spawning objects, and update graphics
		jmp	(DisplaySprite).l			; display debug object
; End of function DebugMode


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to allow movement in debug mode, spawning objects,
; and updating displayed debug object sprite graphics.
; ---------------------------------------------------------------------------

Debug_Control:
		moveq	#0,d4					; clear d4 for button input buffer
		move.w	#1,d1					; clear d1 (redundant, cleared again below)

		move.b	(v_jpadpress1).w,d4			; get buttons that were pressed this frame
		andi.w	#btnDir,d4				; is up/down/left/right pressed?
		bne.s	Debug_Move_GetDirections		; if yes, branch (immediately move a bit)

		move.b	(v_jpadhold1).w,d0			; get buttons that were already held down
		andi.w	#btnDir,d0				; is up/down/left/right held?
		bne.s	Debug_Move_Delay			; if yes, branch

		; No D-Pad buttons were pressed...
		move.b	#debug_movedelay,(v_debugspeedtimer).w	; reset movement delay
		move.b	#debug_startspeed,(v_debugspeed).w	; reset initial move speed
		bra.w	Debug_ChgItem				; skip movement

; ---------------------------------------------------------------------------
; Allow freely moving around in debug mode
; ---------------------------------------------------------------------------

Debug_Move_Delay:
		subq.b	#1,(v_debugspeedtimer).w		; decrement delay for held buttons before moving
		bne.s	Debug_Move				; if time remains, branch
		move.b	#1,(v_debugspeedtimer).w		; keep delay to 1 so that the above branch keeps triggering
		addq.b	#1,(v_debugspeed).w			; accelerate speed for held D-Pad
		bne.s	Debug_Move_GetDirections		; if speed didn't reach max yet, branch
		move.b	#$FF,(v_debugspeed).w			; keep speed fixed at max until D-Pad is released again

Debug_Move_GetDirections:
		move.b	(v_jpadhold1).w,d4			; get held button presses for the directional checks

Debug_Move:
		moveq	#0,d1					; clear d1
		move.b	(v_debugspeed).w,d1			; get current debug move speed
		addq.w	#1,d1					; add one unit to base speed (at max speed, $FF+1=$100)
		swap	d1					; move delta to upper word (calcuations use longwords for subpixels)
		asr.l	#4,d1					; divide speed by 16 to reasonably slow it down (upper nybble is pixels per seconds)

		move.l	obY(a0),d2				; d2 = current debug object Y-position
		move.l	obX(a0),d3				; d3 = current debug object X-position

.chkUp:
		btst	#bitUp,d4				; is up being held?
		beq.s	.chkDown				; if not, branch
		sub.l	d1,d2					; move up
	if FixBugs
		; These boundary checks only consider absolute values, which allows going offscreen.
		; From Sonic 2 onward, the active level boundaries are instead used for the checks.
		; Left/right bounds technically lack those fixes, they were added here for consistency.
		moveq	#0,d0					; clear d0
		move.w	(v_limittop2).w,d0			; get current top level boundary
		swap	d0					; move to upper word for long comparison
		cmp.l	d0,d2					; would new Y-position exceed top level boundary?
		bge.s	.chkDown				; if not, branch
		move.l	d0,d2					; keep Y-position within top level bound
	else
		bcc.s	.chkDown				; would new Y-position underflow? if not, branch
		moveq	#0,d2					; keep Y-position within absolute top bound
	endif

.chkDown:
		btst	#bitDn,d4				; is down being held?
		beq.s	.chkLeft				; if not, branch
		add.l	d1,d2					; move down
	if FixBugs
		; See above.
		moveq	#0,d0					; clear d0
		move.w	(v_limitbtm2).w,d0			; get current bottom level boundary
		addi.w	#224-1,d0				; add screen height
		swap	d0					; move to upper word for long comparison
		cmp.l	d0,d2					; would new Y-position exceed bottom level boundary?
		blt.s	.chkLeft				; if not, branch
		move.l	d0,d2					; keep Y-position within bottom level bound
	else
		cmpi.l	#$7FF<<16,d2				; would new Y-position exceed maximum bottom?
		blo.s	.chkLeft				; if not, branch
		move.l	#$7FF<<16,d2				; keep Y-position within bottom bound
	endif

.chkLeft:
		btst	#bitL,d4				; is left being held?
		beq.s	.chkRight				; if not, branch
		sub.l	d1,d3					; move left
	if FixBugs
		; See above.
		moveq	#0,d0					; clear d0
		move.w	(v_limitleft2).w,d0			; get current left level boundary
		swap	d0					; move to upper word for long comparison
		cmp.l	d0,d3					; would new X-position exceed left level boundary?
		bge.s	.chkRight				; if not, branch
		move.l	d0,d3					; keep X-position within left level bound
	else
		bcc.s	.chkRight				; would new X-position underflow? if not, branch
		moveq	#0,d3					; keep X-position within absolute left bound
	endif

.chkRight:
		btst	#bitR,d4				; is right being held?
		beq.s	.setNewDebugPosition			; if not, branch
		add.l	d1,d3					; move right
	if FixBugs
		; See above. Also, right side lacked any boundary check to begin with.
		moveq	#0,d0					; clear d0
		move.w	(v_limitright2),d0			; get current right level boundary
		addi.w	#320-1,d0				; add screen width
		swap	d0					; move to upper word for long comparison
		cmp.l	d0,d3					; would new X-position exceed right level boundary?
		blt.s	.setNewDebugPosition			; if not, branch
		move.l	d0,d3					; keep X-position within right level bound
	endif

.setNewDebugPosition:
		move.l	d2,obY(a0)				; set new Y-position
		move.l	d3,obX(a0)				; set new X-position
		; continue to Debug_ChgItem...

; ---------------------------------------------------------------------------
; Allow spawning debug objects and cycling through item list
; ---------------------------------------------------------------------------

Debug_ChgItem:
		; Cycle back one item in list when holding A and pressing C
		btst	#bitA,(v_jpadhold1).w			; is button A held?
		beq.s	.checkCreateItem			; if not, branch
		btst	#bitC,(v_jpadpress1).w			; is button C pressed?
		beq.s	.checkNextItem				; if not, branch
		subq.b	#1,(v_debugitem).w			; go back 1 item
		bcc.s	.display				; if still a valid index, branch
		add.b	d6,(v_debugitem).w			; on underflow, set to last entry in list
		bra.s	.display				; do not spawn an item from this C press
; ===========================================================================

	.checkNextItem:
		; Cycle forwards one item in list when pressing A
		btst	#bitA,(v_jpadpress1).w			; is button A pressed?
		beq.s	.checkCreateItem			; if not, branch
		addq.b	#1,(v_debugitem).w			; go forwards 1 item
		cmp.b	(v_debugitem).w,d6			; is newly selected item index past end of list?
		bhi.s	.display				; if not, branch
		move.b	#0,(v_debugitem).w			; go back to start of list

	.display:
		bra.w	Debug_ShowItem				; update displayed sprite for debug object
; ===========================================================================

.checkCreateItem:
		; Spawn new object when pressing C
		btst	#bitC,(v_jpadpress1).w			; is button C pressed?
		beq.s	Debug_ExitDebugMode			; if not, branch

		jsr	(FindFreeObj).l				; find a free object slot
		bne.s	Debug_ExitDebugMode			; if none are free, branch
	if FixBugs
		; Fix not being able to place more rings and such after collecting one
		clr.b	(v_objstate+2).w			; free up object state for spawned object (target for obRespawnNo=0)
	endif
		move.w	obX(a0),obX(a1)				; set new object's X-position
		move.w	obY(a0),obY(a1)				; set new object's X-position
		_move.b	obMap(a0),obID(a1)			; create object (ID is stored in list with mappings as map+(object<<24))
		move.b	obRender(a0),obRender(a1)		; set new object's render flags
		move.b	obRender(a0),obStatus(a1)		; set new object's status flags
		andi.b	#$7F,obStatus(a1)			; make sure bit 7 in status flag is clear

		moveq	#0,d0					; clear d0
		move.b	(v_debugitem).w,d0			; get index of currently selected debug item
		lsl.w	#3,d0					; each entry is 8 bytes
		move.b	4(a2,d0.w),obSubtype(a1)		; load subtype for object from debug list entry

		rts						; return

; ---------------------------------------------------------------------------
; Allow exiting debug mode to revert back to normal Sonic state
; ---------------------------------------------------------------------------

Debug_ExitDebugMode:
		btst	#bitB,(v_jpadpress1).w			; is button B pressed?
		beq.s	.return					; if not, stay in debug mode

		moveq	#0,d0					; prepare 0 value
		move.w	d0,(v_debuguse).w			; deactivate debug mode
		move.l	#Map_Sonic,(v_player+obMap).w		; reset Sonic's mappings
		move.w	#ArtTile_Sonic,(v_player+obGfx).w	; reset Sonic's art tile
		move.b	d0,(v_player+obAnim).w			; reset Sonic's animation to walking
		move.w	d0,obSubpixelX(a0)			; clear Sonic's X subpixel portion
		move.w	d0,obSubpixelY(a0)			; clear Sonic's Y subpixel portion

		move.w	(v_limittopdb).w,(v_limittop2).w	; restore top level boundary
		move.w	(v_limitbtmdb).w,(v_limitbtm1).w	; restore bottom level boundary

		cmpi.b	#id_Special,(v_gamemode).w		; are you in the special stage?
		bne.s	.return					; if not, branch
		clr.w	(v_ssangle).w				; make special stage "upright"
		move.w	#ss_rotatespeed,(v_ssrotate).w		; restart maze rotation
		move.l	#Map_Sonic,(v_player+obMap).w		; reset Sonic's mappings (redundant, already done)
		move.w	#ArtTile_Sonic,(v_player+obGfx).w	; reset Sonic's art tile (redundant, already done)
		move.b	#id_Roll,(v_player+obAnim).w		; reset Sonic's animation to rolling
		bset	#2,(v_player+obStatus).w		; force rolling state
		bset	#1,(v_player+obStatus).w		; force in-air state

	.return:
		rts						; return
; End of function Debug_Control


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to set mappings and graphics for displayed debug object.
; Each entry in DebugList is 8 bytes in the following format:
; 	0:   object ID
;	0-3: mappings address (upper byte is ignored for 24-bit addressing)
;	4:   subtype
;	5:   frame ID
;	6-7: VRAM settings
; ---------------------------------------------------------------------------

Debug_ShowItem:
		moveq	#0,d0					; clear d0
		move.b	(v_debugitem).w,d0			; get currently selected item in debug list
		lsl.w	#3,d0					; each entry is 8 bytes
		move.l	(a2,d0.w),obMap(a0)			; load mappings for displayed item
		move.w	6(a2,d0.w),obGfx(a0)			; load VRAM setting for displayed item
		move.b	5(a2,d0.w),obFrame(a0)			; load frame number for displayed item
		rts						; return
; End of function Debug_ShowItem
