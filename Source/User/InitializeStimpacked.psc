Scriptname InitializeStimpacked extends Quest

Quest Property qMQ102 Auto Const
Perk Property HealingCapManagerPerk Auto Const

Event OnInit()
	If (qMQ102.GetCurrentStageID() > 9)
		game.getPlayer().addPerk(HealingCapManagerPerk )
	Else
		Self.RegisterForRemoteEvent(qMQ102, "OnStageSet")
	EndIf
EndEvent

Event Quest.OnStageSet(Quest akSender, int auiStageID, int auiItemID)
	If (akSender == qMQ102 && auiStageID == 10)
		utility.wait(5)
		game.getPlayer().addPerk(HealingCapManagerPerk )
	EndIf
EndEvent

GlobalVariable Property PlayerHealingCap Auto Const
