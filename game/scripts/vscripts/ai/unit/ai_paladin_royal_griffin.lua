require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local paladin_mystic_flare = self:FindAbilityByName("paladin_mystic_flare")
        if paladin_mystic_flare then
            table.insert(self.abilities, paladin_mystic_flare)
            paladin_mystic_flare.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
               --  units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_paladin_mystic_flare_tag")
                units = AiFilterNoTag(units, "paladin_mystic_flare")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, paladin_mystic_flare, "modifier_paladin_mystic_flare_tag", {duration=1})
                    UTIL:addUnitTag(target, "paladin_mystic_flare", 1)
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            paladin_mystic_flare.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 1100, nil)
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
