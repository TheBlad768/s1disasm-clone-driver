SMPS_z80_ram equ			$A00000

SMPS_version_number equ			$A10001

SMPS_z80_bus_request equ		$A11100
SMPS_z80_reset equ			$A11200

SMPS_ym2612_a0 equ			$A04000
SMPS_ym2612_d0 equ			$A04001
SMPS_ym2612_a1 equ			$A04002
SMPS_ym2612_d1 equ			$A04003

    if SMPS_EnablePWM=1
SMPS_pwm_comm equ			$A15128
    endif

SMPS_psg_input equ			$C00011

SMPS_TRACK_COUNT equ			(SMPS_RAM.v_track_ram_end-SMPS_RAM.v_track_ram)/SMPS_Track.len

SMPS_MUSIC_TRACK_COUNT equ		(SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)/SMPS_Track.len
SMPS_MUSIC_FM_DAC_TRACK_COUNT equ	(SMPS_RAM.v_music_fmdac_tracks_end-SMPS_RAM.v_music_fmdac_tracks)/SMPS_Track.len
SMPS_MUSIC_FM_TRACK_COUNT equ		(SMPS_RAM.v_music_fm_tracks_end-SMPS_RAM.v_music_fm_tracks)/SMPS_Track.len
SMPS_MUSIC_PSG_TRACK_COUNT equ		(SMPS_RAM.v_music_psg_tracks_end-SMPS_RAM.v_music_psg_tracks)/SMPS_Track.len
    if SMPS_EnablePWM=1
SMPS_MUSIC_PWM_TRACK_COUNT equ		(SMPS_RAM.v_music_pwm_tracks_end-SMPS_RAM.v_music_pwm_tracks)/SMPS_Track.len
    endif

SMPS_SFX_TRACK_COUNT equ		(SMPS_RAM.v_sfx_track_ram_end-SMPS_RAM.v_sfx_track_ram)/SMPS_Track.len
SMPS_SFX_FM_TRACK_COUNT equ		(SMPS_RAM.v_sfx_fm_tracks_end-SMPS_RAM.v_sfx_fm_tracks)/SMPS_Track.len
SMPS_SFX_PSG_TRACK_COUNT equ		(SMPS_RAM.v_sfx_psg_tracks_end-SMPS_RAM.v_sfx_psg_tracks)/SMPS_Track.len

    if SMPS_EnableSpecSFX=1
SMPS_SPECIAL_SFX_TRACK_COUNT equ	(SMPS_RAM.v_spcsfx_track_ram_end-SMPS_RAM.v_spcsfx_track_ram)/SMPS_Track.len
SMPS_SPECIAL_SFX_FM_TRACK_COUNT equ	(SMPS_RAM.v_spcsfx_fm_tracks_end-SMPS_RAM.v_spcsfx_fm_tracks)/SMPS_Track.len
SMPS_SPECIAL_SFX_PSG_TRACK_COUNT equ	(SMPS_RAM.v_spcsfx_psg_tracks_end-SMPS_RAM.v_spcsfx_psg_tracks)/SMPS_Track.len
    endif
