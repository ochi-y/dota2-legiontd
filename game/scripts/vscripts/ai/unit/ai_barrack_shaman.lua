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
            self.abilities[1] = self:FindAbilityByName("barrack_blood_rush")
            if self.abilities[1] then 
                self.abilities[1].Skill = function (entity, ability)
                    local units=AiFindAbilityTarget(entity,ability,{})
                    units=AiFilterNoModifier(units,"modifier_barrack_blood_rush_buff")
                    units=AiFilterNoModifier(units,"modifier_barrack_blood_rush_tag")
                    units=AiOrderByHealth(units,false)
                    local target= units[1]
                    if target then
                        target:AddNewModifier(entity, self.abilities[1], "modifier_barrack_blood_rush_tag", {duration=1})
                        entity:CastAbilityOnTarget(target, ability, -1)
                        return 1
                    end
                    return nil
                end
                self.abilities[1].SkillTrigger = function (ability, entity)
                    return CheckEnemyCountInRange(ability, entity,1,1200)
                end
            end
            --self.abilities[1].CustomAffectRadius = self.abilities[1]:GetSpecialValueFor("wave_width") -- Very suboptimal, should check rectangle from caster instead
            self.Unstuck = Unstuck
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            self.NextWayPoint = NextWayPoint
            self.wayPointRadius=150
        end,
        0
    )
end
