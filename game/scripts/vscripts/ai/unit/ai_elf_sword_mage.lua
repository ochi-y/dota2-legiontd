require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("elf_global_silence")
        if self.abilities[1] then
            self.abilities[1].Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {
                    radius = 1000
                })

                -- units filter
                -- units = AiFilterHealthPct(units, 100)

                units = ArrayFilter(units,function (v)
                    return not v:IsSilenced() and not v:IsStunned()
                end)
                
                -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")
                -- units = AiFilterNoTag(units, "demi_human_reverse_polarity")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                if #units>0 then
                    UTIL:addUnitTag(GamePlay:GetKing(entity:GetTeam()),"arctic_cold_embrace",1)
                    entity:CastAbilityNoTarget(ability, -1)
                    return 1    
                end
            end
            self.abilities[1].SkillTrigger = function(ability, entity)
                if UTIL:checkUnitTag(GamePlay:GetKing(entity:GetTeam()),"arctic_cold_embrace") then
                    return false
                end
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 700, nil)
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill
            self:ReloadAiAbility()
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
