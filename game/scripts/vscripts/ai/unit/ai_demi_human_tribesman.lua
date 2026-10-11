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
            self.abilities[1] = self:FindAbilityByName("demi_human_throw_net_1")

            if self.abilities[1] then 
                self.abilities[1].Skill = function(entity, ability)
                    local units = AiFindAbilityTarget(entity, ability,{})
                    units = AiFilterNoModifier(units, "modifier_demi_human_throw_net")
                    units = AiFilterNoTag(units, "demi_human_throw_net")
                    local target =units[1]
                    if target then
                        UTIL:addUnitTag(target,"demi_human_throw_net",2)
                        entity:CastAbilityOnTarget(target, ability, -1)
                        return 1
                    end
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

