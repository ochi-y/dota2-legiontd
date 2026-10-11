require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("beast_fireball")
        if self.abilities[1] then
            self.abilities[1].Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                print(#units)
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNoModifier(units, "modifier_beast_fireball_think_burn")
                units = AiFilterNoTag(units, "beast_fireball")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, self.abilities[1], "modifier_orc_storm_bolt_tag", {duration=1})
                    UTIL:addUnitTag(target, "beast_fireball", 2)
                    local unitsA = AiFindAbilityTarget(entity, ability, {
                        pos=target:GetAbsOrigin(),
                        radius=400
                    })
                    for index, unit in ipairs(unitsA) do
                        UTIL:addUnitTag(unit, "beast_fireball", 2)
                    end

                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            self.abilities[1].SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 800, nil)
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
