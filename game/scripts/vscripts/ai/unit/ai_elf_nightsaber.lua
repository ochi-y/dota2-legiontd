require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("elf_wave_of_terror")
        if self.abilities[1] then
            self.abilities[1].Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")
                units = AiFilterNoTag(units, "elf_wave_of_terror")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, self.abilities[1], "modifier_orc_storm_bolt_tag", {duration=1})

                    local unitsA = AiFindAbilityTarget(entity, ability, {
                        pos = target:GetAbsOrigin(),
                        radius = 350
                    })
                    for _, unit in ipairs(unitsA) do
                        UTIL:addUnitTag(unit, "elf_wave_of_terror", 1)
                    end

                    UTIL:addUnitTag(target, "elf_wave_of_terror", 1)
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            self.abilities[1].SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 1000, nil)
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
