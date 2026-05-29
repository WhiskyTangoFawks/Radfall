Scriptname MonitorPlayerCaps extends activemagiceffect

MiscObject Property Bottlecaps Auto Const
ActorValue Property Decapitalist Auto Const
Actor Property PlayerRef Auto Const

Struct DecapPerks
	Perk collector
	float valueCap
	float maxValue
EndStruct

DecapPerks[] Property perkList auto
FormList Property CapsFilter Auto Const



Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	setPlayerValue()
endEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	setPlayerValue()
endEvent


Event OnEffectStart(Actor akTarget, Actor akCaster)
	setPlayerValue()
	AddInventoryEventFilter(CapsFilter)
endEvent



Float Function setPlayerValue()
	debug.trace(self + ": setPlayerValue called ")
	playerRef.setValue(Decapitalist, playerRef.getItemCount(Bottlecaps))
	int i = perkList.Length-1
	while (i < perkList.Length)
		debug.trace(self + ": iterating " + i)
		if playerRef.hasPerk(perkList[i].collector)
			float value = (PerkList[i].valueCap - (playerRef.getItemCount(Bottlecaps) as float))/PerkList[i].maxValue
			debug.trace(self + ": Found Perk, value calculated as " + value)
			playerRef.setValue(Decapitalist, value)
			return value
		endIf
		i -= 1
	endWhile
	debug.trace(self + ": No Perk found")

endFunction