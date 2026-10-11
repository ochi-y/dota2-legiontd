require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local mech_earth_splitter = self:FindAbilityByName("mech_earth_splitter")
        if mech_earth_splitter then
            table.insert(self.abilities, mech_earth_splitter)

            mech_earth_splitter.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                --  units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_mech_earth_splitter_tag")

                units = AiFilterNoTag(units, "mech_earth_splitter")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, mech_earth_splitter, "modifier_mech_earth_splitter_tag", {duration=1})
                    UTIL:addUnitTag(target, "mech_earth_splitter", 1)
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            mech_earth_splitter.SkillTrigger = function(ability, entity)


                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 1000, nil)
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
