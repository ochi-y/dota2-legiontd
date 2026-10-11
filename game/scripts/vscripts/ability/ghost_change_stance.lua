LinkLuaModifier("modifier_ghost_change_stance", "ability/ghost_change_stance.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if ghost_change_stance == nil then
    ghost_change_stance = class({})
end
function ghost_change_stance:OnToggle()
    -- local caster = self:GetCaster()
    -- -- SimplePlayEffOnUnit(caster,"particles/units/heroes/hero_rattletrap/clock_overclock_buff_recharge.vpcf")
    -- if caster:HasModifier("modifier_ghost_change_stance") then
    --     caster:RemoveModifierByName("modifier_ghost_change_stance")
    -- else
    --     caster:AddNewModifier(caster, self, "modifier_ghost_change_stance", {})
    -- end

    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName( "modifier_ghost_change_stance" )

    if self:GetToggleState() then
        if not modifier then
            EmitSoundOn("Hero_SkeletonKing.Reincarnate.Stinger.Arcana", caster)
            caster:AddNewModifier(
                caster,
                self,
                "modifier_ghost_change_stance",
                {}
            )
            caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
        end
    else
        if modifier then
            modifier:Destroy()
        end
    end
end
---------------------------------------------------------------------
-- Modifiers
modifier_ghost_change_stance = class({
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_ghost_change_stance:OnCreated(params)

    local ability = self:GetAbility()
    self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    self.health_reduction = ability:GetSpecialValueFor("health_reduction")

    if IsServer() then
        local caster = self:GetParent()
        SimpleAddHealth(caster, -self.health_reduction)
        
    end
end
function modifier_ghost_change_stance:OnRefresh(params)
    local ability = self:GetAbility()
    -- self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    -- self.health_reduction = ability:GetSpecialValueFor("health_reduction")

end
function modifier_ghost_change_stance:OnDestroy()
    if IsServer() then
        local caster = self:GetParent()
        SimpleAddHealth(caster, self.health_reduction)
    end
end
function modifier_ghost_change_stance:IsPurgable(params)
    return false
end
function modifier_ghost_change_stance:DeclareFunctions()
    return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end
function modifier_ghost_change_stance:GetModifierBaseAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_ghost_change_stance:GetEffectName()
    return "particles/units/heroes/hero_skeletonking/wraith_king_death.vpcf"
end
function modifier_ghost_change_stance:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

-------------------------------------------------------------------------------------------------------
