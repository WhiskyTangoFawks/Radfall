Scriptname DepletedFusionCoreQuest extends Quest

MiscObject Property DepletedFusionCore Auto Const
Perk Property NuclearPhysicist01 Auto Const

Event OnInit()
	Self.RegisterForTrackedStatsEvent("Fusion Cores Consumed", 1)
	debug.trace(self + " Starting depleted fusion core listener")
EndEvent

Event OnTrackedStatsEvent(string statName, int newValue)
	Self.RegisterForTrackedStatsEvent("Fusion Cores Consumed", newValue + 1)
	debug.trace(self + " Fusion Core depletion event caught")
	if Game.GetPlayer().hasPerk(NuclearPhysicist01)
		Game.getPlayer().addItem(DepletedFusionCore, 1, False)
		debug.trace(self + " Player has NuclearPhysicist01, giving player a depleted fusion core")
	endIF
EndEvent