; ---------------------------------------------------------------------------
; Track variables
; ---------------------------------------------------------------------------

makeStruct__SMPS_Track:	macro *
\*:
\*.PlaybackControl:		ds.b 1	; All tracks
\*.VoiceControl:		ds.b 1	; All tracks

\*.VolEnvIndex:			;ds.b 1	; All tracks	; Clownacy | Now shared with panning RAM
\*.AMSFMSPan:			ds.b 1	; FM/DAC only

\*.TempoDivider:		ds.b 1	; All tracks
\*.Transpose:			ds.b 1	; FM/PSG only
\*.Volume:			ds.b 1	; All tracks

\*.VoiceIndex:			;ds.b 1	; FM/PSG only
\*.DataPointer:			ds.l 1	; All tracks

\*.SavedDAC:			;ds.b 1	; DAC only

    if SMPS_EnablePWM=1
\*.SavedPWM:			;ds.b 1	; PWM only
    endif

\*.Freq:			ds.w 1	; FM/PSG only

\*.StackPointer:		ds.b 1	; All tracks
\*.DurationTimeout:		ds.b 1	; All tracks
\*.SavedDuration:		ds.b 1	; All tracks
\*.NoteTimeout:			ds.b 1	; FM/PSG only

\*.NoteTimeoutMaster:		;ds.b 1	; FM/PSG only
\*.ModulationPtr:		ds.l 1	; FM/PSG only

\*.ModulationWait:		ds.b 1	; FM/PSG only
\*.ModulationSpeed:		ds.b 1	; FM/PSG only
\*.ModulationDelta:		ds.b 1	; FM/PSG only
\*.ModulationSteps:		ds.b 1	; FM/PSG only
\*.ModulationVal:		ds.w 1	; FM/PSG only (2 bytes)

    if SMPS_EnableModulationEnvelopes=1
\*.ModulationCtrl:		ds.b 1	; FM/PSG only
\*.ModEnvIndex:			ds.b 1	; FM/PSG only
\*.ModEnvSens:			ds.b 1	; FM/PSG only
    else
				ds.b 1	; padding to ensure an even address
    endif

\*.Detune:			ds.b 1	; FM/PSG only

\*.PSGNoise:			;ds.b 1	; PSG only
\*.VoicePtr:			ds.l 1	; FM only - This used to be FM SFX only (well, technically all SFX tracks), but now music and Special SFX use it too

\*.LoopCounters:		ds.l 3	; All tracks
\*.GoSubStack:				; All tracks

\*.len:					; special property to determine struct length (must appear last)

	endm

; ---------------------------------------------------------------------------
; Queue variables
; ---------------------------------------------------------------------------

makeStruct__SMPS_Queue:	macro *
\*:
\*.v_playsnd1:			ds.w 1	; music to play	; Clownacy | Note to all, must be on even address!
\*.v_playsnd2:			ds.w 1	; sound to play
\*.v_playsnd3:			ds.w 1	; secondary sound to play
\*.v_playsnd4:			ds.w 1	; secondary music to play

\*.len:					; special property to determine struct length (must appear last)

	endm

; ---------------------------------------------------------------------------
; Global sound driver variables
; ---------------------------------------------------------------------------

makeStruct__SMPS_RAM_Variables:	macro *
\*:
\*.queue:			ds.b SMPS_Queue.len

\*.v_sndprio:			ds.b 1	; sound priority (priority of new music/SFX must be higher or equal to this value or it won't play; bit 7 of priority being set prevents this value from changing)
\*.v_main_tempo_timeout:	ds.b 1	; Has v_main_tempo added to it; when it carries, delays song by 1 frame
\*.v_main_tempo:		ds.b 1	; Used for music only
\*.bitfield2:			ds.b 1

	if MSUMode=1
\*.v_cda_playing:		ds.b 1
\*.v_cda_ignore:		ds.b 1
	endif

f_1up_playing:			equ 0	; flag indicating 1-up song is playing
f_speedup:			equ 1	; flag indicating whether speed shoes tempo is on ($80) or off ($00)
f_force_pal_tempo		equ 2	; flag for if the current song must play at PAL speed on PAL consoles

\*.v_fadeout_counter:		ds.b 1
\*.v_fadeout_delay:		ds.b 1

\*.v_fadein_counter:		ds.b 1	; Timer for fade in/out
\*.v_fadein_delay:		ds.b 1

\*.v_tempo_mod:			ds.b 1	; music - tempo modifier
\*.v_speeduptempo:		ds.b 1	; music - tempo modifier with speed shoes

\*.v_pal_audio_countdown:	ds.b 1
\*.v_communication_byte:	ds.b 1

    if SMPS_EnableContSFX=1
\*.v_current_contsfx:		ds.w 1
\*.v_contsfx_channels:		ds.b 1
    endif

\*.len:				; special property to determine struct length (must appear last)

	endm

; ---------------------------------------------------------------------------
; Global sound driver variables
; ---------------------------------------------------------------------------

makeStruct__SMPS_RAM:	macro *
\*:
\*.v_track_ram:

\*.v_music_track_ram:
\*.v_music_fmdac_tracks:
\*.v_music_dac_track:		makeStruct__SMPS_Track
\*.v_music_fm_tracks:
\*.v_music_fm1_track:		makeStruct__SMPS_Track
\*.v_music_fm2_track:		makeStruct__SMPS_Track
\*.v_music_fm3_track:		makeStruct__SMPS_Track
\*.v_music_fm4_track:		makeStruct__SMPS_Track
\*.v_music_fm5_track:		makeStruct__SMPS_Track
\*.v_music_fm6_track:		makeStruct__SMPS_Track
\*.v_music_fm_tracks_end:
\*.v_music_fmdac_tracks_end:
\*.v_music_psg_tracks:
\*.v_music_psg1_track:		makeStruct__SMPS_Track
\*.v_music_psg2_track:		makeStruct__SMPS_Track
\*.v_music_psg3_track:		makeStruct__SMPS_Track
\*.v_music_psg_tracks_end:

    if SMPS_EnablePWM=1
\*.v_music_pwm_tracks:
\*.v_music_pwm1_track:		makeStruct__SMPS_Track
\*.v_music_pwm2_track:		makeStruct__SMPS_Track
\*.v_music_pwm3_track:		makeStruct__SMPS_Track
\*.v_music_pwm4_track:		makeStruct__SMPS_Track
\*.v_music_pwm_tracks_end:
    endif

\*.v_music_track_ram_end:

\*.v_1up_ram_copy:
\*.v_sfx_track_ram:
\*.v_sfx_fm_tracks:
\*.v_1up_dac_track:
\*.v_sfx_fm3_track:		makeStruct__SMPS_Track
\*.v_1up_fm1_track:
\*.v_sfx_fm4_track:		makeStruct__SMPS_Track
\*.v_1up_fm2_track:
\*.v_sfx_fm5_track:		makeStruct__SMPS_Track
\*.v_sfx_fm_tracks_end:
\*.v_sfx_psg_tracks:
\*.v_1up_fm3_track:
\*.v_sfx_psg1_track:		makeStruct__SMPS_Track
\*.v_1up_fm4_track:
\*.v_sfx_psg2_track:		makeStruct__SMPS_Track
\*.v_1up_fm5_track:
\*.v_sfx_psg3_track:		makeStruct__SMPS_Track
\*.v_sfx_psg_tracks_end:
\*.v_sfx_track_ram_end:

    if SMPS_EnableSpecSFX=1
\*.v_spcsfx_track_ram:
\*.v_spcsfx_fm_tracks:
\*.v_1up_fm6_track:
\*.v_spcsfx_fm4_track:		makeStruct__SMPS_Track
\*.v_spcsfx_fm_tracks_end:
\*.v_spcsfx_psg_tracks:
\*.v_1up_psg1_track:
\*.v_spcsfx_psg3_track:		makeStruct__SMPS_Track
\*.v_spcsfx_psg_tracks_end:
\*.v_spcsfx_track_ram_end:
    endif

\*.v_track_ram_end:

    if SMPS_EnableSpecSFX=0
\*.v_1up_fm6_track:		makeStruct__SMPS_Track
\*.v_1up_psg1_track:		makeStruct__SMPS_Track
    endif
\*.v_1up_psg2_track:		makeStruct__SMPS_Track
\*.v_1up_psg3_track:		makeStruct__SMPS_Track
    if SMPS_EnablePWM=1
\*.v_1up_pwm1_track:		makeStruct__SMPS_Track
\*.v_1up_pwm2_track:		makeStruct__SMPS_Track
\*.v_1up_pwm3_track:		makeStruct__SMPS_Track
\*.v_1up_pwm4_track:		makeStruct__SMPS_Track
    endif

	SMPS_RAM_even

\*.variables:			makeStruct__SMPS_RAM_Variables

	SMPS_RAM_even

\*.variables_backup:		makeStruct__SMPS_RAM_Variables

\*.f_pause:			ds.b 1

\*.bitfield1:			ds.b 1

    if SMPS_RingSFXBehaviour=1
v_ring_speaker			equ 0	; which speaker the "ring" sound is played in (0 = right; 1 = left)
    endif
    if SMPS_GloopSFXBehaviour=1
v_gloop_toggle			equ 1	; if set, prevents further gloop sounds from playing
    endif
    if SMPS_EnableSpinDashSFX=1
f_spindash_lastsound		equ 2
    endif
    if SMPS_PushSFXBehaviour=1
f_push_playing			equ 3
    endif
    if SMPS_EnableContSFX=1
f_continuous_sfx		equ 4
    endif
f_pal				equ 5

    if SMPS_EnableSpinDashSFX=1
\*.v_spindash_timer:		ds.b 1
\*.v_spindash_pitch:		ds.b 1
    endif

\*.SMPS_running_flag:		ds.b 1

\*.len:				; special property to determine struct length (must appear last)

	endm

	obj 0			; Generate "makeStruct__SMPS_Track" structure
SMPS_Track:			makeStruct__SMPS_Track
	objend

	obj 0			; Generate "SMPS_Queue" structure
SMPS_Queue:			makeStruct__SMPS_Queue
	objend

	obj 0			; Generate "SMPS_RAM_Variables" structure
SMPS_RAM_Variables:		makeStruct__SMPS_RAM_Variables
	objend

	obj 0			; Generate "SMPS_RAM" structure
SMPS_RAM:			makeStruct__SMPS_RAM
	objend

	org 0

	inform 0, "Sonic 2 Clone Driver v2 RAM size is $\$SMPS_RAM.len bytes!"

    if SMPS_RAM.len>(Snd_driver_RAM_end-Snd_driver_RAM)
	inform 3, "Sonic 2 Clone Driver v2 RAM overflow!"
    endif
