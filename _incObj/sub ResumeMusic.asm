; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to play music for LZ/SBZ3 after a countdown
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


ResumeMusic:
		cmpi.w	#12,(v_air).w	; more than 12 seconds of air left?
		bhi.s	.over12		; if yes, branch
		move.w	#bgm_LZ,d0	; play LZ music
		cmpi.w	#id_LZ_act4,(v_zone).w ; check if level is SBZ3 (LZ4)
		bne.s	.notsbz
		move.w	#bgm_SBZ,d0	; play SBZ music

.notsbz:
	if Revision<>0
		tst.b	(v_invinc).w ; is Sonic invincible?
		beq.s	.notinvinc ; if not, branch
		move.w	#bgm_Invincible,d0
.notinvinc:
		tst.b	(f_lockscreen).w ; is Sonic at a boss?
		beq.s	.playselected ; if not, branch
		move.w	#bgm_Boss,d0
.playselected:
	endif

		jsr	(QueueSound1).l

.over12:
		move.w	#30,(v_air).w	; reset air to 30 seconds
		clr.b	(v_sonicbubbles+objoff_32).w
		rts
; End of function ResumeMusic

; ===========================================================================