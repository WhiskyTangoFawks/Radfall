;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Perks:PRKF_Locksmith01_000523FF Extends Perk Hidden Const

;BEGIN FRAGMENT Fragment_Entry_01
Function Fragment_Entry_01(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
Actor Player = Game.GetPlayer()
Player.RemoveItem(BobbyPin, 1)
Game.IncrementStat("Locks Picked", 1)
akTargetRef.lock(False, False)
akTargetRef.activate(Player, False)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

MiscObject Property BobbyPin Auto Const

Message Property LockPickedNotification Auto Const

Perk Property Locksmith04 Auto Const
