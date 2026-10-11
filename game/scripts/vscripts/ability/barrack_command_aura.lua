LinkLuaModifier( "modifier_barrack_command_aura", "ability/barrack_command_aura" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_barrack_command_aura_buff", "ability/barrack_command_aura" ,LUA_MODIFIER_MOTION_NONE )

if barrack_command_aura == nil then
    barrack_command_aura = class({})
end

--------------------------------------------------------------------------------
function barrack_command_aura:GetIntrinsicModifierName()
    return "modifier_barrack_command_aura"
end
--------------------------------------------------------------------------------


modifier_barrack_command_aura = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
})


--------------------------------------------------------------------------------

function modifier_barrack_command_aura:IsAura()
    return true
end

function modifier_barrack_command_aura:GetModifierAura()
    return "modifier_barrack_command_aura_buff"
end

function modifier_barrack_command_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_barrack_command_aura:GetAuraDuration()
    return 0.5
end

function modifier_barrack_command_aura:GetAuraSearchTeam()    
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_barrack_command_aura:GetAuraSearchType()    
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_barrack_command_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

--------------------------------------------------------------------------------


modifier_barrack_command_aura_buff = class({
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
function modifier_barrack_command_aura_buff:OnCreated()
    if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_base_damage=ability:GetSpecialValueFor("bonus_base_damage")
end
function modifier_barrack_command_aura_buff:GetModifierDamageOutgoing_Percentage()
	return self.bonus_base_damage
end