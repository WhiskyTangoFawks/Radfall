Scriptname FortunateLegendary extends ObjectReference

Perk Property FortuneFinder02 Auto Const

legendaryitemquestscript Property LegendaryItemQuest Auto Const

;-- Variables ---------------------------------------
int ResetCheck = 1

Event OnReset()
	ResetCheck = 1
EndEvent

Event OnLoad()
	If (ResetCheck == 1 && Game.GetPlayer().HasPerk(FortuneFinder02))
		float chance = Self.GetLockLevel() * Self.GetLockLevel() / 312.5
					
		int rng = Utility.RandomInt(1, 100)
		If (rng as float < chance && Self.GetLockLevel() < 255)
			LegendaryItemQuest.GenerateLegendaryItem(Self as ObjectReference, None, None, None)
			Self.SetValue(LegendaryItemQuest.SpawnedLegendaryItem, 0)
		EndIf
	EndIf

	ResetCheck = 0
EndEvent