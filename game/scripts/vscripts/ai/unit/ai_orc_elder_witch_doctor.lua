require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local orc_paralyzing_cask = self:FindAbilityByName("orc_paralyzing_cask")
        if orc_paralyzing_cask then
            table.insert(self.abilities, orc_paralyzing_cask)
            orc_paralyzing_cask.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNotStunned(units)
                -- units = AiFilterNoModifier(units, "modifier_orc_paralyzing_cask_tag")
                units = AiFilterNoTag(units, "orc_paralyzing_cask")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, orc_paralyzing_cask, "modifier_orc_paralyzing_cask_tag", {duration=1})
                    UTIL:addUnitTag(target, "orc_paralyzing_cask", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            orc_paralyzing_cask.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 500, nil)
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
