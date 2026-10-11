require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local radiant_monkey_king_boundless_strike = self:FindAbilityByName("radiant_monkey_king_boundless_strike")
        if radiant_monkey_king_boundless_strike then
            table.insert(self.abilities, radiant_monkey_king_boundless_strike)
            radiant_monkey_king_boundless_strike.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")
                units = AiFilterNoTag(units, "radiant_monkey_king_boundless_strike")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, orc_storm_bolt, "modifier_orc_storm_bolt_tag", {duration=1})
                    -- UTIL:addUnitTag(target,"radiant_monkey_king_boundless_strike",1)
                    UTIL:addUnitTagAOE(ability, target:GetAbsOrigin(), 200, "radiant_monkey_king_boundless_strike", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            radiant_monkey_king_boundless_strike.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 400, nil)
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
