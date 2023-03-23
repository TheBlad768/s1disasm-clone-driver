; ---------------------------------------------------------------------------
; SFX metadata (pointers, priorities, flags)

; Priority of sound. New music or SFX must have a priority higher than or equal
; to what is stored in v_sndprio or it won't play. If bit 7 of new priority is
; set ($80 and up), the new music or SFX will not set its priority -- meaning
; any music or SFX can override it (as long as it can override whatever was
; playing before). Usually, SFX will only override SFX, special SFX ($D0-$DF)
; will only override special SFX and music will only override music.
; Of course, this isn't the case anymore, as priorities no longer apply to
; special SFX or music.
; TODO Maybe I should make it apply to Special SFX, too.
; ---------------------------------------------------------------------------
; SoundTypes: SoundPriorities:
SoundIndex:
ptr_sndA0:	SMPS_SFX_METADATA	SoundA0, $80, 0
ptr_sndA1:	SMPS_SFX_METADATA	SoundA1, $70, 0
ptr_sndA2:	SMPS_SFX_METADATA	SoundA2, $70, 0
ptr_sndA3:	SMPS_SFX_METADATA	SoundA3, $70, 0
ptr_sndA4:	SMPS_SFX_METADATA	SoundA4, $70, 0
ptr_sndA5:	SMPS_SFX_METADATA	SoundA5, $70, 0
ptr_sndA6:	SMPS_SFX_METADATA	SoundA6, $70, 0
ptr_sndA7:	SMPS_SFX_METADATA	SoundA7, $70, 0
ptr_sndA8:	SMPS_SFX_METADATA	SoundA8, $70, 0
ptr_sndA9:	SMPS_SFX_METADATA	SoundA9, $70, 0
ptr_sndAA:	SMPS_SFX_METADATA	SoundAA, $68, 0
ptr_sndAB:	SMPS_SFX_METADATA	SoundAB, $70, 0
ptr_sndAC:	SMPS_SFX_METADATA	SoundAC, $70, 0
ptr_sndAD:	SMPS_SFX_METADATA	SoundAD, $70, 0
ptr_sndAE:	SMPS_SFX_METADATA	SoundAE, $60, 0
ptr_sndAF:	SMPS_SFX_METADATA	SoundAF, $70, 0
ptr_sndB0:	SMPS_SFX_METADATA	SoundB0, $70, 0
ptr_sndB1:	SMPS_SFX_METADATA	SoundB1, $60, 0
ptr_sndB2:	SMPS_SFX_METADATA	SoundB2, $70, 0
ptr_sndB3:	SMPS_SFX_METADATA	SoundB3, $60, 0
ptr_sndB4:	SMPS_SFX_METADATA	SoundB4, $70, 0
ptr_sndB5:	SMPS_SFX_METADATA	SoundB5, $70, 0
ptr_sndB6:	SMPS_SFX_METADATA	SoundB6, $70, 0
ptr_sndB7:	SMPS_SFX_METADATA	SoundB7, $70, 0
ptr_sndB8:	SMPS_SFX_METADATA	SoundB8, $70, 0
ptr_sndB9:	SMPS_SFX_METADATA	SoundB9, $70, 0
ptr_sndBA:	SMPS_SFX_METADATA	SoundBA, $70, 0
ptr_sndBB:	SMPS_SFX_METADATA	SoundBB, $70, 0
ptr_sndBC:	SMPS_SFX_METADATA	SoundBC, $70, 0
ptr_sndBD:	SMPS_SFX_METADATA	SoundBD, $70, 0
ptr_sndBE:	SMPS_SFX_METADATA	SoundBE, $70, 0
ptr_sndBF:	SMPS_SFX_METADATA	SoundBF, $7F, 0
ptr_sndC0:	SMPS_SFX_METADATA	SoundC0, $60, 0
ptr_sndC1:	SMPS_SFX_METADATA	SoundC1, $70, 0
ptr_sndC2:	SMPS_SFX_METADATA	SoundC2, $70, 0
ptr_sndC3:	SMPS_SFX_METADATA	SoundC3, $70, 0
ptr_sndC4:	SMPS_SFX_METADATA	SoundC4, $70, 0
ptr_sndC5:	SMPS_SFX_METADATA	SoundC5, $70, 0
ptr_sndC6:	SMPS_SFX_METADATA	SoundC6, $70, 0
ptr_sndC7:	SMPS_SFX_METADATA	SoundC7, $70, 0
ptr_sndC8:	SMPS_SFX_METADATA	SoundC8, $70, 0
ptr_sndC9:	SMPS_SFX_METADATA	SoundC9, $70, 0
ptr_sndCA:	SMPS_SFX_METADATA	SoundCA, $70, 0
ptr_sndCB:	SMPS_SFX_METADATA	SoundCB, $70, 0
ptr_sndCC:	SMPS_SFX_METADATA	SoundCC, $70, 0
ptr_sndCD:	SMPS_SFX_METADATA	SoundCD, $70, 0
ptr_sndCE:	SMPS_SFX_METADATA	SoundCE, $70, 0
ptr_sndCF:	SMPS_SFX_METADATA	SoundCF, $70, 0
ptr_sndend

; ---------------------------------------------------------------------------
; SFX data
; ---------------------------------------------------------------------------
SoundA0:	include	"Sound/SFX/SndA0 - Jump.asm"
		even
SoundA1:	include	"Sound/SFX/SndA1 - Lamppost.asm"
		even
SoundA2:	include	"Sound/SFX/SndA2.asm"
		even
SoundA3:	include	"Sound/SFX/SndA3 - Death.asm"
		even
SoundA4:	include	"Sound/SFX/SndA4 - Skid.asm"
		even
SoundA5:	include	"Sound/SFX/SndA5.asm"
		even
SoundA6:	include	"Sound/SFX/SndA6 - Hit Spikes.asm"
		even
SoundA7:	include	"Sound/SFX/SndA7 - Push Block.asm"
		even
SoundA8:	include	"Sound/SFX/SndA8 - SS Goal.asm"
		even
SoundA9:	include	"Sound/SFX/SndA9 - SS Item.asm"
		even
SoundAA:	include	"Sound/SFX/SndAA - Splash.asm"
		even
SoundAB:	include	"Sound/SFX/SndAB.asm"
		even
SoundAC:	include	"Sound/SFX/SndAC - Hit Boss.asm"
		even
SoundAD:	include	"Sound/SFX/SndAD - Get Bubble.asm"
		even
SoundAE:	include	"Sound/SFX/SndAE - Fireball.asm"
		even
SoundAF:	include	"Sound/SFX/SndAF - Shield.asm"
		even
SoundB0:	include	"Sound/SFX/SndB0 - Saw.asm"
		even
SoundB1:	include	"Sound/SFX/SndB1 - Electric.asm"
		even
SoundB2:	include	"Sound/SFX/SndB2 - Drown Death.asm"
		even
SoundB3:	include	"Sound/SFX/SndB3 - Flamethrower.asm"
		even
SoundB4:	include	"Sound/SFX/SndB4 - Bumper.asm"
		even
SoundB5:	include	"Sound/SFX/SndB5 - Ring.asm"
		even
SoundB6:	include	"Sound/SFX/SndB6 - Spikes Move.asm"
		even
SoundB7:	include	"Sound/SFX/SndB7 - Rumbling.asm"
		even
SoundB8:	include	"Sound/SFX/SndB8.asm"
		even
SoundB9:	include	"Sound/SFX/SndB9 - Collapse.asm"
		even
SoundBA:	include	"Sound/SFX/SndBA - SS Glass.asm"
		even
SoundBB:	include	"Sound/SFX/SndBB - Door.asm"
		even
SoundBC:	include	"Sound/SFX/SndBC - Teleport.asm"
		even
SoundBD:	include	"Sound/SFX/SndBD - ChainStomp.asm"
		even
SoundBE:	include	"Sound/SFX/SndBE - Roll.asm"
		even
SoundBF:	include	"Sound/SFX/SndBF - Get Continue.asm"
		even
SoundC0:	include	"Sound/SFX/SndC0 - Basaran Flap.asm"
		even
SoundC1:	include	"Sound/SFX/SndC1 - Break Item.asm"
		even
SoundC2:	include	"Sound/SFX/SndC2 - Drown Warning.asm"
		even
SoundC3:	include	"Sound/SFX/SndC3 - Giant Ring.asm"
		even
SoundC4:	include	"Sound/SFX/SndC4 - Bomb.asm"
		even
SoundC5:	include	"Sound/SFX/SndC5 - Cash Register.asm"
		even
SoundC6:	include	"Sound/SFX/SndC6 - Ring Loss.asm"
		even
SoundC7:	include	"Sound/SFX/SndC7 - Chain Rising.asm"
		even
SoundC8:	include	"Sound/SFX/SndC8 - Burning.asm"
		even
SoundC9:	include	"Sound/SFX/SndC9 - Hidden Bonus.asm"
		even
SoundCA:	include	"Sound/SFX/SndCA - Enter SS.asm"
		even
SoundCB:	include	"Sound/SFX/SndCB - Wall Smash.asm"
		even
SoundCC:	include	"Sound/SFX/SndCC - Spring.asm"
		even
SoundCD:	include	"Sound/SFX/SndCD - Switch.asm"
		even
SoundCE:	include	"Sound/SFX/SndCE - Ring Left Speaker.asm"
		even
SoundCF:	include	"Sound/SFX/SndCF - Signpost.asm"
		even
