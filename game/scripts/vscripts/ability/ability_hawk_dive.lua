ability_hawk_dive = class({})
LinkLuaModifier("modifier_ability_hawk_dive_damage", "ability/ability_hawk_dive", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_generic_arc_lua", "lua_abilities/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH)
-- LinkLuaModifier("modifier_generic_unit_targeted_dash", "lua_abilities/generic/modifier_generic_unit_targeted_dash",
--     LUA_MODIFIER_MOTION_BOTH)


wave_5_hawk_dive = ability_hawk_dive

function ability_hawk_dive:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    EmitSoundOn("Hero_Beastmaster.Hawk.Reveal", caster)
    PlayEffOnUnit("particles/units/heroes/hero_beastmaster/beastmaster_shard_dive_chargeup.vpcf", caster,
        { bind = PATTACH_ABSORIGIN_FOLLOW, })
    return true
end

function ability_hawk_dive:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local target = caster:GetCursorCastTarget()
    local point = target:GetOrigin()
    if target:TriggerSpellAbsorb(self) then
        return
    end



    -- face toward target
    local direction = (point - caster:GetAbsOrigin()):Normalized()
    caster:SetForwardVector(direction)
    local damage = self:GetSpecialValueFor("damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    -- Begin moving to target point
    self.dash = caster:AddNewModifier(caster, ability, "modifier_generic_unit_targeted_dash", {
        targetIndex = target:entindex(),
        speed = 1500,
        vSpeed = 1000,
        close_distance = 100
    })


    PlayEffOnUnit("particles/units/heroes/hero_beastmaster/beastmaster_shard_dive_blur.vpcf", caster, {
        mod = self.dash,
        bind = PATTACH_ABSORIGIN_FOLLOW,
        attach = nil,
        cps = { 0, 1, 2, 3, 4 }
    })


    self.dash:SetEndCallback(function(interrupted)
        if not interrupted and target:GetTeamNumber() ~= caster:GetTeamNumber() then
            -- caster:AddNewModifier(caster, ability, "modifier_ability_hawk_dive_damage", {
            --     duration = 1,
            --     damage = bonus_damage
            -- })
            -- caster:PerformAttack(target, false, true, true, true, false, false, true)
            -- caster:RemoveModifierByName("modifier_ability_hawk_dive_damage")

            ExecuteOrderFromTable({
                UnitIndex = caster:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = target:entindex(),
                Queue = false
            })
            EmitSoundOn("Hero_Beastmaster.Hawk.Target", caster)

            if IsActiveUnit(target) then
                SimpleApplyDamage(ability, caster, target, damage)
                SimpleStun(ability,target, stun_duration)
            end
        end
    end)
end

-- modifier_ability_hawk_dive_damage = class({})
-- function modifier_ability_hawk_dive_damage:IsHidden()
--     return true
-- end
-- function modifier_ability_hawk_dive_damage:IsDebuff()
--     return false
-- end

-- function modifier_ability_hawk_dive_damage:DeclareFunctions()
--     local funcs = {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}
--     return funcs
-- end
-- function modifier_ability_hawk_dive_damage:GetModifierProcAttack_BonusDamage_Physical()
--     if not IsServer() then
--         return
--     end
--     return self.damage
-- end
-- function modifier_ability_hawk_dive_damage:OnCreated(params)
--     self.damage = params.damage
-- end
