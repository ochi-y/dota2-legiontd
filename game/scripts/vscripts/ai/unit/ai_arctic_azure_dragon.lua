


require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)

    function self:ReloadAiAbility()
        self.abilities={}
        self.abilities[1] = self:FindAbilityByName("arctic_cold_embrace")
        if self.abilities[1] then 
            self.abilities[1].Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability,{})
                -- units filter 
                units = AiFilterHealthPct(units, 50)
               -- units = AiFilterNotStunned(units, "modifier_stunned")
                units = AiFilterNoModifier(units, "modifier_custom_cold_embrace")
                units = AiFilterNoTag(units, "arctic_cold_embrace")

                ArrayRemove(units,function (v)
                    return v:GetMaxHealth()<2000
                end)
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target =units[1]
                if target then
                    -- target:AddNewModifier(entity, self.abilities[1], "modifier_orc_storm_bolt_tag", {duration=1})
                    UTIL:addUnitTag(target,"arctic_cold_embrace",2)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            self.abilities[1].SkillTrigger = function (ability, entity)
                return true
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkSwitchTarget
            self.FindNewAttackTarget = function (entity)
                return StandardFindNewAttackTarget(entity)
            end  
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)

            self:ReloadAiAbility()

        end,
        0
    )
end
