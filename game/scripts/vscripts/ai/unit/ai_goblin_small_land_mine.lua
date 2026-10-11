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
            self.abilities[1] = self:FindAbilityByName("goblin_kaboom")
            if self.abilities[1] then 
                self.abilities[1].Skill = UseSkillNoTarget
                self.abilities[1].SkillTrigger = function (ability,entity)
                    return CheckEnemyCountInRangeEx(ability, entity,false,1,150,nil)
                end
            end
            
            self.abilities[2] = self:FindAbilityByName("goblin_blast_off")
            if self.abilities[2] then 
                self.abilities[2].Skill = function(entity, ability)
                    local target = nil
                    -- search units
                    local units = AiFindAbilityTarget(entity, ability)
                    -- units filter
                    -- units = AiFilterHealthPct(units, 100)
                    -- units = AiFilterNoModifier(units, "modifier_marine_sphere_buff")
                    -- units = AiFilterNoModifier(units, "modifier_marine_sphere_tag")
                    -- units sort
                    -- units = AiOrderByHealth(units, false)
                    -- cast ability
                    target = units[1]
    
                    if target then
                        -- target:AddNewModifier(entity, self.abilities[1], "modifier_marine_sphere_tag", { duration = 1 })
                        entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                        return 1
                    end
                    return nil
                end
                self.abilities[2].SkillTrigger = function (ability,entity)
                    return CheckEnemyCountInRangeEx(ability, entity,true,1,500,nil)
                end
            end

            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
