LinkLuaModifier( "modifier_orc_greater_healing_aura", "ability/orc_greater_healing_aura.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_orc_greater_healing_aura_buff", "ability/orc_greater_healing_aura.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if orc_greater_healing_aura == nil then
	orc_greater_healing_aura = class({})
end
function orc_greater_healing_aura:GetIntrinsicModifierName()
	return "modifier_orc_greater_healing_aura"
end
---------------------------------------------------------------------
--Modifiers

modifier_orc_greater_healing_aura = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_orc_greater_healing_aura:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_orc_greater_healing_aura:OnRefresh(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_orc_greater_healing_aura:OnDestroy()
	if IsServer() then
	end
end
function modifier_orc_greater_healing_aura:DeclareFunctions()
	return {
	}
end
function modifier_orc_greater_healing_aura:IsAura()
	return true
end
function modifier_orc_greater_healing_aura:GetModifierAura()
	return "modifier_orc_greater_healing_aura_buff"
end
function modifier_orc_greater_healing_aura:GetAuraRadius()
	local radius=self.radius
	return radius
end

function modifier_orc_greater_healing_aura:GetAuraDuration()
	return 1
end

function modifier_orc_greater_healing_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_orc_greater_healing_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_orc_greater_healing_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_orc_greater_healing_aura:GetAuraEntityReject( hEntity )
	return false
end
--
modifier_orc_greater_healing_aura_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_orc_greater_healing_aura_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.hp_regen=ability:GetSpecialValueFor("hp_regen")
end

function modifier_orc_greater_healing_aura_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end

function modifier_orc_greater_healing_aura_buff:GetModifierConstantHealthRegen()
	return self.hp_regen
end





