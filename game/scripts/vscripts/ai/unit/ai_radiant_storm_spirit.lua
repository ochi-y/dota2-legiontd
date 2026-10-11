require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local radiant_storm_spirit_static_remnant = self:FindAbilityByName("radiant_storm_spirit_static_remnant")
        
        if radiant_storm_spirit_static_remnant then
            --
            table.insert(self.abilities, radiant_storm_spirit_static_remnant)
            radiant_storm_spirit_static_remnant.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_radiant_storm_spirit_static_remnant_tag")
                -- units = AiFilterNoTag(units, "radiant_storm_spirit_static_remnant")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, radiant_storm_spirit_static_remnant, "modifier_radiant_storm_spirit_static_remnant_tag", {duration=1})
                    -- UTIL:addUnitTag(target,"radiant_storm_spirit_static_remnant",1)
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            radiant_storm_spirit_static_remnant.SkillTrigger = function(ability, entity)

                print("SkillTrigger")
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 600, nil)
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
