LinkLuaModifier("modifier_mech_vital_slice", "ability/mech_vital_slice.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if mech_vital_slice == nil then
	mech_vital_slice = class({})
end
function mech_vital_slice:GetIntrinsicModifierName()
	return "modifier_mech_vital_slice"
end

radiant_blade_dance = mech_vital_slice
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_mech_vital_slice = class({
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

function modifier_mech_vital_slice:OnCreated(params)
	local ability = self:GetAbility()
	self.crit_chance = ability:GetSpecialValueFor("blade_dance_crit_chance")
	self.crit_mult = ability:GetSpecialValueFor("blade_dance_crit_mult")
end

function modifier_mech_vital_slice:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_mech_vital_slice:OnDestroy()
	if IsServer() then
	end
end

function modifier_mech_vital_slice:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_mech_vital_slice:GetModifierPreAttack_CriticalStrike(params)
	if RandomInt(1, 100) <= self.crit_chance then

		if self:GetAbility():GetAbilityName()=="radiant_blade_dance" then
			EmitSoundOn("Hero_Juggernaut.BladeDance", self:GetCaster())	
		end
		return self.crit_mult
	end
end
