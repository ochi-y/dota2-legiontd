amumu_cursed_touch = class({})
LinkLuaModifier("modifier_amumu_cursed_touch", "ability/amumu_cursed_touch", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amumu_cursed_touch_debuff", "ability/amumu_cursed_touch", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amumu_cursed_touch_slow_debuff", "ability/amumu_cursed_touch", LUA_MODIFIER_MOTION_NONE)

function amumu_cursed_touch:GetIntrinsicModifierName()
    return "modifier_amumu_cursed_touch"
end
modifier_amumu_cursed_touch = class({})
function modifier_amumu_cursed_touch:IsDebuff()
    return false
end
function modifier_amumu_cursed_touch:IsHidden()
    return true
end
function modifier_amumu_cursed_touch:IsPurgable()
    return false
end
function modifier_amumu_cursed_touch:IsPurgeException()
    return false
end
function modifier_amumu_cursed_touch:RemoveOnDeath()
    return false
end
function modifier_amumu_cursed_touch:DeclareFunctions()
    local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
    return funcs
end

function modifier_amumu_cursed_touch:OnAttackLanded(params)
    if IsServer() then
        if params.attacker ~= self:GetParent() then
            return
        end
        if params.target:IsMagicImmune() then
            return
        end

        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        local slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
        local target = params.target
        if target == nil then
            target = params.target
        end

        local attacker = params.attacker
        if target:GetTeamNumber() ~= caster:GetTeamNumber() and attacker == caster and not target:IsBuilding() then
            target:AddNewModifier(caster, ability, "modifier_amumu_cursed_touch_debuff", {
                duration = duration
            })

            target:AddNewModifier(caster, ability, "modifier_amumu_cursed_touch_slow_debuff", {
                duration = slow_duration
            })

        end
    end
end

modifier_amumu_cursed_touch_debuff = class({})

function modifier_amumu_cursed_touch_debuff:OnCreated()
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.damage_pct=ability:GetSpecialValueFor("damage_pct")
end
function modifier_amumu_cursed_touch_debuff:OnRefresh()
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.damage_pct=ability:GetSpecialValueFor("damage_pct")

end

function modifier_amumu_cursed_touch_debuff:IsDebuff()
    return true
end
function modifier_amumu_cursed_touch_debuff:IsHidden()
    return false
end
function modifier_amumu_cursed_touch_debuff:IsPurgable()
    return true
end
function modifier_amumu_cursed_touch_debuff:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
    return funcs
end
function modifier_amumu_cursed_touch_debuff:GetModifierMagicalResistanceBonus()
    return self.damage_pct * (-1)
end

function modifier_amumu_cursed_touch_debuff:GetEffectName()
    return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf"
end
function modifier_amumu_cursed_touch_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

-------------------------------------------------------------------------------------------------------
modifier_amumu_cursed_touch_slow_debuff = class({})

function modifier_amumu_cursed_touch_slow_debuff:OnCreated()
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.move_slow=ability:GetSpecialValueFor("move_slow")
end
function modifier_amumu_cursed_touch_slow_debuff:OnRefresh()
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.move_slow=ability:GetSpecialValueFor("move_slow")
end
function modifier_amumu_cursed_touch_slow_debuff:IsDebuff()
    return true
end
function modifier_amumu_cursed_touch_slow_debuff:IsPurgable()
    return true
end
function modifier_amumu_cursed_touch_slow_debuff:IsPurgeException()
    return true
end
function modifier_amumu_cursed_touch_slow_debuff:IsHidden()
    return false
end
function modifier_amumu_cursed_touch_slow_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_amumu_cursed_touch_slow_debuff:GetModifierMoveSpeedBonus_Percentage()
    return (0 - self.move_slow)
end

