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
            self.abilities[1] = self:FindAbilityByName("shadow_imp")
            if self.abilities[1] then 
                self.abilities[1].Skill = UseSkillNoTarget
                self.abilities[1].SkillTrigger = function (ability, entity)
                    return CheckEnemyCountInRange(ability, entity,1,1000)
                end
            end
            
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
