require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("ghost_soul_assumption")
        if self.abilities[1] then
            self.abilities[1].Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")

                units = AiFilterNoTag(units, "ghost_soul_assumption")
                units = AiOrderByHealth(units, false)
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, self.abilities[1], "modifier_orc_storm_bolt_tag", {duration=1})
                    UTIL:addUnitTag(target, "ghost_soul_assumption", 0.3)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            self.abilities[1].SkillTrigger = function(ability, entity)
                local mod=entity:FindModifierByName("modifier_ghost_soul_assumption_counter")
                if mod and mod:GetStackCount()>=6 then
                    return CheckEnemyCountInRangeEx(ability, entity, false, 1, 1000, nil)    
                end
                return false
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
