require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("ability_metamorphosis")
        if self.abilities[1] then
            self.abilities[1].Skill = UseSkillNoTarget
            self.abilities[1].SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 1000)
            end
        end

        self.abilities[2] = self:FindAbilityByName("element_sunder")
        if self.abilities[2] then
            self.abilities[2].Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")
                units = AiFilterNoTag(units, "element_sunder")
                units = AiOrderByHealthPct(units, false)
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, self.abilities[2], "modifier_orc_storm_bolt_tag", {duration=1})
                    UTIL:addUnitTag(target, "element_sunder", 2)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            self.abilities[2].SkillTrigger = function(ability, entity)
                if entity:GetHealthPercent() >= 30 then
                    return false
                end
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 475, nil)
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill
            self:ReloadAiAbility()

            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
