; DAC Equates

dac__First equ __ST_SampleID+1

	if SMPS_S1DACSamples|SMPS_S2DACSamples
; Sonic 1 & 2
dKick equ			dac81.id
dSnare equ			dac82.id
dTimpani equ			dac85.id
dHiTimpani equ			dac88.id
dMidTimpani equ			dac89.id
dLowTimpani equ			dac8A.id
dVLowTimpani equ		dac8B.id
	endif

	if SMPS_S2DACSamples
; Sonic 2
dClap equ			dac83.id
dScratch equ			dac84.id
dHiTom equ			dac86.id
dVLowBongo equ			dac87.id
dMidTom equ			dac8C.id
dLowTom equ			dac8D.id
dFloorTom equ			dac8E.id
dHighBongo equ			dac8F.id
dMidBongo equ			dac90.id
dLowBongo equ			dac91.id

dHiClap equ			dHighBongo
dMidClap equ			dMidBongo
dLowClap equ			dLowBongo
	endif

	if SMPS_S3DACSamples|SMPS_SKDACSamples|SMPS_S3DDACSamples
; Sonic 3 & K & 3D
dSnareS3 equ			dac92.id
dHighTom equ			dac93.id
dMidTomS3 equ			dac94.id
dLowTomS3 equ			dac95.id
dFloorTomS3 equ			dac96.id
dKickS3 equ			dac97.id
dMuffledSnare equ		dac98.id
dCrashCymbal equ		dac99.id
dRideCymbal equ			dac9A.id
dLowMetalHit equ		dac9B.id
dMetalHit equ			dac9C.id
dHighMetalHit equ		dac9D.id
dHigherMetalHit equ		dac9E.id
dMidMetalHit equ		dac9F.id
dClapS3 equ			dacA0.id
dElectricHighTom equ		dacA1.id
dElectricMidTom equ		dacA2.id
dElectricLowTom equ		dacA3.id
dElectricFloorTom equ		dacA4.id
dTightSnare equ			dacA5.id
dMidpitchSnare equ		dacA6.id
dLooseSnare equ			dacA7.id
dLooserSnare equ		dacA8.id
dHiTimpaniS3 equ		dacA9.id
dLowTimpaniS3 equ		dacAA.id
dMidTimpaniS3 equ		dacAB.id
dQuickLooseSnare equ		dacAC.id
dClick equ			dacAD.id
dPowerKick equ			dacAE.id
dQuickGlassCrash equ		dacAF.id
	endif

	if SMPS_S3DACSamples|SMPS_SKDACSamples
; Sonic 3 & K
dGlassCrashSnare equ		dacB0.id
dGlassCrash equ			dacB1.id
dGlassCrashKick equ		dacB2.id
dQuietGlassCrash equ		dacB3.id
dOddSnareKick equ		dacB4.id
dKickExtraBass equ		dacB5.id
dComeOn equ			dacB6.id
dDanceSnare equ			dacB7.id
dLooseKick equ			dacB8.id
dModLooseKick equ		dacB9.id
dWoo equ			dacBA.id
dGo equ				dacBB.id
dSnareGo equ			dacBC.id
dPowerTom equ			dacBD.id
dHiWoodBlock equ		dacBE.id
dLowWoodBlock equ		dacBF.id
dHiHitDrum equ			dacC0.id
dLowHitDrum equ			dacC1.id
dMetalCrashHit equ		dacC2.id
dEchoedClapHit equ		dacC3.id
dLowerEchoedClapHit equ		dacC4.id
dHipHopHitKick equ		dacC5.id
dHipHopHitPowerKick equ		dacC6.id
dBassHey equ			dacC7.id
dDanceStyleKick equ		dacC8.id
dHipHopHitKick2 equ		dacC9.id
dReverseFadingWind equ		dacCA.id
dScratchS3 equ			dacCB.id
dLooseSnareNoise equ		dacCC.id
dPowerKick2 equ			dacCD.id
dCrashingNoiseWoo equ		dacCE.id
dQuickHit equ			dacCF.id
dKickHey equ			dacD0.id
dPowerKickHit equ		dacD1.id
dLowPowerKickHit equ		dacD2.id
dLowerPowerKickHit equ		dacD3.id
dLowestPowerKickHit equ		dacD4.id

dHipHopHitKick3 equ 		dHipHopHitKick2
	endif

	if SMPS_S3DDACSamples
; Sonic 3D
dFinalFightMetalCrash equ	dacD5.id
dIntroKick equ			dacD6.id
	endif

	if SMPS_S3DACSamples
; Sonic 3
dEchoedClapHit_S3 equ		dacD7.id
dLowerEchoedClapHit_S3 equ	dacD8.id
	endif

	if SMPS_SCDACSamples
; Sonic Crackers
dBeat equ			dacD9.id
dSnareSC equ			dacDA.id
dHiTimTom equ			dacDB.id
dMidTimTom equ			dacDC.id
dLowTimTom equ			dacDD.id
dLetsGo equ			dacDE.id
dHey equ			dacDF.id
	endif

dSega equ			dacE0.id

dac__Last equ dSega
