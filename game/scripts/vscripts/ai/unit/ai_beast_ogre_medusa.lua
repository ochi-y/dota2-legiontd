require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("beast_chain_lightning")
        if self.abilities[1] then
            self.abilities[1].Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")

                units = AiFilterNoTag(units, "beast_chain_lightning")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, self.abilities[1], "modifier_orc_storm_bolt_tag", {duration=1})
                    UTIL:addUnitTag(target, "beast_chain_lightning", 0.5)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            self.abilities[1].SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 800, nil)
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkSwitchTarget
            self.FindNewAttackTarget = function(entity)
                if self:HasModifier("modifier_toggle_debuff_maker") then
                    return FindNewAttackTargetNoModifier(entity, "modifier_beast_enchanted_poison_debuff")
                else
                    return StandardFindNewAttackTarget(entity)
                end
            end
            self:ReloadAiAbility()
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            --
            self.Unstuck = Unstuck
            self.NextWayPoint = NextWayPoint
        end,
        0
    )
end
