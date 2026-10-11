require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)

    function self:ReloadAiAbility()
        self.abilities = {}
            self.abilities[1] = self:FindAbilityByName("elf_warden_phantom_strike")
            if self.abilities[1] then
                self.abilities[1].Skill = function(entity, ability)
                    -- search units
                    local units = AiFindAbilityTarget(entity, ability, {})
                    -- units filter
                    -- units = AiFilterHealthPct(units, 100)

                    -- print("tag",#units)
                    -- units sort
                    -- cast ability

                    units = AiFilterNoTag(units, "elf_warden_phantom_strike")

                    local target = units[1]
                    if target then
                        UTIL:addUnitTag(target, "elf_warden_phantom_strike", 0.1)
                        entity:CastAbilityOnTarget(target, ability, -1)
                        return 1
                    end
                    return nil
                end
                self.abilities[1].SkillTrigger = function(ability, entity)
                    return CheckEnemyCountInRangeEx(ability, entity, false, 1, 700, nil)
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
