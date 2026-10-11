LinkLuaModifier( "modifier_ability_wave_elite", "ability/ability_wave_elite.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_wave_elite == nil then
	ability_wave_elite = class({})
end
function ability_wave_elite:GetIntrinsicModifierName()
	return "modifier_ability_wave_elite"
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_ability_wave_elite = class({
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
function modifier_ability_wave_elite:AllowIllusionDuplicate()
	return false
end
function modifier_ability_wave_elite:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 

	local ability=self:GetAbility()
	self.bonus_armor=ability:GetSpecialValueFor("bonus_armor")
	self.bonus_health=ability:GetSpecialValueFor("bonus_health")
end
function modifier_ability_wave_elite:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_ability_wave_elite:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE
	}
end
function modifier_ability_wave_elite:GetModifierModelScale( params )
	return 10
end

function modifier_ability_wave_elite:GetModifierExtraHealthPercentage()
	return self.bonus_health
end
function modifier_ability_wave_elite:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_ability_wave_elite:CheckState()
	local state = {
	}
	return state
end
function modifier_ability_wave_elite:GetEffectName()
	return "particles/items5_fx/helm_of_the_dominator_buff.vpcf"
end
function modifier_ability_wave_elite:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
