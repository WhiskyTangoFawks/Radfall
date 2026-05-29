Scriptname DowngradeOMOD extends activemagiceffect

ObjectMod Property brokenOmod Auto Const
ObjectMod Property DowngradeMod Auto Const
Actor Property PlayerRef Auto Const
Container Property LootBag Auto Const
ActorValue Property DegradeChance Auto Const
Sound Property BreakingSound Auto Const

Event OnEffectStart(actor akTarget, actor akCaster)
	debug.Trace(self + " Player equipped a downgradable weapon")
	self.RegisterForAnimationEvent(PlayerRef, "weaponFire")
	self.RegisterForAnimationEvent(PlayerRef, "weaponSwing")

EndEvent

Event OnEffectFinish(actor akTarget, actor akCaster)
	self.UnregisterForAnimationEvent(akCaster, "weaponFire")
	self.RegisterForAnimationEvent(PlayerRef, "weaponSwing")
EndEvent

Event OnAnimationEvent(objectreference akSource, String asEventName)
	If (asEventName == "weaponFire"  || asEventName == "weaponSwing") && utility.RandomInt(0, PlayerRef.getValue(DegradeChance) as int) == 0
		DamagePlayerWeapon()
		utility.wait(0.25)
		BreakingSound.Play(PlayerREF)
		NotifyPlayerOfWeaponDamage()
	endIf
EndEvent


Function DamagePlayerWeapon()
	weapon akWeapon = playerRef.GetEquippedWeapon(0)
	if playerRef.GetItemCount(akWeapon) == 1
		debug.Trace(self + " Single copy of weapon found, attaching mod to inventory item");
		playerRef.attachModToInventoryItem(akWeapon, brokenOmod)
		playerRef.attachModToInventoryItem(akWeapon, DowngradeMod)
	Else
		debug.Trace(self + " Multiple copies of weapon found, playing the shell game");
		;Due to not being able to add mods to an equipped weapon when the player has a copy of the weapon, we have to play a shell game
		objectreference portableHole = playerRef.PlaceAtMe(LootBag, 1, false, false, true)
		playerRef.RemoveItem(akWeapon, 1, true, portableHole) ; put the players equppped weapon in the container
		playerRef.unequipItem(akWeapon, false, true)
		portableHole.attachModToInventoryItem(akWeapon, brokenOmod) ;attach the omod
		portableHole.attachModToInventoryItem(akWeapon, DowngradeMod) ;attach the omod
		objectreference objWeapon = portableHole.DropObject(akWeapon, 1);put it on the ground
		;TODO - is this necessary?
		objWeapon.EnableNoWait(false)
		playerRef.RemoveItem(akWeapon, -1, true, portableHole);put all the players copies of that weapon in the container
		;TODO - do I have to activate, or can I just add back to the player?
		objWeapon.Activate(playerRef, true);player grabs weapon
		playerRef.EquipItem(akWeapon, false, true);
		portableHole.RemoveItem(akWeapon, -1, true, playerRef);give the player back their copies
		portableHole.Disable(false)
		portableHole.DeleteWhenAble()
	endIf
EndFunction


Function NotifyPlayerOfWeaponDamage()
	Debug.notification("Your weapon condition has degraded")
endFunction





