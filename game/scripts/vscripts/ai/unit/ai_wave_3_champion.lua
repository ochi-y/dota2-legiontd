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
            self.Unstuck = Unstuck
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            self.NextWayPoint = NextWayPoint
            self.wayPointRadius=150
            -- 
            self.abilities = {}
            self.abilities[1] = self:FindAbilityByName("wave_3_champion_sand_storm")
            if self.abilities[1] then 
                self.abilities[1].Skill = function(entity, ability)
                    entity:CastAbilityNoTarget(ability,-1)
                    return 0.5
                end
                self.abilities[1].SkillTrigger = function (ability,entity)
                    return CheckEnemyCountInRangeEx(ability, entity,false,1,200,nil)
                end
            end
        end,
        0
    )
end



