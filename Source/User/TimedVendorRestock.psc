Scriptname TimedVendorRestock extends ObjectReference

Form Property Caps001 Auto Const
Container Property HolderContainer Auto Const

GlobalVariable Property iAvgHoursVendorRestock Auto Const
GlobalVariable Property iAvgVendorRestockPercent Auto Const

;-------------------------------------------------------------------------

bool bTimerRunning = false

;-------------------------------------------------------------------------

Event OnLoad()
	if !bTimerRunning
		debug.trace("Starting timer onLoad for: " + GetBaseObject().getFormId())
		StartVendorRestockTimer()
	endIf
EndEvent

Event OnTimerGameTime(int aiTimerID)
  If aiTimerID == GetBaseObject().getFormId()
    bTimerRunning = false
	debug.trace("Vender restock timer expired: " + GetBaseObject().getFormId())
	RestockVendor()
	StartVendorRestockTimer()
  EndIf
EndEvent

Function StartVendorRestockTimer()
	;start a timer with +/- 50% of average
	int min = iAvgHoursVendorRestock.getValueInt() - (iAvgHoursVendorRestock.getValueInt()/2)
	int max = iAvgHoursVendorRestock.getValueInt() + (iAvgHoursVendorRestock.getValueInt()/2)
	int iHoursToRespawn =  utility.RandomInt(min, max)
  	StartTimerGameTime(iHoursToRespawn, GetBaseObject().getFormId())
	bTimerRunning = true
	debug.trace("Started timer for vendor restock: " + iHoursToRespawn + "hours, " + GetBaseObject().getFormId())
endFunction

function RestockVendor()
	ObjectReference holderRef = placeAtMe(HolderContainer, 1, false, true, false)
	
	;treat caps as a number, not as an item
	float vendorCaps = GetItemCount(caps001) as float
	debug.trace(self + "RestockVendor() Getting vendor starting caps count: " + vendorCaps + " for vendor " +  GetBaseObject().getFormId())
	
	self.RemoveAllItems(holderRef)
	reset()

	float restockCaps = GetItemCount(caps001) as float

	float capsRatio = vendorCaps / restockCaps
	float restockRate = iAvgVendorRestockPercent.getValue()/100.0
	float sellRate =  capsRatio * restockRate

	debug.trace(self + "RestockVendor(): " + vendorCaps + "/" + restockCaps + " * " + restockRate + "=" + sellRate + " for vendor:" +  GetBaseObject().getFormId())
	
	if sellRate > 0.9 
		sellRate = 0.9
	elseIf sellRate < 0.1
		sellRate = 0.1
	endIf

	;Get rid of the inverse percentage of the new inventory
	moveContainerPercentage(self, none, 1-sellRate)

	;Add percentage of inventory inventory back
	moveContainerPercentage(holderRef, self, sellRate)

	holderRef.RemoveAllItems()
	holderRef.Disable(false)
	holderRef.DeleteWhenAble()

	StartVendorRestockTimer()
endFunction

function moveContainerPercentage(ObjectReference source, ObjectReference sink, float moveRatio)
	debug.trace(self + "moveContainerPercentage() moving " + moveRatio + " percent from "  + source + " to " + sink)
	Form[] inventory = source.GetInventoryItems()
	int i = 0
	while (i < inventory.length)
		int j = getItemCount(inventory[i])
		float fMove = j*moveRatio
		float fRem = fMove - Math.floor(fMove)
		int iMove = Math.floor(fMove) as int
		
		debug.trace(self + " moving " + inventory[i] + ", " + iMove + "x, remainder " + fRem)
		removeItem(inventory[i], iMove, true, sink)
		
		if utility.RandomFloat(0, 1) > fRem
			debug.trace(self + "moveContainerPercentage() remainder item moved " +  inventory[i])
			removeItem(inventory[i], 1, true, sink)
		else 
			debug.trace(self + "moveContainerPercentage() remainder item left " + inventory[i])
		endIf
				

		i += 1
	endWhile
endFunction