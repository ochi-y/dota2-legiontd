LinkLuaModifier( "modifier_arctic_frost_aura_1", "ability/arctic_frost_aura_1.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arctic_frost_aura_1_debuff", "ability/arctic_frost_aura_1.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if arctic_frost_aura_1 == nil then
	arctic_frost_aura_1 = class({})
end
function arctic_frost_aura_1:GetIntrinsicModifierName()
	return "modifier_arctic_frost_aura_1"
end
---------------------------------------------------------------------
--Modifiers
modifier_arctic_frost_aura_1 = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_arctic_frost_aura_1:OnCreated()
	if not self:GetAbility() then return end

	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_arctic_frost_aura_1:OnRefresh()
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_arctic_frost_aura_1:IsAura()
	return true
end

function modifier_arctic_frost_aura_1:GetModifierAura()
	if not IsServer() then return end
	if self:GetParent():PassivesDisabled() then
		return nil
	else
		return "modifier_arctic_frost_aura_1_debuff"
	end
end

function modifier_arctic_frost_aura_1:GetAuraRadius()
	return self.radius
end

function modifier_arctic_frost_aura_1:GetAuraDuration()
	return 0.3
end

function modifier_arctic_frost_aura_1:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_arctic_frost_aura_1:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_arctic_frost_aura_1:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_arctic_frost_aura_1_debuff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_arctic_frost_aura_1_debuff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.slow=ability:GetSpecialValueFor("slow")
end

function modifier_arctic_frost_aura_1_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
	return funcs
end

function modifier_arctic_frost_aura_1_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end


function modifier_arctic_frost_aura_1_debuff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_cold_snap_status.vpcf"
end

function modifier_arctic_frost_aura_1_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_arctic_frost_aura_1_debuff:GetModifierAttackSpeedPercentage( params )
	return 0
end 

