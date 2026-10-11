LinkLuaModifier("modifier_radiant_air_defense", "ability/radiant_air_defense.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if radiant_air_defense == nil then
	radiant_air_defense = class({})
end
function radiant_air_defense:GetIntrinsicModifierName()
	return "modifier_radiant_air_defense"
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_radiant_air_defense = class({
	IsHidden = function(self)
		return false
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
function modifier_radiant_air_defense:AllowIllusionDuplicate()
	return false
end

function modifier_radiant_air_defense:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.bonus_attack_range = ability:GetSpecialValueFor("bonus_attack_range")
	if not IsServer() then return end
end

function modifier_radiant_air_defense:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_radiant_air_defense:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}
end

function modifier_radiant_air_defense:GetModifierAttackRangeBonus(params)
	if not IsServer() then return end
	local target = self:GetCaster():GetAggroTarget()
	if target and target:HasFlyMovementCapability() then
		return self.bonus_attack_range
	else
		return 0
	end
end
