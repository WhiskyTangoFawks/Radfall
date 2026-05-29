Scriptname MOD_RespecPerkScript extends activemagiceffect

Message Property BeginMsg Auto
Message Property EndMsg Auto

FormList Property Perklist Auto
FormList[] Property Statslist Auto

Spell property VANS auto
Spell property PerkPainTrainCloakSpell auto
Faction Property AnimalFriend01Faction auto
Faction Property AnimalFriend02Faction auto
ActorValue Property BloodyMess Auto Const mandatory
ActorValue Property FastTravelOverEncumbered Auto Const mandatory
Armor Property CrimsomEyepatchHTG Auto Const
Armor Property Armor_SynthGlovesBARE Auto Const
GameSettingsManager Property gsm auto const

Struct ResetGlobal
	GlobalVariable gvar
	Float value
endStruct

ResetGlobal[] Property globals Auto Const

Event OnEffectFinish(Actor akTarget, Actor akCaster)

;==================== SET UP ====================

	actor player = Game.Getplayer()
	perk designatedperk
	if(akTarget == player)
		BeginMsg.Show()
		

		;==================== PROCESS - Perks ====================

			int i = 0
			while(i < Perklist.getsize())
				designatedperk = (Perklist.GetAt(i) as perk)
					if(player.hasperk(designatedperk))
							player.removeperk(designatedperk)
						debug.trace(self + " Removing Perk: " + designatedperk)
						Game.AddPerkPoints(1)
					endif
				i += 1
			endwhile

		;==================== PROCESS - Stats ====================

			i = 0
			while(i < Statslist.length)
				int j = 1
				ActorValue stat = statsList[i].getAt(0) as ActorValue
				while j < statsList[i].getSize()
					designatedperk = (statsList[i].GetAt(j) as perk)
						if(player.hasperk(designatedperk))
							debug.trace(self + " Removing Stat Training Perk: " + designatedperk)
							Game.GetPlayer().SetValue(stat, Game.Getplayer().GetBaseValue(stat)-1)
							player.removeperk(designatedperk)
							Game.AddPerkPoints(1)
						endif
					j += 1
				endWhile
				i += 1
			endwhile

		;==================== PROCESS - Global Variables ====================

			i = 0
			while(i < globals.length)
				globals[i].gvar.SetValue(globals[i].value)
				i += 1
			endwhile

		;==================== PROCESS - Quest Aliases ====================

			i = 0
			while(i < RefsToClear.length)
				RefsToClear[i].clear()
				i += 1
			endwhile

		;==================== FINALIZE ====================

		player.removespell(VANS)
		player.removespell(PerkPainTrainCloakSpell)
		player.SetValue(BloodyMess, 0 as float)
		player.SetValue(FastTravelOverEncumbered, 0)
		player.RemoveFromFaction(AnimalFriend01Faction)
		player.RemoveFromFaction(AnimalFriend02Faction)
		player.RemoveItem(CrimsomEyepatchHTG)
		player.removeItem(Armor_SynthGlovesBARE)
		HCHProvisionerTracker.stop()
		gsm.Update()
		LocksmithLevel.setValue(25)
		HackerLevel.setValue(25)
		EndMsg.Show()	
	endif

endEvent
ReferenceAlias[] Property RefsToClear Auto Const

Quest Property HCHProvisionerTracker Auto Const

GlobalVariable Property LocksmithLevel Auto Const

GlobalVariable Property HackerLevel Auto Const
