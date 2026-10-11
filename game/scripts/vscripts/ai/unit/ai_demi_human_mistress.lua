require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local demi_human_seduce = self:FindAbilityByName("demi_human_seduce")

        local demi_human_sonic_wave = self:FindAbilityByName("demi_human_sonic_wave")
        if demi_human_sonic_wave then
            table.insert(self.abilities,demi_human_sonic_wave)
            demi_human_sonic_wave.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")

                -- units = AiFilterNoTag(units, "orc_storm_bolt")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, demi_human_sonic_wave, "modifier_orc_storm_bolt_tag", {duration=1})
                    -- UTIL:addUnitTag(target,"orc_storm_bolt",1)
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            demi_human_sonic_wave.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 550, nil)
            end
        end
        
        if demi_human_seduce then
            table.insert(self.abilities,demi_human_seduce)
            demi_human_seduce.Skill = function(entity, ability)
                local units = AiFindAbilityTarget(entity, ability, {})
                units = AiFilterNoModifier(units, "modifier_demi_human_seduce")
                units = AiFilterNoModifier(units, "modifier_demi_human_seduce_tag")
                local target = units[1]
                if target then
                    local affectUnits = AiFindAbilityTarget(entity, ability, { radius = 350, pos = target:GetAbsOrigin() })
                    for _, affectUnit in ipairs(affectUnits) do
                        affectUnit:AddNewModifier(entity, demi_human_seduce, "modifier_demi_human_seduce_tag",
                            { duration = 1 })
                    end
                    target:AddNewModifier(entity, demi_human_seduce, "modifier_demi_human_seduce_tag", { duration = 1 })
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return true
                end
                return false
            end
            demi_human_seduce.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, nil, nil)
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
