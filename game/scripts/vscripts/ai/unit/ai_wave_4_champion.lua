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
            self.abilities[1] = self:FindAbilityByName("wave_5_champion_plague_ward")
            if self.abilities[1] then 
                self.abilities[1].Skill = function(entity, ability)
                    local attacktarget=entity:GetAttackTarget()
                    if attacktarget then
                        local pos=entity:GetAbsOrigin()+200*entity:GetForwardVector()
                        local castPos=RandomPointInRadius(pos,150)        
                        entity:CastAbilityOnPosition(castPos,ability,-1)                    
                    end
                    return nil
                    -- entity:CastAbilityNoTarget(ability,-1)
                    -- return 0.5
                end
                self.abilities[1].SkillTrigger = function (ability,entity)
                    return entity:IsAttacking()
                end
            end
        end,
        0
    )
end



