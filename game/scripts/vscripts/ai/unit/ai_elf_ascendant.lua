require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)

    function self:ReloadAiAbility()
        self.abilities = {}
        local beast_fireball = self:FindAbilityByName("beast_fireball")
        if beast_fireball then
            table.insert(self.abilities, beast_fireball)
            beast_fireball.Skill = function(entity, ability)
                -- Search for a target
                local units = AiFindAbilityTarget(entity, ability, {})

                -- Filter units
                units = AiFilterNotStunned(units)
                -- Avoid casting on the same target twice in a row
                units = AiFilterNoTag(units, "beast_fireball")

                local target = units[1]
                if target then
                    -- Tag the target for 1 second
                    UTIL:addUnitTag(target, "beast_fireball", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end

            beast_fireball.SkillTrigger = function(ability, entity)
                -- Cast range
                local castRange = ability:GetCastRange(entity:GetAbsOrigin(), nil)
                -- Trigger when an enemy is inside the cast range
                local shouldCast = CheckEnemyCountInRangeEx(ability, entity, true, 1, castRange, nil)
                return shouldCast
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill
            self:ReloadAiAbility()
            --
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
