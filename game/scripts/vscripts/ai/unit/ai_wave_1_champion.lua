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
            self.abilities[1] = self:FindAbilityByName("wave_1_champion_impale")
            if self.abilities[1] then 
                self.abilities[1].Skill = function(entity, ability)
                    -- search units
                    local units = AiFindAbilityTarget(entity, ability,{})
                    -- units filter 
                    -- units = AiFilterHealthPct(units, 100)
                    units = AiFilterNoModifier(units, "modifier_stunned")
                    units = AiFilterNoModifier(units, "modifier_wave_1_champion_impale_tag")
                    -- print("tag",#units)
                    -- units sort
                    -- cast ability
                    local target =units[1]
                    if target then
                        target:AddNewModifier(entity, self.abilities[1], "modifier_wave_1_champion_impale_tag", {duration=2})
                        -- entity:CastAbilityOnTarget(target, ability, -1)
                        entity:CastAbilityOnPosition(target:GetAbsOrigin(),ability,-1)
                        return 1
                    end
                    return nil
                end
                self.abilities[1].SkillTrigger = function (ability,entity)
                    return CheckEnemyCountInRangeEx(ability, entity,false,1,500,nil)
                end
            end
        end,
        0
    )
end



