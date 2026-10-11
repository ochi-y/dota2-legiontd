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
            self.abilities[1] = self:FindAbilityByName("demi_human_reverse_polarity")
            if self.abilities[1] then 
                self.abilities[1].Skill = function(entity, ability)
                    -- search units
                    local units = AiFindAbilityTarget(entity, ability,{
                        radius=ability:GetSpecialValueFor("pull_radius")
                    })
                    -- units filter 
                    -- units = AiFilterHealthPct(units, 100)
                    units = AiFilterNotStunned(units)
                   -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")
                    units = AiFilterNoTag(units, "demi_human_reverse_polarity")
                    -- print("tag",#units)
                    -- units sort
                    -- cast ability
                    local target =units[1]
                    if target then
                        -- target:AddNewModifier(entity, self.abilities[1], "modifier_orc_storm_bolt_tag", {duration=1})
                        -- UTIL:addUnitTag(target,"orc_storm_bolt",1)
                        for _, unit in ipairs(units) do
                            UTIL:addUnitTag(unit,"demi_human_reverse_polarity",2)
                        end
                        entity:CastAbilityNoTarget(ability, -1)
                        return 1
                    end
                    return nil
                end
                self.abilities[1].SkillTrigger = function (ability, entity)
                    return CheckUnstunEnemyCountInRange(ability, entity,1,200)
                end
            end
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
