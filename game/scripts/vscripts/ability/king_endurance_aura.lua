LinkLuaModifier( "modifier_king_endurance_aura", "ability/king_endurance_aura.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_king_endurance_aura_buff", "ability/king_endurance_aura.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if king_endurance_aura == nil then
	king_endurance_aura = class({})
end
function king_endurance_aura:GetIntrinsicModifierName()
	return "modifier_king_endurance_aura"
end
---------------------------------------------------------------------
--Modifiers

modifier_king_endurance_aura = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_king_endurance_aura:OnCreated(params)
	if IsServer() then
	end
end
function modifier_king_endurance_aura:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_king_endurance_aura:OnDestroy()
	if IsServer() then
	end
end
function modifier_king_endurance_aura:DeclareFunctions()
	return {
	}
end
function modifier_king_endurance_aura:IsAura()
	return true
end
function modifier_king_endurance_aura:GetModifierAura()
	return "modifier_king_endurance_aura_buff"
end
function modifier_king_endurance_aura:GetAuraRadius()
	return 1500
end

function modifier_king_endurance_aura:GetAuraDuration()
	return 1
end

function modifier_king_endurance_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_king_endurance_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_king_endurance_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_king_endurance_aura:GetAuraEntityReject( hEntity )
	return false
end
--
modifier_king_endurance_aura_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_king_endurance_aura_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
end

function modifier_king_endurance_aura_buff:GetModifierMoveSpeedBonus_Percentage()
	return 15
end
function modifier_king_endurance_aura_buff:GetModifierAttackSpeedPercentage( params )
	return 10
end 





