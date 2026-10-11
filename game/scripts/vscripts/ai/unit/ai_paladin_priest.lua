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
            self.abilities[1] = self:FindAbilityByName("paladin_heal")
            if self.abilities[1] then 
                self.abilities[1].Skill = function (entity, ability)
                    local units=AiFindAbilityTarget(entity,ability,{})
                    units=AiFilterNoModifier(units,"modifier_paladin_heal_tag")
                    units=AiOrderByHealthLose(units,false)
                    -- 
                    local health=ability:GetSpecialValueFor("health")
                    -- 
                    local target= units[1]
                    if target and (target:GetMaxHealth()-target:GetHealth())>health/2 then
                        target:AddNewModifier(entity, self.abilities[1], "modifier_paladin_heal_tag", {duration=0.6})
                        entity:CastAbilityOnTarget(target, ability, -1)
                        return true
                    end
                    return nil
                end
                self.abilities[1].SkillTrigger = function (ability, entity)
                    return true
                end
            end
            
            --self.abilities[1].CustomAffectRadius = self.abilities[1]:GetSpecialValueFor("wave_width") -- Very suboptimal, should check rectangle from caster instead
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
