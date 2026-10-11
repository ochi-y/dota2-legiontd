LinkLuaModifier("modifier_riven_broken_wings", "ability/riven_broken_wings.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_riven_broken_wings_buff", "ability/riven_broken_wings.lua", LUA_MODIFIER_MOTION_NONE)


-- Abilities
if riven_broken_wings == nil then
    riven_broken_wings = class({})
end

-- function riven_broken_wings:GetEffectiveCastRange(location, target)
-- 	local caster = self:GetCaster()
-- 	local modifier = caster:HasModifier("modifier_riven_blade_of_the_exile")
-- 	if modifier then
-- 		return self.BaseClass.GetCastRange(self, location, target) + 75
-- 	else
-- 		return self.BaseClass.GetCastRange(self, location, target)
-- 	end
-- end

-- function riven_broken_wings:GetCooldown(iLevel)
-- 	local caster=self:GetCaster()
-- 	if not caster:HasModifier("modifier_riven_broken_wings") then
-- 		return 0
-- 	end
-- 	local mod=caster:FindModifierByName("modifier_riven_broken_wings")
-- 	if mod:GetStackCount()==2 then
-- 		return self:GetSpecialValueFor("cooldown")
-- 	else
-- 		return 0
-- 	end
-- end

function riven_broken_wings:GetAOERadius()
    local radius = self:GetSpecialValueFor("radius")
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_riven_blade_of_the_exile") then
        radius = radius + 75
    end
    return radius
end

function riven_broken_wings:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()

    local ability = self
    local origin = caster:GetOrigin()
    local rangeBonus = 0
    if caster:HasModifier("modifier_riven_blade_of_the_exile") then
        rangeBonus = 75
    end


    self.oldPos=caster:GetAbsOrigin()

    local unit_count = self:GetSpecialValueFor("unit_count")



    local point = getAbilityOvershootPoint(ability, { rangeBonus = 0, alwaysMax = true })

    local recast_cooldown = self:GetSpecialValueFor("recast_cooldown")
    local mod = caster:AddNewModifier(caster, self, "modifier_riven_broken_wings", {
        duration = recast_cooldown
    })
    mod:IncrementStackCount()
    local stackCount = mod:GetStackCount()

    local sounds = { "Hero_Dawnbreaker.Fire_Wreath.Sweep", "Hero_Dawnbreaker.Fire_Wreath.Layer",
        "Hero_Dawnbreaker.Fire_Wreath.Smash" }
    EmitSoundOn(sounds[stackCount], caster)

    local particles = { "particles/units/heroes/hero_dawnbreaker/dawnbreaker_fire_wreath_sweep_ad.vpcf",
        "particles/units/heroes/hero_dawnbreaker/dawnbreaker_fire_wreath_sweep_ad.vpcf",
        "particles/units/heroes/hero_dawnbreaker/dawnbreaker_fire_wreath_sweep_overhead.vpcf" }
    local stoppedByTerrain = true
    if stackCount == 3 then
        stoppedByTerrain = false
    end
    local heights = { 30, 40, 60 }

    self.arc = self:GetCaster():AddNewModifier(self.caster, -- player source
        self,                                               -- ability source
        "modifier_generic_arc_lua",                         -- modifier name
        {
            target_x = point.x,
            target_y = point.y,
            speed = 1000,
            distance = (point - caster:GetAbsOrigin()):Length2D(),
            height = heights[stackCount],
            fix_end = true,
            -- fix_duration = false,
            -- isStun = true,
            isRestricted = true,
            activity = ACT_DOTA_OVERRIDE_ABILITY_1,
            stoppedByTerrain = stoppedByTerrain
        } -- kv
    )
    local radius = self:GetSpecialValueFor("radius")
    radius = radius + rangeBonus
    local knock_up = ability:GetSpecialValueFor("knock_up")
    local damage = self:GetSpecialValueFor("damage_bonus") + caster:GetAverageTrueAttackDamage(caster)
    PlayEffOnUnit(particles[stackCount], caster, { bind = PATTACH_ABSORIGIN_FOLLOW })
    self.arc:SetEndCallback(function()
        caster:AddNewModifier(caster, ability, "modifier_riven_broken_wings_buff", { duration = 0.1 })

        if stackCount == 3 then
            PlayEffOnLocation("particles/units/heroes/hero_dawnbreaker/dawnbreaker_fire_wreath_smash.vpcf",
                caster:GetAbsOrigin())
        end
        local units = FindAbilityTarget(self, caster:GetAbsOrigin(), radius, {})

        units=subrange(units,1,unit_count) 

        for index, unit in ipairs(units) do
            EmitSoundOn("Hero_Sven.Attack.Impact", unit)
            --SimpleApplyDamage(self, caster, unit, damage,self:GetAbilityDamageType())

            caster:PerformAttack(unit, true, true, true, false, true, false, true)
            PlayEffOnUnit("particles/units/heroes/hero_dawnbreaker/dawnbreaker_fire_wreath_impact.vpcf", unit)
            if stackCount == 3 then
                SimpleKnockback(unit, ability, unit:GetAbsOrigin(), knock_up, 0, 200, true)
            end
        end
        caster:RemoveModifierByName("modifier_riven_broken_wings_buff")
        if IsActiveBuilding(caster) then
            caster:SetAbsOrigin(self.oldPos)
            SimpleMoveUnit(caster, self.oldPos)
        end
    end)

    if stackCount == 3 then
        mod:Destroy()
    else
        self:EndCooldown()
        self:StartCooldown(1.5)
    end
end

---------------------------------------------------------------------
-- Modifiers
if modifier_riven_broken_wings == nil then
    modifier_riven_broken_wings = class({})
end
function modifier_riven_broken_wings:IsHidden(params)
    return false
end

function modifier_riven_broken_wings:OnCreated(params)
    if IsServer() then
    end
end

function modifier_riven_broken_wings:OnRemoved(params)
    if not IsServer() then
        return
    end
    local ability = self:GetAbility()
    if ability then
        ability:StartCooldown(ability:GetEffectiveCooldown(ability:GetLevel()))
    end
end

function modifier_riven_broken_wings:OnRefresh(params)
    if IsServer() then
    end
end

function modifier_riven_broken_wings:OnDestroy()
    if IsServer() then
    end
end

function modifier_riven_broken_wings:DeclareFunctions()
    return {}
end

-------------------------------------------------------------------------------------------------------
modifier_riven_broken_wings_buff = class({
    IsHidden = function(self)
        return false
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
function modifier_riven_broken_wings_buff:AllowIllusionDuplicate()
    return false
end

function modifier_riven_broken_wings_buff:OnCreated(params)
    -- self.damage = params.damage
    -- self:SetHasCustomTransmitterData(true)
    local ability = self:GetAbility()
    self.damage_bonus = ability:GetSpecialValueFor("damage_bonus")
end

function modifier_riven_broken_wings_buff:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_riven_broken_wings_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end

function modifier_riven_broken_wings_buff:GetModifierPreAttack_BonusDamage()
    return self.damage_bonus
end

function modifier_riven_broken_wings_buff:CheckState()
    local state = {
    }
    return state
end
