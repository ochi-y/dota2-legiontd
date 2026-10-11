require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local nature_overgrowth = self:FindAbilityByName("nature_overgrowth")
        if nature_overgrowth then
            table.insert(self.abilities, nature_overgrowth)
            nature_overgrowth.Skill = function(entity, ability)
                -- search units
                local radius = ability:GetSpecialValueFor("radius")
                local units = AiFindAbilityTarget(entity, ability, {
                    radius = radius
                })
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNotStunned(units)
                units = AiFilterNoModifier(units, "modifier_nature_overgrowth")
                units = AiFilterNoTag(units, "nature_overgrowth")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, self.abilities[1], "modifier_orc_storm_bolt_tag", {duration=1})
                    -- UTIL:addUnitTag(target,"orc_storm_bolt",1)
                    UTIL:addUnitTagAOE(ability, target:GetAbsOrigin(), radius, "nature_overgrowth", 1)
                    entity:CastAbilityNoTarget(ability, -1)
                    return 1
                end
                return nil
            end
            nature_overgrowth.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 250, nil)
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
