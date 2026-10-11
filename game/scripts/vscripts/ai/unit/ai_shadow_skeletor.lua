require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        -- shadow_intercept ability
        self.abilities[1] = self:FindAbilityByName("shadow_intercept")
        if self.abilities[1] then
            self.abilities[1].Skill = function(entity, ability)
                -- Minimum distance parameter
                local min_range = ability:GetSpecialValueFor("min_range")

                -- Find a target, sorted by distance by default
                local units = AiFindAbilityTarget(entity, ability, {})

                -- Filters:
                -- 1. Never cast on a unit that was already intercepted
                units = AiFilterNoTag(units, "shadow_intercept")

                -- 2. Skip units within 300 units, they are too close to charge
                local filtered_units = {}
                for _, unit in pairs(units) do
                    local distance = (entity:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D()
                    if distance >= min_range then
                        table.insert(filtered_units, unit)
                    end
                end

                -- Pick the closest target beyond the minimum distance
                local target = filtered_units[1]
                if target then
                    -- Mark the target to avoid re-casting too soon
                    UTIL:addUnitTag(target, "shadow_intercept", 2)
                    -- Cast the ability
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end

            -- Cast trigger
            self.abilities[1].SkillTrigger = function(ability, entity)
                -- Try to cast when at least one enemy is within 700
                -- Note: this checks the outer range, the minimum distance is filtered inside Skill
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 700, nil)
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkSwitchTarget
            self.FindNewAttackTarget = function(entity)
                return StandardFindNewAttackTarget(entity)
            end
            self:ReloadAiAbility()
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
