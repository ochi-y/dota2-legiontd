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
            self.abilities[1] = self:FindAbilityByName("undead_firestorm")
            if self.abilities[1] then 
                self.abilities[1].Skill = function(entity, ability)
                    -- search units
                    local units = AiFindAbilityTarget(entity, ability,{})
                    -- units filter 
                    -- units = AiFilterHealthPct(units, 100)
                    units = AiFilterNoModifier(units, "modifier_king_firestorm_thinker")
                   -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")
                    units = AiFilterNoTag(units, "undead_firestorm")
                    -- print("tag",#units)
                    -- units sort
                    -- cast ability
                    local target =units[1]
                    if target then
                        -- target:AddNewModifier(entity, self.abilities[1], "modifier_orc_storm_bolt_tag", {duration=1})
                        UTIL:addUnitTag(target,"undead_firestorm",1)
                        entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                        return 1
                    end
                    return nil
                end
                self.abilities[1].SkillTrigger = function (ability, entity)

                    print("CheckEnemyCountInRangeEx")
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
