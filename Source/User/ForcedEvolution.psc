Scriptname ForcedEvolution extends activemagiceffect

ActorValue Property Strength Auto Const
ActorValue Property Charisma Auto Const

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Game.GetPlayer().SetValue(Strength, Game.Getplayer().GetBaseValue(Strength)+2)
	Game.GetPlayer().SetValue(Charisma, Game.Getplayer().GetBaseValue(Charisma)-1)
endEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	Game.GetPlayer().SetValue(Strength, Game.Getplayer().GetBaseValue(Strength)-2)
	Game.GetPlayer().SetValue(Charisma, Game.Getplayer().GetBaseValue(Charisma)+1)
endEvent