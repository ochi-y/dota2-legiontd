require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)

    function self:ReloadAiAbility()
        self.abilities = {}
        local marine_frogmen_arm_of_the_deep = self:FindAbilityByName("marine_frogmen_arm_of_the_deep")
        if marine_frogmen_arm_of_the_deep then 
            table.insert(self.abilities,marine_frogmen_arm_of_the_deep)
            marine_frogmen_arm_of_the_deep.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability,{})
                -- units filter 
                units = AiFilterMoveCapability(units, DOTA_UNIT_CAP_MOVE_GROUND)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_marine_frogmen_arm_of_the_deep_tag")

                -- units = AiFilterNoTag(units, "marine_frogmen_arm_of_the_deep")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target =units[1]
                if target then
                    -- target:AddNewModifier(entity, marine_frogmen_arm_of_the_deep, "modifier_marine_frogmen_arm_of_the_deep_tag", {duration=1})
                    -- UTIL:addUnitTag(target,"marine_frogmen_arm_of_the_deep",1)
                    -- entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            marine_frogmen_arm_of_the_deep.SkillTrigger = function (ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity,false,1,600,nil)
            end  
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill
            self:ReloadAiAbility()
            -- 
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            -- 
        end,
        0
    )
end
