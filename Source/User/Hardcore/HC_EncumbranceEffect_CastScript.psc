Scriptname Hardcore:HC_EncumbranceEffect_CastScript extends ActiveMagicEffect

Group Data
spell Property SpellToCast const auto mandatory
{HC_EncumbranceEffect_DamagePlayer}

float Property CastTimerInterval = 45.0 const auto
{how often should we cast the spell on the actor}

message Property MessageToDisplay const auto mandatory
ActorValue Property Fatigue Auto Const
ActorValue Property Strength Auto Const
Float Property BaseCarryWeight Auto Const
Float Property DamageMultiplier Auto Const
ActorValue Property Health Auto Const

;these can be set from .esp, easier to modify .esp via xEdit than compiling .pex
float Property MaxFatigue Const Auto; Maximum fatigue value, should not be crossed, can change if is not 1000 for some reason; set to 999 to be safe due to floating points
float Property RemainderFatigue Const Auto; Minimum proportion of AP the encumbrance damage will leave you with, rest will roll-over into health damage, default 50 leaves 5% AP remaining before damaging health
float Property RolloverMultiplier Const Auto; Ratio of fatigue damage to health damage, default at 0.1 so health damage will be balanced at 1/10 of fatigue damage
EndGroup

Event OnEffectStart(Actor akTarget, Actor akCaster) 
	startTimer(CastTimerInterval)
EndEvent

Function CastSpellAndStartTimer()
	if IsBoundGameObjectAvailable() ;is effect still running on a legit object?
		actor actorRef = GetTargetActor()
		float WithoutBonus = BaseCarryWeight + 10 * actorRef.getValue(Strength)
		float over = actorRef.getInventoryWeight() - WithoutBonus
		over = over * DamageMultiplier
		float excess = over + actorRef.getValue(fatigue) - (MaxFatigue - RemainderFatigue)

		if excess < 0 
			; no excess damage
			SpellToCast.cast(actorRef, actorRef)
			MessageToDisplay.show()
			actorRef.DamageValue(Fatigue, over)
		else
			SpellToCast.cast(actorRef, actorRef)
			MessageToDisplay.show()
			actorRef.DamageValue(Fatigue, (over-excess))
			actorRef.DamageValue(Health, RolloverMultiplier * excess)
		endIf
		startTimer(CastTimerInterval)
	endif
EndFunction

Event OnTimer(int aiTimerID)
	CastSpellAndStartTimer()
EndEvent




