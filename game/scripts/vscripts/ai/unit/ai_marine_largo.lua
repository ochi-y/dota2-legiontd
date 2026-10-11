require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}

        -- Grab the Catchy Lick ability
        local catchy_lick = self:FindAbilityByName("marine_largo_catchy_lick")
        if catchy_lick then
            table.insert(self.abilities, catchy_lick)

            -- Cast logic
            catchy_lick.Skill = function(entity, ability)
                -- Search for a target
                local units = AiFindAbilityTarget(entity, ability, {})

                -- Skip targets that are already marked, to avoid re-casting
                units = AiFilterNoTag(units, "marine_largo_catchy_lick")

                -- Pick the farthest target
                local target = nil
                local max_distance = 0
                for _, unit in pairs(units) do
                    local distance = (unit:GetOrigin() - entity:GetOrigin()):Length2D()
                    if distance > max_distance then
                        max_distance = distance
                        target = unit
                    end
                end
                if target then
                    -- Mark the target for 2 seconds so it is not cast on twice
                    UTIL:addUnitTag(target, "marine_largo_catchy_lick", 2)
                    -- Cast on the target
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end

            -- Trigger: cast whenever an enemy is in range
            catchy_lick.SkillTrigger = function(ability, entity)
                -- Is there at least one enemy in range?
                -- CheckEnemyCountInRangeEx(ability, entity, needs vision, min count, range, filter)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, nil, nil)
            end
        end
    end

    -- Set up the AI think loop
    self:SetContextThink(
        "init_think",
        function()
            -- Use the standard ability AI think mode
            self.aiThink = aiThinkStandardSkill

            -- Reload the ability config
            self:ReloadAiAbility()

            -- Assign the standard target search function
            self.FindNewAttackTarget = StandardFindNewAttackTarget

            -- Start the AI think loop
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
