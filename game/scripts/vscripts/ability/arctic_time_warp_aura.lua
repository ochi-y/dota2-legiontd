LinkLuaModifier( "modifier_arctic_time_warp_aura", "ability/arctic_time_warp_aura.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arctic_time_warp_aura_buff", "ability/arctic_time_warp_aura.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if arctic_time_warp_aura == nil then
	arctic_time_warp_aura = class({})
end
function arctic_time_warp_aura:GetIntrinsicModifierName()
	return "modifier_arctic_time_warp_aura"
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_arctic_time_warp_aura = class({
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
function modifier_arctic_time_warp_aura:AllowIllusionDuplicate()
	return false
end
function modifier_arctic_time_warp_aura:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
	if not self:GetAbility() then return end

	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
	self.bonus_cdr=ability:GetSpecialValueFor("bonus_cdr")



end
function modifier_arctic_time_warp_aura:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_arctic_time_warp_aura:DeclareFunctions()
	return {

	}
end

function modifier_arctic_time_warp_aura:IsAura()
	return true
end
function modifier_arctic_time_warp_aura:GetAuraRadius()
	return self.radius
end
function modifier_arctic_time_warp_aura:GetAuraEntityReject(unit)
	return false
end
function modifier_arctic_time_warp_aura:GetAuraDuration()
	return 0
end
function modifier_arctic_time_warp_aura:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_arctic_time_warp_aura:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end
function modifier_arctic_time_warp_aura:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end
function modifier_arctic_time_warp_aura:GetModifierAura()
	return "modifier_arctic_time_warp_aura_buff"
end

-------------------------------------------------------------------------------------------------------
modifier_arctic_time_warp_aura_buff = class({
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
function modifier_arctic_time_warp_aura_buff:AllowIllusionDuplicate()
	return false
end
function modifier_arctic_time_warp_aura_buff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
	self.bonus_cdr=ability:GetSpecialValueFor("bonus_cdr")
	self.mana_cost_reduction=ability:GetSpecialValueFor("mana_cost_reduction")
end
function modifier_arctic_time_warp_aura_buff:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_arctic_time_warp_aura_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE ,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING
	}
end
function modifier_arctic_time_warp_aura_buff:CheckState()
	local state = {
	}
	return state
end
function modifier_arctic_time_warp_aura_buff:GetModifierPercentageCooldown()
	return self.bonus_cdr
end

function modifier_arctic_time_warp_aura_buff:GetModifierPercentageManacostStacking()
    return self.mana_cost_reduction
end

