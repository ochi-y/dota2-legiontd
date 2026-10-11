require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local radiant_shadow_shaman_voodoo = self:FindAbilityByName("radiant_shadow_shaman_voodoo")
        if radiant_shadow_shaman_voodoo then
            table.insert(self.abilities, radiant_shadow_shaman_voodoo)
            radiant_shadow_shaman_voodoo.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNoModifier(units, "modifier_stunned")
                 units = AiFilterNoModifier(units, "modifier_radiant_shadow_shaman_voodoo")
                units = AiFilterNoTag(units, "radiant_shadow_shaman_voodoo")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    UTIL:addUnitTag(target, "radiant_shadow_shaman_voodoo", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            radiant_shadow_shaman_voodoo.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 500, nil)
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
