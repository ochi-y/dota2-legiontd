LinkLuaModifier("modifier_king_entangle_debuff", "ability/king_entangle.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_king_entangle_debuff_tag", "ability/king_entangle.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if king_entangle == nil then
    king_entangle = class({})
end

function king_entangle:OnAbilityPhaseStart()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_casting", {
        duration = 0.4
    })

    return true
end
function king_entangle:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end
function king_entangle:OnSpellStart()
    if not IsServer() then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")

    local max_count=self:GetSpecialValueFor("max_count")
    local caster = self:GetCaster()
    local duration = self.duration

    local units = FindAbilityTarget(self, self:GetCursorPosition(), self:GetSpecialValueFor("radius"), {})
    
    for i = 1, max_count, 1 do
        if units[i] then
            local unit=units[i]
            local realDuration = duration * (1 - CalUnitStatusResistance(unit))
            unit:AddNewModifier(caster, self, "modifier_king_entangle_debuff", {
                duration = realDuration
            })
        end
    end
    
    -- for _, unit in ipairs(units) do
        
    --     -- PlayEffOnUnit("particles/units/heroes/hero_treant/treant_overgrowth_trails.vpcf",caster,{
    --     -- 	cpUnit = {
    --     --         [1] = {target, PATTACH_POINT_FOLLOW, ""}
    --     --     }
    --     -- })
        
    -- end

    if units[1] then
        EmitSoundOn("Hero_Treant.NaturesGrasp.Spawn", units[1])
    end

end

---------------------------------------------------------------------
-- Modifiers
if modifier_king_entangle_debuff == nil then
    modifier_king_entangle_debuff = class({})
end
function modifier_king_entangle_debuff:OnCreated(params)
    if not IsServer() then
        return
    end
    local ability = self:GetAbility()
    self.damage = ability:GetSpecialValueFor("damage")

    self:StartIntervalThink(1)
end

function modifier_king_entangle_debuff:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_king_entangle_debuff:OnIntervalThink()
    if not IsServer() then
        return
    end
    SimpleApplyDamage(self:GetAbility(), self:GetCaster(), self:GetParent(), self.damage)
end
function modifier_king_entangle_debuff:OnDestroy()
    if IsServer() then
    end
end
function modifier_king_entangle_debuff:DeclareFunctions()
    return {}
end
function modifier_king_entangle_debuff:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true
        -- [MODIFIER_STATE_DISARMED]=true
    }
end

function modifier_king_entangle_debuff:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle.vpcf"
end

function modifier_king_entangle_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_king_entangle_debuff_tag = class({
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
        return MODIFIER_ATTRIBUTE_NONE
    end
})
