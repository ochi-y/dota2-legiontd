LinkLuaModifier( "modifier_barrack_resilience_aura", "ability/barrack_resilience_aura.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_barrack_resilience_aura_buff", "ability/barrack_resilience_aura.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if barrack_resilience_aura == nil then
	barrack_resilience_aura = class({})
end
function barrack_resilience_aura:GetIntrinsicModifierName()
	return "modifier_barrack_resilience_aura"
end
---------------------------------------------------------------------
--Modifiers

modifier_barrack_resilience_aura = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_barrack_resilience_aura:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")

end
function modifier_barrack_resilience_aura:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_barrack_resilience_aura:OnDestroy()
	if IsServer() then
	end
end
function modifier_barrack_resilience_aura:DeclareFunctions()
	return {
	}
end
function modifier_barrack_resilience_aura:IsAura()
	return true
end
function modifier_barrack_resilience_aura:GetModifierAura()
	return "modifier_barrack_resilience_aura_buff"
end
function modifier_barrack_resilience_aura:GetAuraRadius()
	return self.radius
end

function modifier_barrack_resilience_aura:GetAuraDuration()
	return 0
end

function modifier_barrack_resilience_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_barrack_resilience_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_barrack_resilience_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_barrack_resilience_aura:GetAuraEntityReject( hEntity )
	return false
end
--
modifier_barrack_resilience_aura_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_barrack_resilience_aura_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_barrack_resilience_aura_buff:GetModifierPhysicalArmorBonus()
	return 3
end





