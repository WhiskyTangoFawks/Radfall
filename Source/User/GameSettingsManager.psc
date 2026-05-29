Scriptname GameSettingsManager extends Quest

Perk Property PainTrain02 Auto Const
Perk Property PainTrain04 Auto Const
Actor Property PlayerRef Auto Const


Event OnQuestInit()
  RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
EndEvent

Event Actor.OnPlayerLoadGame(Actor ActorRef)
	Update()
EndEvent

Function update()
	debug.trace(self + ": Updating game settings ")
	
	if playerref.hasPerk(Paintrain02)
		debug.trace(self + ": Paintrain02 found")
		Game.setGameSettingFloat("fPowerArmorPowerDrainPerSecondRunning", 0.025)
		debug.trace(self + ": fPowerArmorPowerDrainPerSecondRunning=" + Game.getGameSettingFloat("fPowerArmorPowerDrainPerSecondRunning"))
	elseif playerref.hasPerk(Paintrain04)
		debug.trace(self + ": Paintrain04 found")
		Game.setGameSettingFloat("fPowerArmorPowerDrainPerSecondRunning", 0.016)
		debug.trace(self + ": fPowerArmorPowerDrainPerSecondRunning=" + Game.getGameSettingFloat("fPowerArmorPowerDrainPerSecondRunning"))
	else 	
		debug.trace(self + ": Paintrain02 and Paintrain04 not found")
		Game.setGameSettingFloat("fPowerArmorPowerDrainPerSecondRunning", 0.05)
		debug.trace(self + ": fPowerArmorPowerDrainPerSecondRunning=" + Game.getGameSettingFloat("fPowerArmorPowerDrainPerSecondRunning"))
	endif

endFunction
