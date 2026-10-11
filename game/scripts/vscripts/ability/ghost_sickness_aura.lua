LinkLuaModifier( "modifier_ghost_sickness_aura", "ability/ghost_sickness_aura.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ghost_sickness_aura_buff", "ability/ghost_sickness_aura.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ghost_sickness_aura == nil then
	ghost_sickness_aura = class({})
end
function ghost_sickness_aura:GetIntrinsicModifierName()
	return "modifier_ghost_sickness_aura"
end
---------------------------------------------------------------------
--Modifiers

modifier_ghost_sickness_aura = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_ghost_sickness_aura:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ghost_sickness_aura:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ghost_sickness_aura:IsPurgable(params)
	return false
end
function modifier_ghost_sickness_aura:OnDestroy()
	if IsServer() then
	end
end
function modifier_ghost_sickness_aura:DeclareFunctions()
	return {
	}
end
function modifier_ghost_sickness_aura:IsAura()
	return true
end
function modifier_ghost_sickness_aura:GetModifierAura()
	return "modifier_ghost_sickness_aura_buff"
end
function modifier_ghost_sickness_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_ghost_sickness_aura:GetAuraDuration()
	return 0.3
end

function modifier_ghost_sickness_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ghost_sickness_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_ghost_sickness_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_ghost_sickness_aura:GetAuraEntityReject( hEntity )
	return false
end
--
modifier_ghost_sickness_aura_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_ghost_sickness_aura_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.damage_reduction=ability:GetSpecialValueFor("damage_reduction")
end
function modifier_ghost_sickness_aura_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
end
function modifier_ghost_sickness_aura_buff:GetModifierDamageOutgoing_Percentage()
	return - self.damage_reduction
end





