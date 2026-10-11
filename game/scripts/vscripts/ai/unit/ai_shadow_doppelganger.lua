require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local shadow_chronosphere = self:FindAbilityByName("shadow_chronosphere")
        if shadow_chronosphere then
            table.insert(self.abilities, shadow_chronosphere)
            shadow_chronosphere.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                print(#units)
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNoModifier(units, "modifier_shadow_chronosphere_effect")
                -- units = AiFilterNoModifier(units, "modifier_shadow_chronosphere_tag")
                units = AiFilterNoTag(units, "shadow_chronosphere")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, shadow_chronosphere, "modifier_shadow_chronosphere_tag", {duration=1})
                    -- UTIL:addUnitTag(target, "shadow_chronosphere", 1)
                    UTIL:addUnitTagAOE(ability, target:GetAbsOrigin(), 500, "shadow_chronosphere", 1)
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            shadow_chronosphere.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 450, nil)
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
