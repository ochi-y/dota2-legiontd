require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}

        -- Backstep ability
        self.abilities[1] = self:FindAbilityByName("legiontd_backstep")
        if self.abilities[1] then
            -- Cast logic
            self.abilities[1].Skill = function(entity, ability)
                -- Search for a target, enemies in range
                local units = AiFindAbilityTarget(entity, ability, {})

                -- Skip marked targets so the ability is not spammed
                units = AiFilterNoTag(units, "legiontd_backstep")

                -- Prefer the closest enemy, which is also where the chestnut flies
                table.sort(units, function(a, b)
                    local distA = (a:GetAbsOrigin() - entity:GetAbsOrigin()):Length2D()
                    local distB = (b:GetAbsOrigin() - entity:GetAbsOrigin()):Length2D()
                    return distA < distB
                end)

                local target = units[1]
                if target then
                    -- Mark the target for 2 seconds so it is not picked again
                    -- UTIL:addUnitTag(target, "legiontd_backstep", 2)
                    -- Cast the ability
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end

            -- Trigger: an enemy enters 250 range
            self.abilities[1].SkillTrigger = function(ability, entity)
                -- Fires when at least one enemy is within 250, close to cast range
                -- so the unit retreats as soon as an enemy closes in
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 250, nil)
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            -- Use the standard ability-aware AI think
            self.aiThink = aiThinkStandardSkill
            self:ReloadAiAbility()
            -- Use the standard target search
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            -- Start the AI think loop
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
