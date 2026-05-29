Scriptname IdiotSavantScript extends Perk

Event OnEntryRun(int auiEntryID, ObjectReference akTarget, Actor akOwner)
	Game.ShowPerkVaultBoyOnHUD(idiotSavantSwfName, yeah)
	Game.IncrementStat("Bright Ideas")
EndEvent

Sound Property Yeah Auto Const
string Property idiotSavantSwfName = "Components\\VaultBoys\\Perks\\PerkClip_1d245e.swf" Auto const
