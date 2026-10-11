LinkLuaModifier("modifier_nature_forbidden_fruit", "ability/nature_forbidden_fruit.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nature_forbidden_fruit_buff", "ability/nature_forbidden_fruit.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if nature_forbidden_fruit == nil then
    nature_forbidden_fruit = class({})
end
function nature_forbidden_fruit:GetIntrinsicModifierName()
    return "modifier_nature_forbidden_fruit"
end
---------------------------------------------------------------------
-- Modifiers

modifier_nature_forbidden_fruit = class({
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

function modifier_nature_forbidden_fruit:OnCreated(params)
    if not self:GetAbility() then return end
    if IsServer() then
    end
    local ability = self:GetAbility()
    self.damage_return = ability:GetSpecialValueFor("damage_return")
    self.damage = ability:GetSpecialValueFor("damage")
    self.count = ability:GetSpecialValueFor("count")
    self.radius = ability:GetSpecialValueFor("radius")

end
function modifier_nature_forbidden_fruit:OnRefresh(params)
    if not self:GetAbility() then return end
    if IsServer() then
    end
    local ability = self:GetAbility()
    self.damage_return = ability:GetSpecialValueFor("damage_return")
    self.damage = ability:GetSpecialValueFor("damage")
    self.count = ability:GetSpecialValueFor("count")
    self.radius = ability:GetSpecialValueFor("radius")
end
function modifier_nature_forbidden_fruit:OnDestroy()
    if IsServer() then
    end
end
function modifier_nature_forbidden_fruit:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACKED, MODIFIER_EVENT_ON_DEATH}
end

function modifier_nature_forbidden_fruit:OnAttacked(params)
    if not IsServer() then
        return
    end
    if params.target ~= self:GetParent() then
        return
    end
    local attacker = params.attacker
    local target = params.target

    if attacker:IsMagicImmune() then
        return
    end

    if attacker:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
        local factor = SimpleGetAttackFactor(target, attacker)
        SimpleApplyDamage(self:GetAbility(), target, attacker, (self.damage_return / 100) * params.damage * factor,
            DAMAGE_TYPE_PHYSICAL,DOTA_DAMAGE_FLAG_BYPASSES_ALL_BLOCK+DOTA_DAMAGE_FLAG_REFLECTION)
    end
end

function modifier_nature_forbidden_fruit:OnDeath(params)
    if IsServer() then
        if params.unit == self:GetCaster() then
            local caster = self:GetParent()
            local radius = self.radius
            EmitSoundOn("Hero_Treant.Overgrowth.Cast", caster)
            local nFXIndex2 = ParticleManager:CreateParticle(
                "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_cast.vpcf",
                PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(nFXIndex2, 0, caster:GetOrigin())
            ParticleManager:SetParticleControl(nFXIndex2, 1, Vector(radius, radius, radius))
            ParticleManager:ReleaseParticleIndex(nFXIndex2)
            local nTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
            local entities = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, radius, nTeam,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST, false)
            local c = 0
            if #entities > 0 then
                for _, entity in pairs(entities) do
                    SimpleApplyDamage(self:GetAbility(), caster, entity, self.damage)
                    c = c + 1
                    if c >= self.count then
                        break
                    end
                end
            end
        end
    end
    return 0
end

----

