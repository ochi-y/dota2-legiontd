require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local undead_reapers_scythe = self:FindAbilityByName("undead_reapers_scythe")
        if undead_reapers_scythe then
            table.insert(self.abilities, undead_reapers_scythe)
            undead_reapers_scythe.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNoModifier(units, "modifier_imba_reapers_scythe")
                units = AiFilterHealthPct(units, 90)
                -- units = AiFilterNoModifier(units, "modifier_undead_reapers_scythe_tag")
                units = AiFilterNoTag(units, "undead_reapers_scythe")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, undead_reapers_scythe, "modifier_undead_reapers_scythe_tag", {duration=1})
                    UTIL:addUnitTag(target, "undead_reapers_scythe", 2)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            undead_reapers_scythe.SkillTrigger = function(ability, entity)
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
