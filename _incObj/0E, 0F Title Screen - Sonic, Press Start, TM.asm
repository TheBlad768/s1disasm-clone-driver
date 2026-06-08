; ---------------------------------------------------------------------------
; Object 0E - Sonic on the title screen
; ---------------------------------------------------------------------------

TitleSonic:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TSon_Index(pc,d0.w),d1
		jmp	TSon_Index(pc,d1.w)
; ===========================================================================
TSon_Index:	dc.w TSon_Main-TSon_Index
		dc.w TSon_Delay-TSon_Index
		dc.w TSon_Move-TSon_Index
		dc.w TSon_Animate-TSon_Index
; ===========================================================================

TSon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
	if FixBugs
		; Fix title screen position
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_Title_Screen_position_in_Sonic_1
		move.w	#$F0+8,obX(a0)
	else
		move.w	#$F0,obX(a0)
	endif
		move.w	#$DE,obScreenY(a0) ; position is fixed to screen
		move.l	#Map_TSon,obMap(a0)
		move.w	#ArtTile_Title_Sonic|Tile_Pal2,obGfx(a0)
		move.b	#1,obPriority(a0)
		move.b	#29,obDelayAni(a0) ; set time delay to 0.5 seconds
		lea	(Ani_TSon).l,a1
		bsr.w	AnimateSprite

TSon_Delay:	;Routine 2
		subq.b	#1,obDelayAni(a0) ; subtract 1 from time delay
		bpl.s	.wait		; if time remains, branch
		addq.b	#2,obRoutine(a0) ; go to next routine
		bra.w	DisplaySprite

.wait:
		rts
; ===========================================================================

TSon_Move:	; Routine 4
		subq.w	#8,obScreenY(a0) ; move Sonic up
		cmpi.w	#$96,obScreenY(a0) ; has Sonic reached final position?
		bne.s	.display	; if not, branch
		addq.b	#2,obRoutine(a0)

.display:
		bra.w	DisplaySprite
		rts	; redundant rts
; ===========================================================================

TSon_Animate:	; Routine 6
		lea	(Ani_TSon).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
		rts	; redundant rts


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0F - "PRESS START BUTTON", "TM", and masking sprites on title screen
; ---------------------------------------------------------------------------

PSBTM:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	PSB_Index(pc,d0.w),d1
		jsr	PSB_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
PSB_Index:	dc.w PSB_Main-PSB_Index
		dc.w PSB_PrsStart-PSB_Index
		dc.w PSB_Exit-PSB_Index
; ===========================================================================

PSB_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
	if FixBugs
		; Fix title screen position
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_Title_Screen_position_in_Sonic_1
		move.w	#$D0+8,obX(a0)
	else
		move.w	#$D0,obX(a0)
	endif
		move.w	#$130,obScreenY(a0)
		move.l	#Map_PSB,obMap(a0)
		move.w	#ArtTile_Title_Foreground,obGfx(a0)
		cmpi.b	#2,obFrame(a0)	; is object "PRESS START"?
		blo.s	PSB_PrsStart	; if yes, branch

		addq.b	#2,obRoutine(a0)
		cmpi.b	#3,obFrame(a0)	; is the object "TM"?
		bne.s	PSB_Exit	; if not, branch

		move.w	#ArtTile_Title_Trademark|Tile_Pal2,obGfx(a0) ; "TM" specific code
	if FixBugs
		; Fix title screen position
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_Title_Screen_position_in_Sonic_1
		move.w	#$170+8,obX(a0)
	else
		move.w	#$170,obX(a0)
	endif
		move.w	#$F8,obScreenY(a0)

PSB_Exit:	; Routine 4
		rts
; ===========================================================================

PSB_PrsStart:	; Routine 2
		lea	(Ani_PSBTM).l,a1
		bra.w	AnimateSprite	; "PRESS START" is animated
; ===========================================================================

		include	"_anim/Title Screen Sonic.asm"
		include	"_anim/Press Start and TM.asm"

		include	"_incObj/sub AnimateSprite.asm"	; mixed in here, this was probably the first use of it

Map_PSB:	include	"_maps/Press Start and TM.asm"
Map_TSon:	include	"_maps/Title Screen Sonic.asm"
