; ---------------------------------------------------------------------------
; Subroutine to load basic level data
; ---------------------------------------------------------------------------

LevelDataLoad:
	; --- Load Level Header ---
		moveq	#0,d0
		move.b	(v_zone).w,d0			; get zone ID to load
		lsl.w	#4,d0				; multiply by $10 (size per level header entry)
		lea	(LevelHeaders).l,a2
		lea	(a2,d0.w),a2			; advance to level header for current zone
		move.l	a2,-(sp)			; remember header address for later
		addq.l	#4,a2				; skip 1st PLC and level gfx entry (handled in GM_Level)

	; --- 16x16 Block Mappings ---
		movea.l	(a2)+,a0			; get 16x16 data pointer from level header
		lea	(v_16x16).w,a1			; set target RAM buffer for 16x16 mappings
		move.w	#ArtTile_Level,d0		; set base art tile (0)
		bsr.w	EniDec				; decompress Enigma-compresseed block data to buffer

	; --- 128x128 Chunk Mappings ---
		movea.l	(a2)+,a0			; get 128x128 chunk data pointer from level header
		lea	(v_128x128).l,a1		; set target RAM buffer for 128x128 mappings
		bsr.w	KosDec				; decompress Kosinski-compressed chunk data to buffer

	; --- Level Layout (FG/BG) ---
		bsr.w	LevelLayoutLoad			; load FG and BG layout

	; --- Music (unused) ---
		move.w	(a2)+,d0			; load music (unused)

	; --- Palette ---
		move.w	(a2),d0				; load palette ID
		andi.w	#$FF,d0				; only use lower byte (palette ID is duplicated in headers)

		cmpi.w	#id_LZ_act4,(v_zone_act).w	; is level SBZ3 (LZ4)?
		bne.s	.notSBZ3			; if not, branch
		moveq	#palid_SBZ3,d0			; use SB3 palette instead
	.notSBZ3:
		cmpi.w	#id_SBZ_act2,(v_zone_act).w	; is level SBZ2?
		beq.s	.isSBZorFZ			; if yes, branch
		cmpi.w	#id_FZ,(v_zone_act).w		; is level FZ?
		bne.s	.normalpal			; if not, branch
	.isSBZorFZ:
		moveq	#palid_SBZ2,d0			; use SBZ2/FZ palette instead
	.normalpal:
		bsr.w	PalLoad_Fade			; load specified palette into fade-in buffer

	; --- 2nd PLC ---
		movea.l	(sp)+,a2			; restore base level header pointer
		addq.w	#4,a2				; advance to 2nd PLC entry
		moveq	#0,d0
		move.b	(a2),d0				; load 2nd PLC entry from level headers
		beq.s	.skipPLC			; if 2nd PLC is 0 (i.e. the ending sequence), branch
		bsr.w	AddPLC				; load secondary pattern load cues
	.skipPLC:
		rts					; return
; End of function LevelDataLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Level layout loading subroutine
; ---------------------------------------------------------------------------

LevelLayoutLoad:
		move.w	(v_zone_act).w,d0		; get current zone and act
		lsl.b	#6,d0				; shift only act byte
		lsr.w	#5,d0				; d0 = pointer for current level in Level_Index
		lea	(Level_Index).l,a0		; get layout index
		move.w	(a0,d0.w),d0			; advance to desired layout pointer in index
		lea	(a0,d0.w),a0			; load layout pointer from index
		lea	(v_lvllayout).w,a1		; MJ: FG and BG rows are interlaced $80 bytes each
		bra.w	KosDec				; MJ: decompress layout
; End of function LevelLayoutLoad
