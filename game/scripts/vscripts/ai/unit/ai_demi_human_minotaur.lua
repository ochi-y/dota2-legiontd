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
            self.abilities[1] = self:FindAbilityByName("demi_human_tremor")
            if self.abilities[1] then 
                self.abilities[1].Skill = UseSkillNoTarget
                self.abilities[1].SkillTrigger = function (ability, entity)
                    local units=AiFindAbilityTarget(entity,ability,{radius=170})
                    units=AiFilterMoveCapability(units,DOTA_UNIT_CAP_MOVE_GROUND)
                    return #units>=1
                end
            end
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
