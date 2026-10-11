require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill
            self.abilities = {}


            self.abilities[1] = self:FindAbilityByName("elf_nightsaber_elite_lucent_beam")
   
            if self.abilities[1] then 
                self.abilities[1].Skill = function(entity, ability)
                    -- search units
                    local units = AiFindAbilityTarget(entity, ability,{})
                    -- units filter 
                    -- units = AiFilterHealthPct(units, 100)
                    units = AiFilterNoTag(units, "elf_nightsaber_elite_lucent_beam")
                    -- print("tag",#units)
                    -- units sort
                    -- cast ability
                    local target =units[1]
                    if target then
                        UTIL:addUnitTag(target,"elf_nightsaber_elite_lucent_beam",1)
                        entity:CastAbilityOnTarget(target, ability, -1)
                        return 1
                    end
                    return nil
                end
                self.abilities[1].SkillTrigger = function (ability, entity)
                    return CheckEnemyCountInRangeEx(ability, entity,false,1,nil,nil)
                end  
            end
            -- 
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            -- 
        end,
        0
    )
end
