require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local foulfell_medusa_mystic_snake = self:FindAbilityByName("foulfell_medusa_mystic_snake")
        if foulfell_medusa_mystic_snake then
            table.insert(self.abilities, foulfell_medusa_mystic_snake)
            foulfell_medusa_mystic_snake.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_foulfell_medusa_mystic_snake_tag")
                units = AiFilterNoTag(units, "foulfell_medusa_mystic_snake")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, foulfell_medusa_mystic_snake, "modifier_foulfell_medusa_mystic_snake_tag", {duration=1})
                    UTIL:addUnitTag(target, "foulfell_medusa_mystic_snake", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            foulfell_medusa_mystic_snake.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 800, nil)
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
            --
        end,
        0
    )
end
