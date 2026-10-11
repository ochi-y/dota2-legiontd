require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local undead_meat_hook = self:FindAbilityByName("undead_meat_hook")
        if undead_meat_hook then
            table.insert(self.abilities, undead_meat_hook)

            undead_meat_hook.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                --  units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_undead_meat_hook_tag")
                units = AiFilterNoTag(units, "undead_meat_hook")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, undead_meat_hook, "modifier_undead_meat_hook_tag", {duration=1})
                    -- UTIL:addUnitTag(target, "undead_meat_hook", 1)
                    UTIL:addUnitTagAOE(ability, target:GetAbsOrigin(), 50, "undead_meat_hook", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            undead_meat_hook.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, nil, nil)
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
