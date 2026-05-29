;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Quests:QF_DegradationQuest_03004B83 Extends Quest Hidden Const

;BEGIN FRAGMENT Fragment_Stage_0000_Item_00
Function Fragment_Stage_0000_Item_00()
;BEGIN CODE
game.getPlayer().addPerk(DegredationPerk)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0010_Item_00
Function Fragment_Stage_0010_Item_00()
;BEGIN CODE
ModScrapScalar_MoreDamage1.setValue(2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0020_Item_00
Function Fragment_Stage_0020_Item_00()
;BEGIN CODE
ModScrapScalar_MoreDamage2.setValue(1.75)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Stage_0030_Item_00
Function Fragment_Stage_0030_Item_00()
;BEGIN CODE
ModScrapScalar_MoreDamage3.setValue(1.5)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property ModScrapScalar_MoreDamage1 Auto Const

GlobalVariable Property ModScrapScalar_MoreDamage2 Auto Const

GlobalVariable Property ModScrapScalar_MoreDamage3 Auto Const

Perk Property DegredationPerk Auto Const
