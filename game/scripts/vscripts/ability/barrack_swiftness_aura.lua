LinkLuaModifier( "modifier_barrack_swiftness_aura", "ability/barrack_swiftness_aura" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_barrack_swiftness_aura_buff", "ability/barrack_swiftness_aura" ,LUA_MODIFIER_MOTION_NONE )

if barrack_swiftness_aura == nil then
    barrack_swiftness_aura = class({})
end

--------------------------------------------------------------------------------
function barrack_swiftness_aura:GetIntrinsicModifierName()
    return "modifier_barrack_swiftness_aura"
end
--------------------------------------------------------------------------------


modifier_barrack_swiftness_aura = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
})


--------------------------------------------------------------------------------

function modifier_barrack_swiftness_aura:IsAura()
    return true
end

function modifier_barrack_swiftness_aura:GetModifierAura()
    return "modifier_barrack_swiftness_aura_buff"
end

function modifier_barrack_swiftness_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_barrack_swiftness_aura:GetAuraDuration()
    return 0.5
end

function modifier_barrack_swiftness_aura:GetAuraSearchTeam()    
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_barrack_swiftness_aura:GetAuraSearchType()    
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_barrack_swiftness_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

--------------------------------------------------------------------------------


modifier_barrack_swiftness_aura_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
        }
    end,
})
function modifier_barrack_swiftness_aura_buff:OnCreated()
    if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_movement_speed=ability:GetSpecialValueFor("bonus_movement_speed")
end
function modifier_barrack_swiftness_aura_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movement_speed
end