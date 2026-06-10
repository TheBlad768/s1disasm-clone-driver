; PSG volume envelope equates

	if SMPS_S1PSGEnvelopes|SMPS_S2PSGEnvelopes
; S1/S2
fTone_01 equ		((ptr_s1psg01-PSG_Index)/4)+1
fTone_02 equ		((ptr_s1psg02-PSG_Index)/4)+1
fTone_03 equ		((ptr_s1psg03-PSG_Index)/4)+1
fTone_04 equ		((ptr_s1psg04-PSG_Index)/4)+1
fTone_05 equ		((ptr_s1psg05-PSG_Index)/4)+1
fTone_06 equ		((ptr_s1psg06-PSG_Index)/4)+1
fTone_07 equ		((ptr_s1psg07-PSG_Index)/4)+1
fTone_08 equ		((ptr_s1psg08-PSG_Index)/4)+1
fTone_09 equ		((ptr_s1psg09-PSG_Index)/4)+1
	endif

	if SMPS_S2PSGEnvelopes
; S2
fTone_0A equ		((ptr_s2psg0A-PSG_Index)/4)+1
fTone_0B equ		((ptr_s2psg0B-PSG_Index)/4)+1
fTone_0C equ		((ptr_s2psg0C-PSG_Index)/4)+1
fTone_0D equ		((ptr_s2psg0D-PSG_Index)/4)+1
	endif

	if SMPS_S3PSGEnvelopes|SMPS_SKPSGEnvelopes|SMPS_S3DPSGEnvelopes
; S3/S&K/S3D
sTone_01 equ		((ptr_s3psg01-PSG_Index)/4)+1
sTone_02 equ		((ptr_s3psg02-PSG_Index)/4)+1
sTone_03 equ		((ptr_s3psg03-PSG_Index)/4)+1
sTone_05 equ		((ptr_s3psg05-PSG_Index)/4)+1
sTone_06 equ		((ptr_s3psg06-PSG_Index)/4)+1
sTone_07 equ		((ptr_s3psg07-PSG_Index)/4)+1
sTone_08 equ		((ptr_s3psg08-PSG_Index)/4)+1
sTone_09 equ		((ptr_s3psg09-PSG_Index)/4)+1
sTone_0A equ		((ptr_s3psg0A-PSG_Index)/4)+1
sTone_0B equ		((ptr_s3psg0B-PSG_Index)/4)+1
sTone_0C equ		((ptr_s3psg0C-PSG_Index)/4)+1
sTone_0D equ		((ptr_s3psg0D-PSG_Index)/4)+1
sTone_10 equ		((ptr_s3psg10-PSG_Index)/4)+1
sTone_11 equ		((ptr_s3psg11-PSG_Index)/4)+1
sTone_14 equ		((ptr_s3psg14-PSG_Index)/4)+1
sTone_18 equ		((ptr_s3psg18-PSG_Index)/4)+1
sTone_1A equ		((ptr_s3psg1A-PSG_Index)/4)+1
sTone_1C equ		((ptr_s3psg1C-PSG_Index)/4)+1
sTone_1D equ		((ptr_s3psg1D-PSG_Index)/4)+1
sTone_1E equ		((ptr_s3psg1E-PSG_Index)/4)+1
sTone_1F equ		((ptr_s3psg1F-PSG_Index)/4)+1
sTone_20 equ		((ptr_s3psg20-PSG_Index)/4)+1
sTone_21 equ		((ptr_s3psg21-PSG_Index)/4)+1
sTone_22 equ		((ptr_s3psg22-PSG_Index)/4)+1
sTone_23 equ		((ptr_s3psg23-PSG_Index)/4)+1
sTone_24 equ		((ptr_s3psg24-PSG_Index)/4)+1
sTone_25 equ		((ptr_s3psg25-PSG_Index)/4)+1
sTone_27 equ		((ptr_s3psg27-PSG_Index)/4)+1
	endif

	if SMPS_S3PSGEnvelopes
; S3
sTone_26a equ		((ptr_s3psg26-PSG_Index)/4)+1
	endif

	if SMPS_S3PSGEnvelopes|SMPS_SKPSGEnvelopes
; S3/S&K
sTone_04a equ		((ptr_s3psg04-PSG_Index)/4)+1
sTone_04 equ	sTone_04a
	endif

	if SMPS_SKPSGEnvelopes|SMPS_S3DPSGEnvelopes
; S&K/S3D
sTone_26b equ		((ptr_skpsg26-PSG_Index)/4)+1
sTone_26 equ	sTone_26b
	endif

	if SMPS_S3DPSGEnvelopes
; S3D
sTone_04b equ		((ptr_s3dpsg04-PSG_Index)/4)+1
sTone_28 equ		((ptr_s3dpsg28-PSG_Index)/4)+1
	endif

	if SMPS_S3PSGEnvelopes|SMPS_SKPSGEnvelopes|SMPS_S3DPSGEnvelopes
; Duplicates
sTone_0E equ sTone_01
sTone_0F equ sTone_02
sTone_12 equ sTone_05
sTone_13 equ sTone_06
sTone_15 equ sTone_08
sTone_16 equ sTone_09
sTone_17 equ sTone_0A
sTone_19 equ sTone_0C
sTone_1B equ sTone_0C
	endif

    if SMPS_KCPSGEnvelopes
; Knuckles' Chaotix
KCVolEnv_01 equ		((ptr_kcpsg01-PSG_Index)/4)+1
KCVolEnv_02 equ		((ptr_kcpsg02-PSG_Index)/4)+1
KCVolEnv_03 equ		((ptr_kcpsg03-PSG_Index)/4)+1
KCVolEnv_04 equ		((ptr_kcpsg04-PSG_Index)/4)+1
KCVolEnv_05 equ		((ptr_kcpsg05-PSG_Index)/4)+1
KCVolEnv_06 equ		((ptr_kcpsg06-PSG_Index)/4)+1
KCVolEnv_07 equ		((ptr_kcpsg07-PSG_Index)/4)+1
KCVolEnv_08 equ		((ptr_kcpsg08-PSG_Index)/4)+1
KCVolEnv_09 equ		((ptr_kcpsg09-PSG_Index)/4)+1
KCVolEnv_0A equ		((ptr_kcpsg0A-PSG_Index)/4)+1
KCVolEnv_0B equ		((ptr_kcpsg0B-PSG_Index)/4)+1
KCVolEnv_0C equ		((ptr_kcpsg0C-PSG_Index)/4)+1
KCVolEnv_0D equ		((ptr_kcpsg0D-PSG_Index)/4)+1
KCVolEnv_0E equ		((ptr_kcpsg0E-PSG_Index)/4)+1
	endif

	; Insert custom equates here
