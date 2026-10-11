require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local ghost_catastrophe = self:FindAbilityByName("ghost_catastrophe")
        if ghost_catastrophe then
            table.insert(self.abilities, ghost_catastrophe)
            ghost_catastrophe.Skill = function(entity, ability)
                return UseSkillTargetNoModifier(entity, ability, "modifier_ghost_catastrophe",
                    "modifier_ghost_catastrophe_tag")
            end
            ghost_catastrophe.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, nil, nil)
            end
        end

        local ghost_soul_assumption = self:FindAbilityByName("ghost_dark_portrait")
        if ghost_soul_assumption then
            table.insert(self.abilities, ghost_soul_assumption)
            ghost_soul_assumption.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})

                ArrayRemove(units, function (v)
                    return GamePlay:GetUnitCreepValue(v)==nil
                end)

                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")
                units = AiFilterNoTag(units, "ghost_dark_portrait")
                -- units = AiOrderByHealth(units, false)
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, ghost_soul_assumption, "modifier_orc_storm_bolt_tag", {duration=1})
                    UTIL:addUnitTag(target, "ghost_dark_portrait", 2)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            ghost_soul_assumption.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 800, nil)
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
