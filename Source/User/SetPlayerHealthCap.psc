Scriptname SetPlayerHealthCap extends activemagiceffect

GlobalVariable Property PlayerHealingCap Auto Const
Float Property ValueToSet Auto Const

Event OnEffectStart(Actor akTarget, Actor akCaster)
	PlayerHealingCap.setValue(ValueToSet)
endEvent