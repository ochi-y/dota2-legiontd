require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}

        -- Cyclone ability
        self.abilities[1] = self:FindAbilityByName("legiontd_cyclone")
        if self.abilities[1] then
            -- Cast logic
            self.abilities[1].Skill = function(entity, ability)
                -- Search for a target, enemies in range
                local units = AiFindAbilityTarget(entity, ability, {})

                -- Do not cast when the field holds one unit or fewer
                if #units <= 1 then
                    return nil
                end

                -- Skip marked targets so the ability is not spammed
                units = AiFilterNoTag(units, "legiontd_cyclone")

                -- No target left after filtering, so do not cast
                if #units == 0 then
                    return nil
                end

                -- Prefer the unit with the most health
                table.sort(units, function(a, b)
                    return a:GetHealth() > b:GetHealth()
                end)

                local target = units[1]
                if target then
                    -- Mark the target for 5 seconds so it is not picked again
                    UTIL:addUnitTag(target, "legiontd_cyclone", 5)
                    -- Cast the ability
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end

            -- Trigger: at least two enemies inside the cast range
            self.abilities[1].SkillTrigger = function(ability, entity)
                -- Is there at least two enemies within 600, the cast range?
                return CheckEnemyCountInRangeEx(ability, entity, false, 2, 600, nil)
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
