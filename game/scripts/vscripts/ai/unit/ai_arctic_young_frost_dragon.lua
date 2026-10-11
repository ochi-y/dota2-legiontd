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
            self.abilities[1] = self:FindAbilityByName("arctic_breath_of_frost")
            if self.abilities[1] then
                self.abilities[1].Skill = UseSkillTargetOnClosest
                self.abilities[1].SkillTrigger = function (ability, entity)
                    return CheckEnemyCountInRangeEx(ability, entity,false,1,300,nil)
                end
            end
            
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            self.Unstuck = Unstuck
            self.NextWayPoint = NextWayPoint
        end,
        0
    )
end
