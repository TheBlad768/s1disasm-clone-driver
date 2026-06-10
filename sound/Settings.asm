; ========SONIC 1 GIT EQUATES========

; ---FLAGS---
SMPS_RingSFXBehaviour		equ 1
;	| If 1, SndID_Ring alternates between the left and right speakers.
;
SMPS_GloopSFXBehaviour		equ 0
;	| If 1, SndID_Gloop only plays on every other call.
;
SMPS_PushSFXBehaviour		equ 1
;	| If 1, sfx_push plays similarly to a continuous SFX.
;
SMPS_EnableSpecSFX		equ 1
;	| If 1, include the Special SFX system. Used by S1's waterfall SFX
;
SMPS_EnableSpinDashSFX		equ 0
;	| If 1, include S2's spin dash SFX pitch system
;
SMPS_EnableContSFX		equ 0
;	| If 1, include S3K's continuous SFX system
;
SMPS_First_ContSFX		equ $BC
;	| Set this to the sound ID of your first continuous SFX. This ID must be a higher number than any of your normal SFXes
;	| (Default value is S&K's)
;
SMPS_IdlingSegaSound		equ 0
;	| If 1, the Sega sound makes the 68k idle. Needed for stock Sonic 1
;
SMPS_EnableUniversalVoiceBank	equ 0
;	| If 1, include the Universal Voice Bank, used by S3 and S&K
;
SMPS_EnablePlaySoundLocal	equ 0
;	| If 1, SMPS_PlaySoundLocal is included
;
SMPS_EnableModulationEnvelopes	equ 0
;	| If 1, modulation envelope support is included
;
SMPS_IsOn32X			equ 0
;	| If 1, DAC driver is made compatible with the 32X
;
SMPS_EnablePWM			equ 0
;	| If 1, support for four PWM tracks is added
;
SMPS_Asserts			equ 0
;	| If 1, some debugging logic is enabled to catch broken behaviour in songs and sounds.
;
SMPS_SoundTest			equ 0
;	| If 1, some some extra logic for my 'sound test' homebrew is enabled.

SMPS_S1DACSamples		equ 1
SMPS_S2DACSamples		equ 0
SMPS_S3DACSamples		equ 0
SMPS_SKDACSamples		equ 0
SMPS_S3DDACSamples		equ 0
SMPS_SCDACSamples		equ 0

SMPS_S1PSGEnvelopes		equ 1
SMPS_S2PSGEnvelopes		equ 0
SMPS_S3PSGEnvelopes		equ 0
SMPS_SKPSGEnvelopes		equ 0
SMPS_S3DPSGEnvelopes		equ 0
SMPS_KCPSGEnvelopes		equ 0

; ---DISASM-DEPENDANT VARIABLES AND FUNCTIONS---
SoundDriverLoad			equ SMPS_LoadDACDriver
DACDriverLoad			equ SMPS_LoadDACDriver

PlayMusic			equ SMPS_QueueSound1
Play_Music			equ SMPS_QueueSound1
PlaySound			equ SMPS_QueueSound1
Play_Sound			equ SMPS_QueueSound1
QueueSound1			equ SMPS_QueueSound1
PlaySFX				equ SMPS_QueueSound2
Play_SFX			equ SMPS_QueueSound2
PlaySound_Special		equ SMPS_QueueSound2
QueueSound2			equ SMPS_QueueSound2
Play_Sound_2			equ SMPS_QueueSound2
PlaySound_Unused		equ SMPS_QueueSound3
Play_Sample			equ SMPS_PlayDACSample

bgm_FadeOut			equ bgm_Fade
bgm_StopSFX			equ sfx_Stop

Clone_Driver_RAM		equ (-(Snd_driver_RAM&$80000000)<<1)|Snd_driver_RAM

; ---SOUND ID BOUNDARIES---
MusID__First			equ bgm__First
;	| ID of your first song
;
MusID__End			equ bgm__End+1
;	| ID of your last song+1
;
SndID__First			equ sfx__First
;	| ID of your first SFX
;
SndID__End			equ sfx__End+1
;	| ID of your last SFX+1
;
SpecID__First			equ spec__First
;	| ID of your first Special SFX
;
SpecID__End			equ spec__End+1
;	| ID of your last Special SFX+1
;
FlgID__First			equ flg__First
;	| ID of your first command
;
FlgID__End			equ flg__End+1
;	| ID of your last command+1
;

; ---MUSIC CONSTANTS---
MusID_ExtraLife			equ bgm_ExtraLife
;	| ID of your Extra Life jingle
;

; ---SFX CONSTANTS---
SndID_Ring			equ sfx_Ring
;	| ID of your ring SFX
;
SndID_RingLeft			equ sfx_RingLeft
;	| ID of your alternate ring SFX
;
SndID_SpindashRev		equ $00
;	| Set this to the ID of your Spin Dash SFX (if you have one). Use with EnableSpinDashSFX
;
