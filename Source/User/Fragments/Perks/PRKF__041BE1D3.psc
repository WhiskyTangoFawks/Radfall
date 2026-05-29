;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Perks:PRKF__041BE1D3 Extends Perk Hidden Const

;BEGIN FRAGMENT Fragment_Entry_02
Function Fragment_Entry_02(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
string setting = "fLockpickXPRewardEasy"
Actor PC = Game.GetPlayer()
Key oKey = akTargetRef.GetKey()
If (oKey as bool && PC.GetItemCount(oKey as Form) > 0)
	akTargetRef.activate(PC as ObjectReference, False)
	Debug.Notification("You have the password.")
Else
	PC.EquipItem(Mentats)
                Game.IncrementStat("Computers Hacked", 1)
	Game.RewardPlayerXP(Game.GetGameSettingFloat(setting) as int, False)
	akTargetRef.lock(False, False)
	akTargetRef.activate(Game.GetPlayer() as ObjectReference, False)
	Debug.Notification("Hacked")
EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Potion Property Mentats Auto Const
