LinkLuaModifier( "modifier_ghost_mortal_strike", "ability/ghost_mortal_strike.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ghost_mortal_strike == nil then
	ghost_mortal_strike = class({})
end
function ghost_mortal_strike:GetIntrinsicModifierName()
	return "modifier_ghost_mortal_strike"
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_ghost_mortal_strike = class({
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
function modifier_ghost_mortal_strike:AllowIllusionDuplicate()
	return false
end
function modifier_ghost_mortal_strike:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.crit_mult=ability:GetSpecialValueFor("crit_mult")
end
function modifier_ghost_mortal_strike:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end
function modifier_ghost_mortal_strike:CheckState()
	local state = {
	}

	return state
end
function modifier_ghost_mortal_strike:GetModifierPreAttack_CriticalStrike( params )
	if not IsServer() then return end
	if self:GetAbility():IsCooldownReady()   then
		self:GetAbility():StartCooldown(self:GetAbility():GetEffectiveCooldown(self:GetAbility():GetLevel()))
		EmitSoundOn("Hero_SkeletonKing.CriticalStrike", self:GetParent())
		return self.crit_mult
	end
end