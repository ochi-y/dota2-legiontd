require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}

        local marine_tidal_wave = self:FindAbilityByName("marine_tidal_wave")

        if marine_tidal_wave then
            table.insert(self.abilities, marine_tidal_wave)
            marine_tidal_wave.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})

                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_marine_storm_geyser_heal_buff")
                -- units sort
                -- units = AiOrderByHealthPct(units, true)
                -- units = AiOrderByAttackCap(units, true)
                -- cast ability
                local target = units[1]
                if target then
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            marine_tidal_wave.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 700)
            end
        end

        local marine_sphere_1 = self:FindAbilityByName("marine_sphere_1")
        if marine_sphere_1 then
            table.insert(self.abilities, marine_sphere_1)

            marine_sphere_1.Skill = function(entity, ability)
                local target = nil
                local targetFighterId = GamePlay:FighterGetAbilityTarget(self.fighterId, ability:GetAbilityName())
                local targetFighter = GamePlay:FighterGetUnit(targetFighterId)

                if IsActiveUnit(targetFighter) and not targetFighter:HasModifier("modifier_marine_sphere_buff") and (targetFighter:GetAbsOrigin() - self:GetAbsOrigin()):Length2D() < 1200 then
                    target = targetFighter
                else
                    -- search units
                    local units = AiFindFriends(entity, ability)
                    -- units filter
                    -- units = AiFilterHealthPct(units, 100)
                    units = AiFilterNoModifier(units, "modifier_marine_sphere_buff")
                    units = AiFilterNoModifier(units, "modifier_marine_sphere_tag")
                    -- units sort
                    units = AiOrderByHealth(units, false)
                    -- cast ability
                    target = units[1]
                end

                if target then
                    target:AddNewModifier(entity, marine_sphere_1, "modifier_marine_sphere_tag", { duration = 1 })
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end

            marine_sphere_1.SkillTrigger = CheckFriendAbilityRange
        end

        local marine_storm_geyser = self:FindAbilityByName("marine_storm_geyser")

        if marine_storm_geyser then
            table.insert(self.abilities, marine_storm_geyser)
            marine_storm_geyser.Skill = function(entity, ability)
                local targetPos = nil
                -- local fighterTarget = GamePlay:FighterGetAbilityTarget(self.fighterId, ability:GetAbilityName())

                -- if fighterTarget and (self:GetAbsOrigin() - fighterTarget):Length2D() < 1200 then
                --     targetPos = fighterTarget
                --     entity:CastAbilityOnPosition(targetPos, ability, -1)
                --     return 1
                -- end
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNoModifier(units, "modifier_marine_storm_geyser_tag")
                -- units = AiFilterNoModifier(units, "modifier_marine_storm_geyser_heal_buff")
                -- units sort
                units = AiOrderByHealthPct(units, true)
                -- units = AiOrderByAttackCap(units, true)
                -- cast ability
                local target = units[1]
                if target and target:GetHealthPercent() < 100 then
                    for _, unit in ipairs(units) do
                        unit:AddNewModifier(entity, ability, "modifier_marine_storm_geyser_tag", { duration = 2 })
                    end
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            marine_storm_geyser.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 900)
            end
        end
    end

    self:SetContextThink("init_think", function()
        self.aiThink = aiThinkStandardSkill
        

        self:ReloadAiAbility()


        -- marine_sphere_1.CustomAffectRadius = marine_sphere_1:GetSpecialValueFor("wave_width") -- Very suboptimal, should check rectangle from caster instead
        self.FindNewAttackTarget = StandardFindNewAttackTarget
        self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
    end, 0)
end
