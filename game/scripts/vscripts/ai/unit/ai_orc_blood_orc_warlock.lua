require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local orc_fatal_bonds = self:FindAbilityByName("orc_fatal_bonds")
        if orc_fatal_bonds then
            table.insert(self.abilities, orc_fatal_bonds)
            orc_fatal_bonds.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNoModifier(units, "modifier_orc_fatal_bonds_debuff")
                -- units = AiFilterNoModifier(units, "modifier_orc_fatal_bonds_tag")
                units = AiFilterNoTag(units, "orc_fatal_bonds")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, orc_fatal_bonds, "modifier_orc_fatal_bonds_tag", {duration=1})
                    UTIL:addUnitTag(target, "orc_fatal_bonds", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            orc_fatal_bonds.SkillTrigger = function(ability, entity)
            return CheckEnemyCountInRangeEx(ability, entity, false, 1, 800, nil)
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkSwitchTarget
            self.FindNewAttackTarget = function(entity)
                return StandardFindNewAttackTarget(entity)
            end
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            self:ReloadAiAbility()
        end,
        0
    )
end
