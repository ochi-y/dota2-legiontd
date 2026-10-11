LinkLuaModifier( "modifier_barrack_healing_aura_10", "ability/barrack_healing_aura_10" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_barrack_healing_aura_10_buff", "ability/barrack_healing_aura_10" ,LUA_MODIFIER_MOTION_NONE )

if barrack_healing_aura_10 == nil then
    barrack_healing_aura_10 = class({})
end

--------------------------------------------------------------------------------
function barrack_healing_aura_10:GetIntrinsicModifierName()
    return "modifier_barrack_healing_aura_10"
end
--------------------------------------------------------------------------------


modifier_barrack_healing_aura_10 = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
})


--------------------------------------------------------------------------------
function modifier_barrack_healing_aura_10:IsPurgable(params)
    return false
end
function modifier_barrack_healing_aura_10:IsAura()
    return true
end

function modifier_barrack_healing_aura_10:GetModifierAura()
    return "modifier_barrack_healing_aura_10_buff"
end

function modifier_barrack_healing_aura_10:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_barrack_healing_aura_10:GetAuraDuration()
    return 0.5
end

function modifier_barrack_healing_aura_10:GetAuraSearchTeam()    
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_barrack_healing_aura_10:GetAuraSearchType()    
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_barrack_healing_aura_10:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

--------------------------------------------------------------------------------


modifier_barrack_healing_aura_10_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
        }
    end,
})
function modifier_barrack_healing_aura_10_buff:OnCreated()
    if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.heal_rate=ability:GetSpecialValueFor("heal_rate")
end
function modifier_barrack_healing_aura_10_buff:GetModifierConstantHealthRegen()
	return self.heal_rate
end