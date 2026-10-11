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
            self.abilities[1] = self:FindAbilityByName("element_mud_golem_hurl_boulder")  
            if self.abilities[1] then 
                self.abilities[1].Skill = function(entity, ability)
                    local units = AiFindAbilityTarget(entity, ability,{})
                    units = AiFilterNoModifier(units, "modifier_stunned")
                    units = AiFilterNoModifier(units, "modifier_element_mud_golem_hurl_boulder_tag")
                    local target =units[1]
                    if target then
                        target:AddNewModifier(entity, self.abilities[1], "modifier_element_mud_golem_hurl_boulder_tag", {duration=1})
                        entity:CastAbilityOnTarget(target, ability, -1)
                        return 1
                    end
                    -- 
                    return nil
                end
                self.abilities[1].SkillTrigger = function (ability, entity)
                    return CheckEnemyCountInRangeEx(ability, entity,false,1,nil,nil)
                end  
            end
            
            self.FindNewAttackTarget = StandardFindNewAttackTarget  
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)  
        end,
        0
    )
end
