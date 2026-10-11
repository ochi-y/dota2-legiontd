require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)

    function self:ReloadAiAbility()
        self.abilities = {}
        local orc_storm_bolt = self:FindAbilityByName("orc_storm_bolt")
        if orc_storm_bolt then 
            table.insert(self.abilities,orc_storm_bolt)
            orc_storm_bolt.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability,{})
                -- units filter 
                -- units = AiFilterHealthPct(units, 100)
                 units = AiFilterNoModifier(units, "modifier_stunned")
               -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")

                units = AiFilterNoTag(units, "orc_storm_bolt")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target =units[1]
                if target then
                    -- target:AddNewModifier(entity, orc_storm_bolt, "modifier_orc_storm_bolt_tag", {duration=1})
                    UTIL:addUnitTag(target,"orc_storm_bolt",1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            orc_storm_bolt.SkillTrigger = function (ability, entity)
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
