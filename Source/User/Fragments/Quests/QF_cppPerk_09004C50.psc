;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Quests:QF_cppPerk_09004C50 Extends Quest Hidden Const

;BEGIN FRAGMENT Fragment_Stage_0020_Item_00
Function Fragment_Stage_0020_Item_00()
;BEGIN CODE
if game.getPlayer().hasPerk(Chemist[1])
     cppChemist[0].setValue(1)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0030_Item_00
Function Fragment_Stage_0030_Item_00()
;BEGIN CODE
if game.getPlayer().hasPerk(Chemist[2])
     cppChemist[1].setValue(1)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0040_Item_00
Function Fragment_Stage_0040_Item_00()
;BEGIN CODE
if game.getPlayer().hasPerk(Chemist[3])
     cppChemist[2].setValue(1)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0110_Item_00
Function Fragment_Stage_0110_Item_00()
;BEGIN CODE
if game.getPlayer().hasPerk(SynthBody[0])
     ObjectReference ref = game.getPlayer().placeAtMe(SynthBodyArmor[0])
     SynthBodyParts[0].ForceRefTo(ref)
     Game.getPlayer().addItem(ref)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0120_Item_00
Function Fragment_Stage_0120_Item_00()
;BEGIN CODE
if game.getPlayer().hasPerk(SynthBody[1])
     ObjectReference ref = game.getPlayer().placeAtMe(SynthBodyArmor[1])
     SynthBodyParts[1].ForceRefTo(ref)
     Game.getPlayer().addItem(ref)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0210_Item_00
Function Fragment_Stage_0210_Item_00()
;BEGIN CODE
if game.getPlayer().hasPerk(FortuneFinder01)
     CPP_FortuneFinder1.setValue(chanceFF1)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0310_Item_00
Function Fragment_Stage_0310_Item_00()
;BEGIN CODE
if game.getPlayer().hasPerk(Scrounger[0])
     CPP_Scrounger1.setValue(chanceScrounger1)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0320_Item_00
Function Fragment_Stage_0320_Item_00()
;BEGIN CODE
if game.getPlayer().hasPerk(Scrounger[1])
     CPP_Scrounger2.setValue(chanceScrounger2)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0410_Item_00
Function Fragment_Stage_0410_Item_00()
;BEGIN CODE
if game.getPlayer().hasPerk(Scrapper03)
     ScrapperRareChance.setValue(0)
endIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0510_Item_00
Function Fragment_Stage_0510_Item_00()
;BEGIN CODE
LocksmithLevel.setValue(50)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0520_Item_00
Function Fragment_Stage_0520_Item_00()
;BEGIN CODE
LocksmithLevel.setValue(75)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0530_Item_00
Function Fragment_Stage_0530_Item_00()
;BEGIN CODE
LocksmithLevel.setValue(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0610_Item_00
Function Fragment_Stage_0610_Item_00()
;BEGIN CODE
HackerLevel.setValue(50)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0620_Item_00
Function Fragment_Stage_0620_Item_00()
;BEGIN CODE
HackerLevel.setValue(75)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0630_Item_00
Function Fragment_Stage_0630_Item_00()
;BEGIN CODE
HackerLevel.setValue(100)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable[] Property cppChemist Auto Const
ReferenceAlias[] Property SynthBodyParts Auto Const
Armor[] Property SynthBodyArmor Auto Const
GlobalVariable Property CPP_Scrounger1 Auto Const
GlobalVariable Property CPP_Scrounger2 Auto Const
GlobalVariable Property CPP_FortuneFinder1 Auto Const
Float Property chanceFF1 Auto Const
Float Property chanceScrounger1 Auto Const
Float Property chanceScrounger2 Auto Const
Perk[] Property SynthBody Auto Const
Perk[] Property Chemist Auto Const
Perk Property FortuneFinder01 Auto Const
Perk[] Property Scrounger Auto Const
Armor Property GumshoeArmorBonus Auto Const

Actor Property PlayerRef Auto Const

Perk Property Scrapper02 Auto Const

Perk Property Scrapper03 Auto Const

GlobalVariable Property ScrapperUncommonChance Auto Const

GlobalVariable Property ScrapperRareChance Auto Const

GlobalVariable Property LocksmithLevel Auto Const

GlobalVariable Property HackerLevel Auto Const
