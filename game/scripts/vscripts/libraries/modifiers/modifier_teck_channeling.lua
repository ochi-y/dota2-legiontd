modifier_teck_channeling = class({
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
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})

function modifier_teck_channeling:OnCreated(params)
    if not IsServer() then
        return
    end
    
    -- local abilityName = params.abilityName
    -- local eff = nil
    -- local effMap = {
    --     ["upgrade_lumber_farm"] = "particles/econ/items/tinker/boots_of_travel/teleport_end_bots.vpcf",
    --     ["upgrade_farm"] = "particles/econ/events/fall_major_2015/teleport_start_fallmjr_2015_lvl2.vpcf",
    --     ["upgrade_lumber_farm_speedup"] = "particles/econ/events/ti10/teleport/teleport_end_ti10_lvl1.vpcf"
    -- }
    -- eff = effMap[abilityName] or "particles/econ/items/tinker/boots_of_travel/teleport_end_bots.vpcf"
    -- SimpleAddEff(self, self:GetParent(), eff, nil)

end
-- function modifier_teck_channeling:GetEffectAttachType()
--     return PATTACH_ABSORIGIN_FOLLOW
-- end
