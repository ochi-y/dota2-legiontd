
-------------------------------------------------------------------------------------------------------
modifier_generic_true_sight_aura = class({
    IsHidden = function(self)
        return true
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
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})
function modifier_generic_true_sight_aura:AllowIllusionDuplicate()
    return false
end
function modifier_generic_true_sight_aura:OnCreated(params)
    self.radius = params.radius

    if not IsServer() then return end
    if params.showEff then
        local eff="particles/econ/wards/f2p/f2p_ward/f2p_ward_true_sight_ambient.vpcf"
        local effect_cast = ParticleManager:CreateParticle(eff, PATTACH_POINT_FOLLOW, self:GetParent())
        self:AddParticle(effect_cast, false, false, -1, false, false)
    end
end
function modifier_generic_true_sight_aura:DeclareFunctions()
    return {}
end
function modifier_generic_true_sight_aura:CheckState()
    local state = {}

    return state
end

function modifier_generic_true_sight_aura:IsAura()
    return true
end
function modifier_generic_true_sight_aura:GetAuraRadius()
    return self.radius
end
function modifier_generic_true_sight_aura:GetAuraEntityReject(unit)
    return false
end
function modifier_generic_true_sight_aura:GetAuraDuration()
    return 0
end
function modifier_generic_true_sight_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_generic_true_sight_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_generic_true_sight_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_generic_true_sight_aura:GetModifierAura()
    return "modifier_generic_true_sight_aura_debuff"
end

-------------------------------------------------------------------------------------------------------
modifier_generic_true_sight_aura_debuff = class({
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return true
    end,
    IsBuff = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})
function modifier_generic_true_sight_aura_debuff:AllowIllusionDuplicate()
    return false
end
function modifier_generic_true_sight_aura_debuff:OnCreated(params)
    -- self.damage = params.damage
    -- self:SetHasCustomTransmitterData(true) 
end
function modifier_generic_true_sight_aura_debuff:GetModifierInvisibilityLevel()
    return 0
end
function modifier_generic_true_sight_aura_debuff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}
end
function modifier_generic_true_sight_aura_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = false
    }
    return state
end
function modifier_generic_true_sight_aura_debuff:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end
