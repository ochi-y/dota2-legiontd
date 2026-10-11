require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local shadow_death_pact = self:FindAbilityByName("shadow_death_pact")
        if shadow_death_pact then
            table.insert(self.abilities, shadow_death_pact)
            shadow_death_pact.Skill = function(entity, ability)
                local target = AiGetPresetCastTarget(ability, nil)

                if not target then
                    local units = AiFindAbilityTarget(entity, ability, {})
                    units = AiFilterNoTag(units, "shadow_death_pact")
                    units = AiFilterNotKing(units)
                    units = AiOrderByHealth(units, false)
                    TableRemoveByValue(units, entity)
                    ArrayRemove(units, function(v)
                        return v:GetUnitName() == "shadow_fire_archer"
                    end)
                    --
                    target = units[1]
                end

                if target then
                    UTIL:addUnitTag(target, "shadow_death_pact", 2)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return true
                end
                return nil
            end
            shadow_death_pact.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 1000, nil)
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill

            self:ReloadAiAbility()

            --shadow_death_pact.CustomAffectRadius = shadow_death_pact:GetSpecialValueFor("wave_width") -- Very suboptimal, should check rectangle from caster instead
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
