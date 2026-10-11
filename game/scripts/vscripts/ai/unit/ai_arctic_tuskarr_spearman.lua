require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    
    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("arctic_tuskarr_spearman_walrus_kick")
        --
        if self.abilities[1] then
            local tagName = "arctic_tuskarr_spearman_walrus_kick"
            self.abilities[1].Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")
                units = AiFilterNoTag(units, tagName)
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, self.abilities[1], "modifier_orc_storm_bolt_tag", {duration=1})
                    UTIL:addUnitTag(target, tagName, 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            self.abilities[1].SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 275, nil)
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkSwitchTarget
            self.FindNewAttackTarget = function(entity)
                return FindNewAttackTargetNoModifier(entity, "modifier_arctic_ice_spear_2_debuff")
            end
            
            self:ReloadAiAbility()
            --
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            --
            self.Unstuck = Unstuck
            self.NextWayPoint = NextWayPoint
        end,
        0
    )
end
