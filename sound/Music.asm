; ---------------------------------------------------------------------------
; Music metadata (pointers, speed shoes tempos, flags)
; ---------------------------------------------------------------------------

; byte_71A94: SpeedUpIndex:
MusicIndex:

					s1TempotoS3	$07
ptr_mus81:	SMPS_MUSIC_METADATA	Music81, s13convval, 0	; GHZ

					s1TempotoS3	$72
ptr_mus82:	SMPS_MUSIC_METADATA	Music82, s13convval, 0	; LZ

					s1TempotoS3	$73
ptr_mus83:	SMPS_MUSIC_METADATA	Music83, s13convval, 0	; MZ

					s1TempotoS3	$26
ptr_mus84:	SMPS_MUSIC_METADATA	Music84, s13convval, 0	; SLZ

					s1TempotoS3	$15
ptr_mus85:	SMPS_MUSIC_METADATA	Music85, s13convval, 0	; SYZ

					s1TempotoS3	$08
ptr_mus86:	SMPS_MUSIC_METADATA	Music86, s13convval, 0	; SBZ

					s1TempotoS3	$FF
ptr_mus87:	SMPS_MUSIC_METADATA	Music87, s13convval, 0	; Invincible

					s1TempotoS3	$05
ptr_mus88:	SMPS_MUSIC_METADATA	Music88, s13convval, 0	; Extra Life

					s1TempotoS3	$08
ptr_mus89:	SMPS_MUSIC_METADATA	Music89, s13convval, 0	; Special Stage

					s1TempotoS3	$05
ptr_mus8A:	SMPS_MUSIC_METADATA	Music8A, s13convval, 0	; Title Screen

					s1TempotoS3	$05
ptr_mus8B:	SMPS_MUSIC_METADATA	Music8B, s13convval, SMPS_MUSIC_METADATA_FORCE_PAL_SPEED	; Ending

					s1TempotoS3	$04
ptr_mus8C:	SMPS_MUSIC_METADATA	Music8C, s13convval-$20, 0	; Boss

					s1TempotoS3	$06
ptr_mus8D:	SMPS_MUSIC_METADATA	Music8D, s13convval-$20, 0	; Final Zone

					s1TempotoS3	$03
ptr_mus8E:	SMPS_MUSIC_METADATA	Music8E, s13convval, 0	; End of Act

					s1TempotoS3	$13
ptr_mus8F:	SMPS_MUSIC_METADATA	Music8F, s13convval, 0	; Game Over

					s1TempotoS3	$07
ptr_mus90:	SMPS_MUSIC_METADATA	Music90, s13convval, SMPS_MUSIC_METADATA_FORCE_PAL_SPEED	; Continue

					s1TempotoS3	$33
ptr_mus91:	SMPS_MUSIC_METADATA	Music91, s13convval, SMPS_MUSIC_METADATA_FORCE_PAL_SPEED	; Credits

					s1TempotoS3	$02
ptr_mus92:	SMPS_MUSIC_METADATA	Music92, s13convval, SMPS_MUSIC_METADATA_FORCE_PAL_SPEED	; Drowning

					s1TempotoS3	$06
ptr_mus93:	SMPS_MUSIC_METADATA	Music93, s13convval, 0	; Emerald
ptr_musend

; ---------------------------------------------------------------------------
; Music data
; ---------------------------------------------------------------------------

Music81:	include "sound/music/Mus81 - GHZ.asm"
	even
Music82:	include "sound/music/Mus82 - LZ.asm"
	even
Music83:	include "sound/music/Mus83 - MZ.asm"
	even
Music84:	include "sound/music/Mus84 - SLZ.asm"
	even
Music85:	include "sound/music/Mus85 - SYZ.asm"
	even
Music86:	include "sound/music/Mus86 - SBZ.asm"
	even
Music87:	include "sound/music/Mus87 - Invincibility.asm"
	even
Music88:	include "sound/music/Mus88 - Extra Life.asm"
	even
Music89:	include "sound/music/Mus89 - Special Stage.asm"
	even
Music8A:	include "sound/music/Mus8A - Title Screen.asm"
	even
Music8B:	include "sound/music/Mus8B - Ending.asm"
	even
Music8C:	include "sound/music/Mus8C - Boss.asm"
	even
Music8D:	include "sound/music/Mus8D - FZ.asm"
	even
Music8E:	include "sound/music/Mus8E - Sonic Got Through.asm"
	even
Music8F:	include "sound/music/Mus8F - Game Over.asm"
	even
Music90:	include "sound/music/Mus90 - Continue Screen.asm"
	even
Music91:	include "sound/music/Mus91 - Credits.asm"
	even
Music92:	include "sound/music/Mus92 - Drowning.asm"
	even
Music93:	include "sound/music/Mus93 - Get Emerald.asm"
	even
