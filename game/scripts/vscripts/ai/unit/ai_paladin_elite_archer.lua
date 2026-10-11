require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local paladin_focus_fire = self:FindAbilityByName("paladin_focus_fire")
        if paladin_focus_fire then
            table.insert(self.abilities, paladin_focus_fire)
            paladin_focus_fire.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_paladin_focus_fire_tag")
                units = AiFilterNoTag(units, "paladin_focus_fire")
                ArrayOrderByMapFunc(units, function(v)
                    return -v:GetHealth()
                end)
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, paladin_focus_fire, "modifier_paladin_focus_fire_tag", {duration=1})
                    UTIL:addUnitTag(target, "paladin_focus_fire", 0.3)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            paladin_focus_fire.SkillTrigger = function(ability, entity)
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
