LinkLuaModifier( "modifier_barrack_battle_drums", "ability/barrack_battle_drums" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_barrack_battle_drums_buff", "ability/barrack_battle_drums" ,LUA_MODIFIER_MOTION_NONE )

if barrack_battle_drums == nil then
    barrack_battle_drums = class({})
end

--------------------------------------------------------------------------------
function barrack_battle_drums:GetIntrinsicModifierName()
    return "modifier_barrack_battle_drums"
end
--------------------------------------------------------------------------------


modifier_barrack_battle_drums = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
})


--------------------------------------------------------------------------------

function modifier_barrack_battle_drums:IsAura()
    return true
end

function modifier_barrack_battle_drums:GetModifierAura()
    return "modifier_barrack_battle_drums_buff"
end

function modifier_barrack_battle_drums:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_barrack_battle_drums:GetAuraDuration()
    return 0.5
end

function modifier_barrack_battle_drums:GetAuraSearchTeam()    
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_barrack_battle_drums:GetAuraSearchType()    
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_barrack_battle_drums:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

--------------------------------------------------------------------------------


modifier_barrack_battle_drums_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
        }
    end,
})
function modifier_barrack_battle_drums_buff:OnCreated()
    if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_base_damage=ability:GetSpecialValueFor("bonus_base_damage")
end
function modifier_barrack_battle_drums_buff:GetModifierDamageOutgoing_Percentage()
	return self.bonus_base_damage
end