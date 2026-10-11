if arctic_ice_spear_2 == nil then
    arctic_ice_spear_2 = class({})
end

LinkLuaModifier("modifier_arctic_ice_spear_2", "ability/arctic_ice_spear_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arctic_ice_spear_2_debuff", "ability/arctic_ice_spear_2", LUA_MODIFIER_MOTION_NONE)

arctic_ice_spear_2 = class({
    GetIntrinsicModifierName = function()
        return "modifier_arctic_ice_spear_2"
    end
})

modifier_arctic_ice_spear_2 = class({
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
    DeclareFunctions = function()
        return {MODIFIER_EVENT_ON_ATTACK_LANDED}
    end
})

function modifier_arctic_ice_spear_2:OnCreated()
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.duration = ability:GetSpecialValueFor("duration")
    self.chance = ability:GetSpecialValueFor("chance")
end

function modifier_arctic_ice_spear_2:OnRefresh()
    self:OnCreated()
end

function modifier_arctic_ice_spear_2:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end
    local target = params.target
    local chance=self.chance
  
    if RandomInt(1, 100) <= chance and not target:IsMagicImmune() then
        if params.attacker:PassivesDisabled() == false and (target:IsHero() or target:IsCreep()) then
            local duration = self.duration
            --
            EmitSoundOn("hero_Crystal.frostbite", target)
            duration = duration * (1 - CalUnitStatusResistance(target))
            target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_arctic_ice_spear_2_debuff", {
                duration = duration
            })
        end
    end
end

-------------------------------------------------------------------------------------------------------
modifier_arctic_ice_spear_2_debuff = class({
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
        return MODIFIER_ATTRIBUTE_NONE
    end
})
function modifier_arctic_ice_spear_2_debuff:AllowIllusionDuplicate()
    return false
end
function modifier_arctic_ice_spear_2_debuff:OnCreated(params)
    -- self.damage = params.damage
    -- self:SetHasCustomTransmitterData(true) 
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.damage = ability:GetSpecialValueFor("damage")

    if not IsServer() then
        return
    end
    self:StartIntervalThink(1)
    -- would be lethal in the same frame
    Timers:CreateTimer(FrameTime(), function()
        if IsActiveUnit(self.parent) then
            self:OnIntervalThink()
        end
    end)
    self.damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility() -- Optional.
    }

end
function modifier_arctic_ice_spear_2_debuff:DeclareFunctions()
    return {}
end
function modifier_arctic_ice_spear_2_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function modifier_arctic_ice_spear_2_debuff:GetEffectName()
    return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end
function modifier_arctic_ice_spear_2_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

function modifier_arctic_ice_spear_2_debuff:OnIntervalThink()
    if not IsServer() then
        return
    end
    ApplyDamage(self.damageTable)

end
