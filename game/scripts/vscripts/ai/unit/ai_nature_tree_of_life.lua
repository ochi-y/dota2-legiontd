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
            self.abilities[1] = self:FindAbilityByName("ab_treant_living_armor")
            -- 
            if self.abilities[1] then 
                self.abilities[1].Skill = function(entity, ability)
                    local target = nil
                    local targetFighterId = GamePlay:FighterGetAbilityTarget(self.fighterId, ability:GetAbilityName())
                    local targetFighter = GamePlay:FighterGetUnit(targetFighterId)

                    if IsActiveUnit(targetFighter) and not targetFighter:HasModifier("modifier_ab_treant_living_armor") and (targetFighter:GetAbsOrigin() - self:GetAbsOrigin()):Length2D() < 1200 then
                        target = targetFighter
                    else
                        local units = AiFindAbilityTarget(entity, ability,{})
                        units = AiFilterNoModifier(units, "modifier_ab_treant_living_armor")
                        units = AiFilterNoTag(units, "ab_treant_living_armor")
                        units = AiFilterNotBuilding(units)

                        units = AiOrderByHealth(units, false)
                        target = units[1]
                    end
                    if target then
                        --target:AddNewModifier(entity, self.abilities[1], "modifier_ab_treant_living_armor_tag", {duration=1})
                        UTIL:addUnitTag(target,"ab_treant_living_armor",1)
                        entity:CastAbilityOnTarget(target, ability, -1)
                        return 1
                    end
                    return nil
                end
                self.abilities[1].SkillTrigger = CheckFriendAbilityRange
            end  
            --self.abilities[1].CustomAffectRadius = self.abilities[1]:GetSpecialValueFor("wave_width") -- Very suboptimal, should check rectangle from caster instead
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end

