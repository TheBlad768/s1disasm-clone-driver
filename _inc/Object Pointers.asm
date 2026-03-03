; ---------------------------------------------------------------------------
; Object pointers
; ---------------------------------------------------------------------------

objptr:	macro label
	if "label"<>"NullObject"
		ptr_label:
		id_label:	equ ((ptr_label-Obj_Index)/4)+1
	endif
		dc.l	label
		endm

; ---------------------------------------------------------------------------

		objptr	SonicPlayer		; $01
		objptr	NullObject
		objptr	NullObject
		objptr	NullObject
		objptr	NullObject
		objptr	NullObject
		objptr	NullObject
		objptr	Splash			; $08
		objptr	SonicSpecial
		objptr	DrownCount
		objptr	Pole
		objptr	FlapDoor
		objptr	Signpost
		objptr	TitleSonic
		objptr	PSBTM
		objptr	Obj10			; $10
		objptr	Bridge
		objptr	SpinningLight
		objptr	LavaMaker
		objptr	LavaBall
		objptr	SwingingPlatform
		objptr	Harpoon
		objptr	Helix
		objptr	BasicPlatform		; $18
		objptr	Obj19
		objptr	CollapseLedge
		objptr	WaterSurface
		objptr	Scenery
		objptr	MagicSwitch
		objptr	BallHog
		objptr	Crabmeat
		objptr	Cannonball		; $20
		objptr	HUD
		objptr	BuzzBomber
		objptr	Missile
		objptr	MissileDissolve
		objptr	Rings
		objptr	Monitor
		objptr	ExplosionItem
		objptr	Animals			; $28
		objptr	Points
		objptr	AutoDoor
		objptr	Chopper
		objptr	Jaws
		objptr	Burrobot
		objptr	PowerUp
		objptr	LargeGrass
		objptr	GlassBlock		; $30
		objptr	ChainStomp
		objptr	Button
		objptr	PushBlock
		objptr	TitleCard
		objptr	GrassFire
		objptr	Spikes
		objptr	RingLoss
		objptr	ShieldItem		; $38
		objptr	GameOverCard
		objptr	GotThroughCard
		objptr	PurpleRock
		objptr	SmashWall
		objptr	BossGreenHill
		objptr	Prison
		objptr	ExplosionBomb
		objptr	MotoBug			; $40
		objptr	Springs
		objptr	Newtron
		objptr	Roller
		objptr	EdgeWalls
		objptr	SideStomp
		objptr	MarbleBrick
		objptr	Bumper
		objptr	BossBall		; $48
		objptr	WaterSound
		objptr	VanishSonic
		objptr	GiantRing
		objptr	GeyserMaker
		objptr	LavaGeyser
		objptr	LavaWall
		objptr	Obj4F
		objptr	Yadrin			; $50
		objptr	SmashBlock
		objptr	MovingBlock
		objptr	CollapseFloor
		objptr	LavaTag
		objptr	Basaran
		objptr	FloatingBlock
		objptr	SpikeBall
		objptr	BigSpikeBall		; $58
		objptr	Elevator
		objptr	CirclingPlatform
		objptr	Staircase
		objptr	Pylon
		objptr	Fan
		objptr	Seesaw
		objptr	Bomb
		objptr	Orbinaut		; $60
		objptr	LabyrinthBlock
		objptr	Gargoyle
		objptr	LabyrinthConvey
		objptr	Bubble
		objptr	Waterfall
		objptr	Junction
		objptr	RunningDisc
		objptr	Conveyor		; $68
		objptr	SpinPlatform
		objptr	Saws
		objptr	ScrapStomp
		objptr	VanishPlatform
		objptr	Flamethrower
		objptr	Electro
		objptr	SpinConvey
		objptr	Girder			; $70
		objptr	Invisibarrier
		objptr	Teleport
		objptr	BossMarble
		objptr	BossFire
		objptr	BossSpringYard
		objptr	BossBlock
		objptr	BossLabyrinth
		objptr	Caterkiller		; $78
		objptr	Lamppost
		objptr	BossStarLight
		objptr	BossSpikeball
		objptr	RingFlash
		objptr	HiddenBonus
		objptr	SSResult
		objptr	SSRChaos
		objptr	ContScrItem		; $80
		objptr	ContSonic
		objptr	ScrapEggman
		objptr	FalseFloor
		objptr	EggmanCylinder
		objptr	BossFinal
		objptr	BossPlasma
		objptr	EndSonic
		objptr	EndChaos		; $88
		objptr	EndSTH
		objptr	CreditsText
		objptr	EndEggman
		objptr	TryChaos

; ---------------------------------------------------------------------------

NullObject:
	if FixBugs
		; It would be safer to have this instruction here, otherwise it would just fall through to ObjectFall
		jmp	(DeleteObject).l
	endif
