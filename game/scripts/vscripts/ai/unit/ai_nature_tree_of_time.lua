require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local nature_furion_sprout = self:FindAbilityByName("nature_furion_sprout")
        if nature_furion_sprout then
            table.insert(self.abilities, nature_furion_sprout)

            nature_furion_sprout.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                --  units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_nature_furion_sprout_tag")
                units = AiFilterNoTag(units, "nature_furion_sprout")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, nature_furion_sprout, "modifier_nature_furion_sprout_tag", {duration=1})
                    UTIL:addUnitTag(target, "nature_furion_sprout", 2)
                    UTIL:addUnitTagAOE(ability, target:GetAbsOrigin(), 375, "nature_furion_sprout", 2)
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            nature_furion_sprout.SkillTrigger = function(ability, entity)
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
