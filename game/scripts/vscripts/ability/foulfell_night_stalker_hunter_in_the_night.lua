LinkLuaModifier("modifier_foulfell_night_stalker_hunter_in_the_night",
	"ability/foulfell_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_foulfell_night_stalker_hunter_in_the_night_buff",
	"ability/foulfell_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if foulfell_night_stalker_hunter_in_the_night == nil then
	foulfell_night_stalker_hunter_in_the_night = class({})
end
function foulfell_night_stalker_hunter_in_the_night:GetIntrinsicModifierName()
	return "modifier_foulfell_night_stalker_hunter_in_the_night"
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_night_stalker_hunter_in_the_night = class({
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
function modifier_foulfell_night_stalker_hunter_in_the_night:AllowIllusionDuplicate()
	return false
end

function modifier_foulfell_night_stalker_hunter_in_the_night:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()

	if not IsServer() then return end

	self:StartIntervalThink(0.3)
end

function modifier_foulfell_night_stalker_hunter_in_the_night:OnIntervalThink(params)
	local caster = self:GetCaster()
	if GameRules:IsDaytime() then
		if caster:HasModifier("modifier_foulfell_night_stalker_hunter_in_the_night_buff") then
			caster:RemoveModifierByName("modifier_foulfell_night_stalker_hunter_in_the_night_buff")
		end
	else
		if not caster:HasModifier("modifier_foulfell_night_stalker_hunter_in_the_night_buff") then
			caster: AddNewModifier(caster, self:GetAbility(), "modifier_foulfell_night_stalker_hunter_in_the_night_buff", {})
		end
	end
end

function modifier_foulfell_night_stalker_hunter_in_the_night:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_night_stalker_hunter_in_the_night:DeclareFunctions()
	return {

	}
end

function modifier_foulfell_night_stalker_hunter_in_the_night:CheckState()
	local state = {
	}
	return state
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_night_stalker_hunter_in_the_night_buff = class({
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
function modifier_foulfell_night_stalker_hunter_in_the_night_buff:AllowIllusionDuplicate()
	return false
end

function modifier_foulfell_night_stalker_hunter_in_the_night_buff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.bonus_movement_speed_pct_night = ability:GetSpecialValueFor("bonus_movement_speed_pct_night")
	self.bonus_attack_speed_night = ability:GetSpecialValueFor("bonus_attack_speed_night")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_foulfell_night_stalker_hunter_in_the_night_buff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_night_stalker_hunter_in_the_night_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_foulfell_night_stalker_hunter_in_the_night_buff:GetModifierAttackSpeedPercentage(params)
	return self.bonus_attack_speed_night
end

function modifier_foulfell_night_stalker_hunter_in_the_night_buff:GetModifierMoveSpeedBonus_Percentage(params)
	return self.bonus_movement_speed_pct_night
end

function modifier_foulfell_night_stalker_hunter_in_the_night_buff:CheckState()
	local state = {
	}
	return state
end

function modifier_foulfell_night_stalker_hunter_in_the_night_buff:GetEffectName()
	return "particles/legiontd/nightstalker_dark_buff.vpcf"
end

function modifier_foulfell_night_stalker_hunter_in_the_night_buff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
