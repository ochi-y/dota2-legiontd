LinkLuaModifier("modifier_nature_water_of_life", "ability/nature_water_of_life.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if nature_water_of_life == nil then
    nature_water_of_life = class({})
end
function nature_water_of_life:OnProjectileHit_ExtraData(target, location, params)
    if not target then
        return
    end
    local heal = self:GetSpecialValueFor("heal")

    if not IsActiveUnit(self:GetCaster()) then
        heal = self:GetSpecialValueFor("death_heal")
    end
    -- EmitSoundOn("Hero_Treant.LeechSeed.Target",target)
    -- target:Heal(heal, self)

    target:HealWithParams(heal, self, false, true,self:GetCaster() , false)

    PopupHealing(target, heal)
end

function nature_water_of_life:GetIntrinsicModifierName()
    return "modifier_nature_water_of_life"
end



---------------------------------------------------------------------
-- Modifiers

modifier_nature_water_of_life = class({
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
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})

function modifier_nature_water_of_life:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.heal_cooldown = ability:GetSpecialValueFor("heal_cooldown")
    self.heal_count = ability:GetSpecialValueFor("heal_count")
    self.death_heal = ability:GetSpecialValueFor("death_heal")


    if IsServer() then
        self:StartIntervalThink(self.heal_cooldown)
    end
end
function modifier_nature_water_of_life:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_nature_water_of_life:OnDestroy()
    if IsServer() then
    end
end
function modifier_nature_water_of_life:DeclareFunctions()
    return {MODIFIER_EVENT_ON_DEATH}
end
function modifier_nature_water_of_life:OnIntervalThink()
    if IsServer() then
        if IsCustomBuilding(self:GetParent()) then
            return
        end
        if not IsActiveUnit(self:GetParent()) then
            return
        end
        self:DoHeal(self.heal_count)
    end
end

function modifier_nature_water_of_life:DoHeal(count)
    if IsServer() then
        local caster = self:GetParent()
        local ability=self:GetAbility()
        EmitSoundOn("Hero_Treant.LeechSeed.Cast", caster)
        -- SimplePlayEffOnUnit(caster, "particles/units/heroes/hero_treant/treant_leech_seed.vpcf")
        --local units = SimpleFindFriend(caster:GetTeamNumber(), caster:GetAbsOrigin(), 700)

        local units=FindAbilityTarget(ability,caster:GetAbsOrigin(),ability:GetSpecialValueFor("radius"),{})

        stableSort(units, function(a, b)
            return a:GetHealthPercent() < b:GetHealthPercent()
        end)

        local c = 0
        for key, unit in pairs(units) do


            SimpleTrackingProjectile(self:GetAbility(), caster, unit,
                "particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf", 400,{
                    iSourceAttachment     = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
                })
            c = c + 1
            if c >= count then
                break
            end
        end
    end
end

function modifier_nature_water_of_life:OnDeath(params)
    if IsServer() then
        if params.unit == self:GetParent() then
            local caster = self:GetParent()
            local units = SimpleFindFriend(caster:GetTeamNumber(), caster:GetAbsOrigin(), 700)

            local heal = self.death_heal

            local c = 0
            for key, unit in pairs(units) do

                -- unit:Heal(heal, self)

                unit:HealWithParams(heal, self, false, true,self:GetCaster() , false)

                PopupHealing(unit, heal)
                SimplePlayEffOnUnit(unit, "particles/neutral_fx/troll_heal.vpcf")
                c = c + 1
                if c >= self.heal_count then
                    break
                end
            end
        end
    end
    return 0
end

----
