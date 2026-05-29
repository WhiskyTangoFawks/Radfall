Scriptname BlackWidowListener extends activemagiceffect

SPELL Property BlackWidowFortifyCharisma Auto Const


Event OnKill(Actor akVictim)
	BlackWidowFortifyCharisma.cast(Game.GetPlayer())
EndEvent
