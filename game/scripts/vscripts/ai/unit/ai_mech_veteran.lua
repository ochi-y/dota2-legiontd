require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local mech_sidekick = self:FindAbilityByName("mech_sidekick")
        if mech_sidekick then
            table.insert(self.abilities, mech_sidekick)
            mech_sidekick.Skill = function(entity, ability)
                local target = AiGetPresetCastTarget(ability, nil)

                if not target then
                    local units = AiFindAbilityTarget(entity, ability, {})
                    units = AiFilterNoModifier(units, "modifier_mech_sidekick")
                    units = AiFilterNoTag(units, "mech_sidekick")
                    ArrayRemoveValue(units, entity)
                    ArrayRemove(units, function(v)
                        return v:GetUnitName() == entity:GetUnitName()
                    end)
                    units = AiOrderByDps(units, false)
                    target = units[1] or entity
                end
                if target then
                    -- target:AddNewModifier(entity, mech_sidekick, "modifier_mech_sidekick_tag", {duration=0.6})
                    UTIL:addUnitTag(target, "mech_sidekick", 1)
                    UTIL:addUnitTag(entity, "mech_sidekick", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return true
                end
                return nil
            end
            mech_sidekick.SkillTrigger = function(ability, entity)
                return true
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
