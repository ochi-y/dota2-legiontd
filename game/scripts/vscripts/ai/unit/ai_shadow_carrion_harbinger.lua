require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local shadow_conjure_fanatic = self:FindAbilityByName("shadow_conjure_fanatic")
        if shadow_conjure_fanatic then
            table.insert(self.abilities, shadow_conjure_fanatic)
            shadow_conjure_fanatic.Skill = UseSkillNoTarget
            shadow_conjure_fanatic.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 1000)
            end
        end

        local riven_broken_wings = self:FindAbilityByName("riven_broken_wings")
        if riven_broken_wings then
            table.insert(self.abilities, riven_broken_wings)
            riven_broken_wings.Skill = function(entity, ability)
                local units = AiFindAbilityTarget(entity, ability,{
                    radius=225
                })
                
                -- units = AiFilterNotStunned(units)
                -- units = AiFilterNoTag(units, "riven_broken_wings")
                local target = units[1]
                if target then
                    --local radius = ability:GetSpecialValueFor("radius")
                    -- local affectedUnits = AiFindAbilityTarget(entity, ability, {
                    --     pos = target:GetAbsOrigin(),
                    --     radius = radius
                    -- })
                    -- for _, affectedUnit in ipairs(affectedUnits) do
                    --     UTIL:addUnitTag(affectedUnit, "riven_broken_wings", 2)
                    -- end
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return true
                end
                --
                return false
            end
            riven_broken_wings.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 225)
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
