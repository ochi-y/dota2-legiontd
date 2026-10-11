require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local element_sun_strike = self:FindAbilityByName("element_sun_strike")
        if element_sun_strike then
            table.insert(self.abilities, element_sun_strike)
            element_sun_strike.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {
                    radius = -1,
                    findOrder = FIND_CLOSEST
                })
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_element_sun_strike_tag")

                units = AiFilterNoTag(units, "element_sun_strike")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, element_sun_strike, "modifier_element_sun_strike_tag", {duration=1})
                    -- UTIL:addUnitTag(target,"element_sun_strike",1)
                    UTIL:addUnitTagAOE(ability, target:GetAbsOrigin(), 175, "element_sun_strike", 0.5)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            element_sun_strike.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, -1, nil)
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
