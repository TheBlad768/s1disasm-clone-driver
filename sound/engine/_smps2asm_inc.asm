; =============================================================================================
; Created by Flamewing, based on S1SMPS2ASM version 1.1 by Marc Gordon (AKA Cinossu)
; =============================================================================================
; This modification supports the Sonic 2 Clone Driver v2, and strips out support for all other drivers

SMPS2ASMVer	= 1

; PSG conversion to S3/S&K/S3D drivers require a tone shift of 12 semi-tones.
psgdelta	EQU 12
; ---------------------------------------------------------------------------------------------
; Standard Octave Pitch Equates

enum macro val
current_val	set \1
	rept narg-1
	shift
\1	equ current_val
current_val	set current_val+enumconf
	endr
	endm

nextenum macro
	rept narg
\1	equ current_val
current_val	set current_val+enumconf
	shift
	endr
	endm

	enumconf:	= $C
	enum	$88,smpsPitch10lo,smpsPitch09lo,smpsPitch08lo,smpsPitch07lo,smpsPitch06lo
	nextenum	smpsPitch05lo,smpsPitch04lo,smpsPitch03lo,smpsPitch02lo,smpsPitch01lo
	enum	$00,smpsPitch00,smpsPitch01hi,smpsPitch02hi,smpsPitch03hi,smpsPitch04hi
	nextenum	smpsPitch05hi,smpsPitch06hi,smpsPitch07hi,smpsPitch08hi,smpsPitch09hi
	nextenum	smpsPitch10hi
; ---------------------------------------------------------------------------------------------
; Note Equates

	enumconf:	= 1
	enum	$80,nRst
	nextenum	nC0,nCs0,nD0,nDs0,nE0,nEs0,nFs0,nG0,nGs0,nA0,nAs0,nB0,nBs0
	nextenum	nCs1,nD1,nDs1,nE1,nEs1,nFs1,nG1,nGs1,nA1,nAs1,nB1,nBs1
	nextenum	nCs2,nD2,nDs2,nE2,nEs2,nFs2,nG2,nGs2,nA2,nAs2,nB2,nBs2
	nextenum	nCs3,nD3,nDs3,nE3,nEs3,nFs3,nG3,nGs3,nA3,nAs3,nB3,nBs3
	nextenum	nCs4,nD4,nDs4,nE4,nEs4,nFs4,nG4,nGs4,nA4,nAs4,nB4,nBs4
	nextenum	nCs5,nD5,nDs5,nE5,nEs5,nFs5,nG5,nGs5,nA5,nAs5,nB5,nBs5
	nextenum	nCs6,nD6,nDs6,nE6,nEs6,nFs6,nG6,nGs6,nA6,nAs6,nB6,nBs6
	nextenum	nCs7,nD7,nDs7,nE7,nEs7,nFs7,nG7,nGs7,nA7,nAs7
; ---------------------------------------------------------------------------------------------
; Extra Note Equates

nDb0				EQU nCs0
nEb0				EQU nDs0
nFb0				EQU nE0
nF0				EQU nEs0
nGb0				EQU nFs0
nAb0				EQU nGs0
nBb0				EQU nAs0
nCb1				EQU nB0
nC1				EQU nBs0
nDb1				EQU nCs1
nEb1				EQU nDs1
nFb1				EQU nE1
nF1				EQU nEs1
nGb1				EQU nFs1
nAb1				EQU nGs1
nBb1				EQU nAs1
nCb2				EQU nB1
nC2				EQU nBs1
nDb2				EQU nCs2
nEb2				EQU nDs2
nFb2				EQU nE2
nF2				EQU nEs2
nGb2				EQU nFs2
nAb2				EQU nGs2
nBb2				EQU nAs2
nCb3				EQU nB2
nC3				EQU nBs2
nDb3				EQU nCs3
nEb3				EQU nDs3
nFb3				EQU nE3
nF3				EQU nEs3
nGb3				EQU nFs3
nAb3				EQU nGs3
nBb3				EQU nAs3
nCb4				EQU nB3
nC4				EQU nBs3
nDb4				EQU nCs4
nEb4				EQU nDs4
nFb4				EQU nE4
nF4				EQU nEs4
nGb4				EQU nFs4
nAb4				EQU nGs4
nBb4				EQU nAs4
nCb5				EQU nB4
nC5				EQU nBs4
nDb5				EQU nCs5
nEb5				EQU nDs5
nFb5				EQU nE5
nF5				EQU nEs5
nGb5				EQU nFs5
nAb5				EQU nGs5
nBb5				EQU nAs5
nCb6				EQU nB5
nC6				EQU nBs5
nDb6				EQU nCs6
nEb6				EQU nDs6
nFb6				EQU nE6
nF6				EQU nEs6
nGb6				EQU nFs6
nAb6				EQU nGs6
nBb6				EQU nAs6
nCb7				EQU nB6
nC7				EQU nBs6
nDb7				EQU nCs7
nEb7				EQU nDs7
nFb7				EQU nE7
nF7				EQU nEs7
nGb7				EQU nFs7
nAb7				EQU nGs7
nBb7				EQU nAs7

; SMPS2ASM uses nMaxPSG for songs from S1/S2 drivers.
; nMaxPSG1 and nMaxPSG2 are used only for songs from S3/S&K/S3D drivers.
; The use of psgdelta is intended to undo the effects of PSGPitchConvert
; and ensure that the ending note is indeed the maximum PSG frequency.
nMaxPSG				EQU nBb6-psgdelta
nMaxPSG1			EQU nBb6
nMaxPSG2			EQU nB6
; ---------------------------------------------------------------------------------------------

	include "sound/SMPS2ASM - PSG Volume Envelope Equates.asm"
	include "sound/SMPS2ASM - DAC Sample Equates.asm"
    if SMPS_EnablePWM=1
	include "sound/SMPS2ASM - PWM Sample Equates.asm"
    endif

; ---------------------------------------------------------------------------------------------
; Channel IDs for SFX
cPSG1				EQU $80
cPSG2				EQU $A0
cPSG3				EQU $C0
cNoise				EQU $E0	; Not for use in S3/S&K/S3D
cFM3				EQU $02
cFM4				EQU $04
cFM5				EQU $05
cFM6				EQU $06	; Only in S3/S&K/S3D, overrides DAC
; ---------------------------------------------------------------------------------------------
; Conversion macros and functions

;conv0To256  function n,((n==0)<<8)|n
;s2TempotoS1 function n,(((768-n)>>1)/(256-n))&$FF
;s2TempotoS3 function n,($100-((n==0)|n))&$FF
;s1TempotoS2 function n,((((conv0To256(n)-1)<<8)+(conv0To256(n)>>1))/conv0To256(n))&$FF
;s1TempotoS3 function n,s2TempotoS3(s1TempotoS2(n))
;s3TempotoS1 function n,s2TempotoS1(s2TempotoS3(n))
;s3TempotoS2 function n,s2TempotoS3(n)

s2TempotoS1 macro
	s21convval:	= (((768-\1)>>1)/(256-\1))&$FF
	endm

s2TempotoS3 macro
	s23convval:	= ($100-(((\1=0)&1)|\1))&$FF
	s32convval:	= s23convval
	endm

s1TempotoS2 macro
	if \1=0
		s12convval:	= ((((256-1)<<8)+(256>>1))/256)&$FF
	else
		s12convval:	= ((((\1-1)<<8)+(\1>>1))/\1)&$FF
	endif
	endm

s1TempotoS3 macro
	s1TempotoS2	\1
	s2TempotoS3	s12convval
	s13convval:	= s32convval
	endm

s3TempotoS1 macro
	s2TempotoS3	\1
	s2TempotoS1	s23convval
	s31convval:	= s21convval
	endm

s3TempotoS2 macros
	s2TempotoS3	\_

convertMainTempoMod macro mod
	if SourceDriver>=3
		dc.b	mod
	elseif SourceDriver=1
		if mod=1
			inform 3,"Invalid main tempo of 1 in song from Sonic 1"
		endif
		s1TempotoS3	\mod
		dc.b	s13convval
	elseif SourceDriver=2
		if mod=0
			inform 3,"Invalid main tempo of 0 in song from Sonic 2"
		endif
		s2TempotoS3	\mod
		dc.b	s23convval
	endif
	endm

; PSG conversion to S3/S&K/S3D drivers require a tone shift of 12 semi-tones.
PSGPitchConvert macro pitch
	if SourceDriver>=3
		dc.b	\pitch
	else
		dc.b	(\pitch\+psgdelta)&$FF
	endif
	endm
; ---------------------------------------------------------------------------------------------
; Header Macros
smpsHeaderStartSong macro ver, sourcesmps2asmver

SourceDriver set ver

	if (narg=2)
SourceSMPS2ASM set sourcesmps2asmver
	else
SourceSMPS2ASM set 0
	endif

songStart set *

	if SMPS2ASMVer < SourceSMPS2ASM
		inform 1,"Song at 0x%h was made for a newer version of SMPS2ASM (this is version %d, but song wants at least version %d).",songStart,SMPS2ASMVer,SourceSMPS2ASM
	endif

	endm

smpsHeaderVoiceNull macro
	if songStart<>*
		inform 3,"Missing smpsHeaderStartSong"
	endif
	dc.w	$0000
	endm

; Header - Set up Voice Location
; Common to music and SFX
smpsHeaderVoice macro location
	if songStart<>*
		inform 3,"Missing smpsHeaderStartSong"
	endif

;loc_val	set location
;
;	if ((loc_val-songstart) >= $8000) | ((loc_val-songstart) < -$8000)
;		inform 3, "Track is too far away from its header"
;	endif

	dc.w	location-songStart
	endm

; Header - Set up Voice Location as S3's Universal Voice Bank
; Common to music and SFX
smpsHeaderVoiceUVB macro
	if songStart<>*
		inform 3,"Missing smpsHeaderStartSong"
	endif
	if SMPS_EnableUniversalVoiceBank=1
		dc.w	$0000
	else
		inform 3,"Go set SMPS_EnableUniversalVoiceBank to 1."
	endif
	endm

; Header macros for music (not for SFX)
; Header - Set up Channel Usage
smpsHeaderChan macro fm,psg,pwm
	dc.b	fm,psg
	if strlen("\pwm")>0
		dc.b	pwm
	else
		dc.b	$00
	endif
	dc.b	$00
	endm

; Header - Set up Tempo
smpsHeaderTempo macro div,mod
	dc.b	div
	convertMainTempoMod \mod
	endm

; Header - Set up DAC Channel
smpsHeaderDAC macro location,pitch,vol

;loc_val	set location
;
;	if ((loc_val-songstart) >= $8000) | ((loc_val-songstart) < -$8000)
;		inform 3, "Track is too far away from its header"
;	endif

	dc.w	location-songStart
	if strlen("\pitch")>0
		dc.b	pitch
		if strlen("\vol")>0
			dc.b	vol
		else
			dc.b	$00
		endif
	else
		dc.w	$00
	endif
	endm

; Header - Set up FM Channel
smpsHeaderFM macro location,pitch,vol

;loc_val	set location
;
;	if ((loc_val-songstart) >= $8000) | ((loc_val-songstart) < -$8000)
;		inform 3, "Track is too far away from its header"
;	endif

	dc.w	location-songStart
	dc.b	pitch,vol
	endm

; Header - Set up PSG Channel
smpsHeaderPSG macro location,pitch,vol,mod,voice

;loc_val	set location
;
;	if ((loc_val-songstart) >= $8000) | ((loc_val-songstart) < -$8000)
;		inform 3, "Track is too far away from its header"
;	endif

	dc.w	location-songStart
	PSGPitchConvert \pitch
	dc.b	(vol)<<3
	if SourceDriver>=3
		if (mod <> 0) & (SMPS_EnableModulationEnvelopes=0)
			inform 1, "PSG track header specifies a frequency modulation envelope (of \{mod}) but support for it is disabled - go set SMPS_EnableModulationEnvelopes to 1"
		endif
		dc.b	\mod
	else
		; Sometimes Sonic 1/2 songs specify a modulation envelope despite the driver not supporting them. Ignore them.
		dc.b	0
	endif
	dc.b	voice
	endm

; Header - Set up PWM Channel
smpsHeaderPWM macro loc,pitch,vol
    if SMPS_EnablePWM=1
	smpsHeaderFM loc,pitch,vol
    else
	inform 3, "Go set SMPS_EnablePWM to 1."
    endif
	endm

; Header macros for SFX (not for music)
; Header - Set up Tempo
smpsHeaderTempoSFX macro div
	dc.b	div
	endm

; Header - Set up Channel Usage
smpsHeaderChanSFX macro chan
	dc.b	chan
	endm

; Header - Set up FM Channel
smpsHeaderSFXChannel macro chanid,location,pitch,vol
	if chanid=cFM6
		inform 3, "Using channel ID of FM6 ($06) in Sonic 1 or Sonic 2 drivers is unsupported. Change it to another channel."
	endif
	dc.b	$80,chanid

;loc_val	set location
;
;	if ((loc_val-songstart) >= $8000) | ((loc_val-songstart) < -$8000)
;		inform 3, "Track is too far away from its header"
;	endif

	dc.w	location-songStart
	if (chanid&$80)<>0
		PSGPitchConvert \pitch
	else
		dc.b	pitch
	endif
	if (chanid=cPSG1) | (chanid=cPSG2) | (chanid=cPSG3)
		dc.b	vol<<3
	else
		dc.b	vol
	endif
	endm
; ---------------------------------------------------------------------------------------------
; Co-ord Flag Macros and Equates
; E0xx - Panning, AMS, FMS
smpsPan macro direction,amsfms
panNone equ $00
panRight equ $40
panLeft equ $80
panCentre equ $C0
panCenter equ $C0 ; silly Americans :U
	dc.b	$FF,$00,direction+amsfms
	endm

; E1xx - Set channel frequency displacement to xx
smpsDetune macro val
	dc.b	$FF,$01,val
	endm

; E2xx - Useless
smpsNop macro val
	dc.b	$FF,$02,val
	endm

; Return (used after smpsCall)
smpsReturn macro
	dc.b	$FF,$03
	endm

; Fade in previous song (ie. 1-Up)
smpsFade macro val
	if (SourceDriver>=3)&(strlen("\val"))&(strcmp("\val","$FF"))
		; This is one of those stupid S3+ "fades" that we don't need
	else
		dc.b	$FF,$04
	endif
	endm

; E5xx - Set channel tempo divider to xx
smpsChanTempoDiv macro val
	dc.b	$FF,$05,val
	endm

; E6xx - Alter Volume by xx
smpsAlterVol macro val
	dc.b	$FF,$06,val
	endm

; E7 - Prevent attack of next note
smpsNoAttack	EQU $FE

; E8xx - Set note fill to xx
smpsNoteFill macro val
	if SourceDriver>=3
		dc.b	$FF,$1D,val
	else
		dc.b	$FF,$08,val
	endif
	endm

; Add xx to channel pitch
smpsChangeTransposition macro val
	dc.b	$FF,$09,val
	endm

; Set music tempo modifier to xx
smpsSetTempoMod macro mod
	dc.b	$FF,$0A
	convertMainTempoMod \mod
	endm

; Set music tempo divider to xx
smpsSetTempoDiv macro val
	dc.b	$FF,$0B,val
	endm

; ECxx - Set Volume to xx
smpsSetVol macro val
	dc.b	$FF,$1C,val
	endm

; Works on all drivers
smpsPSGAlterVol macro vol
	dc.b	$FF,$0C,(((vol)<<3)&$7F)|((vol)&$80)
	endm

; Clears pushing sound flag in S1
smpsClearPush macro
	if SMPS_PushSFXBehaviour=1
		dc.b	$FF,$1F
	else
		inform 3,"Go set SMPS_PushSFXBehaviour to 1."
	endif
	endm

; Stops special SFX (S1 only) and restarts overridden music track
smpsStopSpecial macro
	if SMPS_EnableSpecSFX=1
		dc.b	$FF,$07
	else
		inform 3,"Go set SMPS_EnableSpecSFX to 1."
	endif
	endm

; EFxx[yy] - Set Voice of FM channel to xx; xx < 0 means yy present
smpsFMvoice macro voice,songID
	dc.b	$FF,$0D,voice
	endm

; F0wwxxyyzz - Modulation - ww: wait time - xx: modulation speed - yy: change per step - zz: number of steps
smpsModSet macro wait,speed,change,step
	if SourceDriver>=3
		dc.b	$FF,$21	; SMPS Z80 modulation mode
	else
		dc.b	$FF,$0E	; SMPS 68k modulation mode
	endif
	dc.b	wait,speed,change,step
	endm

; Turn on Modulation
smpsModOn macro type
	if strlen("\type")>0
		if SMPS_EnableModulationEnvelopes=1
			dc.b	$FF,$22,type
		else
			inform 3,"Go set SMPS_EnableModulationEnvelopes to 1"
		endif
	else
		dc.b	$FF,$0F
	endif
	endm

; F2 - End of channel
smpsStop macro
	dc.b	$FF,$10
	endm

; F3xx - PSG waveform to xx
smpsPSGform macro form
	dc.b	$FF,$11,form
	endm

; Turn off Modulation
smpsModOff macro
	dc.b	$FF,$12
	endm

; F5xx - PSG voice to xx
smpsPSGvoice macro voice
	dc.b	$FF,$13,voice
	endm

; F6xxxx - Jump to xxxx
smpsJump macro loc
	dc.b	$FF,$14
	dc.w	loc-(*+1)
	endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
smpsLoop macro index,loops,loc
	dc.b	$FF,$15
	dc.b	index,loops
	dc.w	loc-(*+1)
	endm

; F8xxxx - Call pattern at xxxx, saving return point
smpsCall macro loc
	dc.b	$FF,$16
	dc.w	loc-(*+2)
	endm
; ---------------------------------------------------------------------------------------------
; Alter Volume
smpsFMAlterVol macro val1
	dc.b	$FF,$06,val1
	endm

; S3/S&K/S3D/Clone Driver v2-only coordination flags

; Silences FM channel then stops as per smpsStop
smpsStopFM macro
	dc.b	$FF,$18
	endm

smpsPlayDACSample macro sample
	dc.b	$FF,$19,sample
	endm

smpsPlaySound macro index
	dc.b	$FF,$1A,index
	endm

; Set note values to xx-$40
smpsSetNote macro val
	dc.b	$FF,$1B,(val-$40)&$FF
	endm

; Set Modulation
smpsModChange macro val
	if SMPS_EnableModulationEnvelopes=1
		dc.b	$FF,$22,val
	else
		inform 3,"Go set SMPS_EnableModulationEnvelopes to 1"
	endif
	endm

; FCxxxx - Jump to xxxx
smpsContinuousLoop macro loc
	if SMPS_EnableContSFX=1
		dc.b	$FF,$1E
		dc.w	loc-(*+1)
	else
		inform 3,"You're using a Continuous SFX, but don't have SMPS_EnableContSFX set"
	endif
	endm

smpsFMICommand macro reg,val
	dc.b	$FF,$20,reg,val
	endm

	; Flags ported from other drivers.
smpsChanFMCommand macro reg,val
	dc.b	$FF,$17,reg,val
	endm
; ---------------------------------------------------------------------------------------------
; S1/S2 only coordination flag
; Sets D1L to maximum volume (minimum attenuation) and RR to maximum for operators 3 and 4 of FM1
smpsMaxRelRate macro
	; Emulate it in S3/S&K/S3D/Clone Driver v2
	smpsFMICommand $88,$0F
	smpsFMICommand $8C,$0F
	endm
; ---------------------------------------------------------------------------------------------
; Backwards compatibility
smpsAlterNote macro
	smpsDetune	\_
	endm

smpsAlterPitch macro
	smpsChangeTransposition	\_
	endm

smpsWeirdD1LRR macro
	smpsMaxRelRate \_
	endm

smpsSetvoice macro
	smpsFMvoice \_
	endm
; ---------------------------------------------------------------------------------------------
; Macros for FM instruments
; Voices - Feedback
smpsVcFeedback macro val
vcFeedback set val
	endm

; Voices - Algorithm
smpsVcAlgorithm macro val
vcAlgorithm set val
	endm

smpsVcUnusedBits macro val
vcUnusedBits set val
	endm

; Voices - Detune
smpsVcDetune macro op1,op2,op3,op4
vcDT1 set op1
vcDT2 set op2
vcDT3 set op3
vcDT4 set op4
	endm

; Voices - Coarse-Frequency
smpsVcCoarseFreq macro op1,op2,op3,op4
vcCF1 set op1
vcCF2 set op2
vcCF3 set op3
vcCF4 set op4
	endm

; Voices - Rate Scale
smpsVcRateScale macro op1,op2,op3,op4
vcRS1 set op1
vcRS2 set op2
vcRS3 set op3
vcRS4 set op4
	endm

; Voices - Attack Rate
smpsVcAttackRate macro op1,op2,op3,op4
vcAR1 set op1
vcAR2 set op2
vcAR3 set op3
vcAR4 set op4
	endm

; Voices - Amplitude Modulation
; The original SMPS2ASM erroneously assumed the 6th and 7th bits
; were the Amplitude Modulation.
; According to several docs, however, it's actually the high bit.
smpsVcAmpMod macro op1,op2,op3,op4
	if SMPS2ASMVer=0
vcAM1 set op1<<5
vcAM2 set op2<<5
vcAM3 set op3<<5
vcAM4 set op4<<5
	else
vcAM1 set op1<<7
vcAM2 set op2<<7
vcAM3 set op3<<7
vcAM4 set op4<<7
	endif
	endm

; Voices - First Decay Rate
smpsVcDecayRate1 macro op1,op2,op3,op4
vcD1R1 set op1
vcD1R2 set op2
vcD1R3 set op3
vcD1R4 set op4
	endm

; Voices - Second Decay Rate
smpsVcDecayRate2 macro op1,op2,op3,op4
vcD2R1 set op1
vcD2R2 set op2
vcD2R3 set op3
vcD2R4 set op4
	endm

; Voices - Decay Level
smpsVcDecayLevel macro op1,op2,op3,op4
vcDL1 set op1
vcDL2 set op2
vcDL3 set op3
vcDL4 set op4
	endm

; Voices - Release Rate
smpsVcReleaseRate macro op1,op2,op3,op4
vcRR1 set op1
vcRR2 set op2
vcRR3 set op3
vcRR4 set op4
	endm

; Voices - Total Level
; The original SMPS2ASM decides TL high bits automatically,
; but later versions leave it up to the user.
; Alternatively, if we're converting an SMPS 68k song to SMPS Z80,
; then we *want* the TL bits to match the algorithm, because SMPS 68k
; prefers the algorithm over the TL bits, ignoring the latter, while
; SMPS Z80 does the opposite.
; Unfortunately, there's nothing we can do if we're trying to convert
; an SMPS Z80 song to SMPS 68k. It will ignore the bits no matter
; what we do, so we just print a warning.
smpsVcTotalLevel macro op1,op2,op3,op4
vcTL1 set op1
vcTL2 set op2
vcTL3 set op3
vcTL4 set op4
	dc.b	(vcUnusedBits<<6)+(vcFeedback<<3)+vcAlgorithm
;   0     1     2     3     4     5     6     7
;%1000,%1000,%1000,%1000,%1010,%1110,%1110,%1111
	if SourceSMPS2ASM=0
vcTLMask4 set ((vcAlgorithm=7)<<7)
vcTLMask3 set ((vcAlgorithm>=4)<<7)
vcTLMask2 set ((vcAlgorithm>=5)<<7)
vcTLMask1 set $80
	else
vcTLMask4 set 0
vcTLMask3 set 0
vcTLMask2 set 0
vcTLMask1 set 0
	endif

	if SourceDriver<3
vcTLMask4 set ((vcAlgorithm=7)<<7)
vcTLMask3 set ((vcAlgorithm>=4)<<7)
vcTLMask2 set ((vcAlgorithm>=5)<<7)
vcTLMask1 set $80
vcTL1 set vcTL1&$7F
vcTL2 set vcTL2&$7F
vcTL3 set vcTL3&$7F
vcTL4 set vcTL4&$7F
	endif

	dc.b	(vcDT4<<4)+vcCF4 ,(vcDT2<<4)+vcCF2 ,(vcDT3<<4)+vcCF3 ,(vcDT1<<4)+vcCF1
	dc.b	vcTL4|vcTLMask4  ,vcTL2|vcTLMask2  ,vcTL3|vcTLMask3  ,vcTL1|vcTLMask1
	dc.b	(vcRS4<<6)+vcAR4 ,(vcRS2<<6)+vcAR2 ,(vcRS3<<6)+vcAR3 ,(vcRS1<<6)+vcAR1
	dc.b	vcAM4|vcD1R4     ,vcAM2|vcD1R2     ,vcAM3|vcD1R3     ,vcAM1|vcD1R1
	dc.b	vcD2R4           ,vcD2R2           ,vcD2R3           ,vcD2R1
	dc.b	(vcDL4<<4)+vcRR4 ,(vcDL2<<4)+vcRR2 ,(vcDL3<<4)+vcRR3 ,(vcDL1<<4)+vcRR1
	endm
