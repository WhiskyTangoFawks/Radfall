Scriptname setRecipeGlobal extends activemagiceffect

GlobalVariable Property GlobalToSet Auto Const

Message Property MessageToShow Auto Const

Event OnEffectStart(Actor akTarget, Actor akCaster)
	if (GlobalToSet.getValue() != 1 && akTarget == Game.getPlayer())
		GlobalToSet.setValue(1)
		MessageToShow.show()	
	endIf
endEvent