LinkLuaModifier( "modifier_arctic_critical_strike", "ability/arctic_critical_strike.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities


arctic_critical_strike = class({})

wave_12_champion_critical_strike=arctic_critical_strike
function arctic_critical_strike:GetIntrinsicModifierName()
	return "modifier_arctic_critical_strike"
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_arctic_critical_strike = class({
	IsHidden = function(self)
		return true
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return false
	end,
	IsBuff = function(self)
		return true
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})

function modifier_arctic_critical_strike:OnCreated(params)
	local ability=self:GetAbility()
	self.crit_chance=ability:GetSpecialValueFor("crit_chance")
	self.crit_mult=ability:GetSpecialValueFor("crit_mult")
end
function modifier_arctic_critical_strike:OnRefresh(params)
	local ability=self:GetAbility()
	self.crit_chance=ability:GetSpecialValueFor("crit_chance")
	self.crit_mult=ability:GetSpecialValueFor("crit_mult")
end
function modifier_arctic_critical_strike:OnDestroy()
	if IsServer() then
	end
end

function modifier_arctic_critical_strike:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_arctic_critical_strike:GetModifierPreAttack_CriticalStrike( params )
	if RandomInt(1,100)<=self.crit_chance then
		return self.crit_mult
	end
end
