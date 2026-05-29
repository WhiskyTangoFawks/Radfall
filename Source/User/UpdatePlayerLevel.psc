Scriptname UpdatePlayerLevel extends Quest

ActorValue Property Level Auto Const
Actor Property PlayerRef Auto Const

Event OnStoryIncreaseLevel(int aiNewLevel)
	float playerLevel = PlayerRef.GetLevel()
	PlayerRef.SetValue(level, playerLevel /100)
	debug.trace("Player Level Variable set to " + PlayerRef.GetValue(level))
	Reset()
EndEvent