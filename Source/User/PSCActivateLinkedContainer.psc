Scriptname PSCActivateLinkedContainer extends ObjectReference

; A reference to the Master Container for this Object
ObjectReference Property MasterContainer Auto

auto STATE closedPosition
	EVENT onActivate(objectReference triggerRef)
 		gotoState("busy")
		
		; Wait for the open animation to complete.
		Utility.wait(0.5)
		
		; Activate the Master Container.
		MasterContainer.activate(Game.getPlayer())

		; Wait till the Inventory Menu closes. The wait function pauses when the game is in menu mode.
		Utility.wait(0.1)
		
		; Set the container as opened and re-activate it to end the animation.
		gotoState("openedPosition")
		Self.activate(Game.getPlayer())
	endEVENT
endSTATE

STATE busy
	EVENT onActivate(objectReference triggerRef)
		; Do Nothing.
	endEVENT
endSTATE

STATE openedPosition
	EVENT onActivate(objectReference triggerRef)
		; Perform the closing container animation and sound.
		gotoState("busy")
		Utility.wait(0.05)
		gotoState("closedPosition")
	endEVENT
endSTATE
