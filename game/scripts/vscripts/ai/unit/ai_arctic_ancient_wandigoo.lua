require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local alistar_pulverize = self:FindAbilityByName("alistar_pulverize")
        if alistar_pulverize then
            table.insert(self.abilities, alistar_pulverize)
            alistar_pulverize.Skill = function(entity, ability)
                -- search units
                local radius = ability:GetSpecialValueFor("radius");
                local units = AiFindAbilityTarget(entity, ability, {
                })
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNotStunned(units)
                -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")
                units = AiFilterNoTag(units, "alistar_pulverize")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, self.abilities[1], "modifier_orc_storm_bolt_tag", {duration=1})
                    -- UTIL:addUnitTag(target,"orc_storm_bolt",1)
                    UTIL:addUnitTagAOE(ability, target:GetAbsOrigin(), radius, "alistar_pulverize", 0.5)
                    entity:CastAbilityNoTarget(ability, -1)
                    return 1
                end
                return nil
            end
            alistar_pulverize.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, true, 1, 190, 5)
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
        end,
        0
    )
end
