LinkLuaModifier("modifier_radiant_spell_immunity", "ability/radiant_spell_immunity.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if radiant_spell_immunity == nil then
	radiant_spell_immunity = class({})
end
function radiant_spell_immunity:GetIntrinsicModifierName()
	return "modifier_radiant_spell_immunity"
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_radiant_spell_immunity = class({
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
function modifier_radiant_spell_immunity:AllowIllusionDuplicate()
	return false
end

function modifier_radiant_spell_immunity:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
end

function modifier_radiant_spell_immunity:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_radiant_spell_immunity:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end


function modifier_radiant_spell_immunity:GetModifierMagicalResistanceBonus()
	return 100
end
function modifier_radiant_spell_immunity:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
	return state
end

function modifier_radiant_spell_immunity:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_earth_ambient.vpcf"
end

function modifier_radiant_spell_immunity:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


