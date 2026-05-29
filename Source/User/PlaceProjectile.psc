Scriptname PlaceProjectile extends ObjectReference Const

PROJECTILE Property toPlace Auto Const

Event OnLoad()
	If isDisabled()
		debug.trace(self + "Skipping stash Replace because already disabled ")
		return 
	EndIf

	debug.Trace(self + "Placing " + toPlace )
	self.placeAtMe(toPlace, 1, False, False, True)

	self.Disable(false)
	self.Delete()

EndEvent