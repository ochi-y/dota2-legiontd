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
            self.abilities[1] = self:FindAbilityByName("ghost_disturb")  
            if self.abilities[1] then 
                self.abilities[1].Skill = function (entity, ability)
                    return UseSkillTargetNoModifier(entity, ability,"modifier_ghost_disturb","modifier_ghost_disturb_tag")
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
