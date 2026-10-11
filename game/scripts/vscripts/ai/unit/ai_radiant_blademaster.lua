require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}

        local radiant_juggernaut_healing_ward = self:FindAbilityByName("radiant_juggernaut_healing_ward")

        if radiant_juggernaut_healing_ward then
            table.insert(self.abilities, radiant_juggernaut_healing_ward)
            radiant_juggernaut_healing_ward.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, { radius = 700 })
                -- units filter
                units = AiFilterHealthPct(units, 100)
                units = AiFilterNoModifier(units, "modifier_radiant_juggernaut_healing_ward_aura_buff")
                -- units sort
                -- units = AiOrderByHealthPct(units, true)
                -- units = AiOrderByAttackCap(units, true)
                units = AiFilterNoTag(units, "radiant_juggernaut_healing_ward")
                -- cast ability
                local target = units[1]
                if target then
                    local castPos = target:GetAbsOrigin()
                    if castPos ~= entity:GetAbsOrigin() then
                        local dir = (castPos - entity:GetAbsOrigin()):Normalized()
                        local len = 100
                        if (castPos - entity:GetAbsOrigin()):Length2D() - 400 > 0 then
                            len = math.max((castPos - entity:GetAbsOrigin()):Length2D() - 400, len)
                        end
                        castPos = entity:GetAbsOrigin() + dir * len
                    else
                        castPos = entity:GetAbsOrigin() + entity:GetForwardVector() * 100
                    end
                    UTIL:addUnitTagAOE(ability, castPos, 400, "radiant_juggernaut_healing_ward", 1)
                    entity:CastAbilityOnPosition(castPos, ability, -1)
                    return 1
                end
                return nil
            end
            radiant_juggernaut_healing_ward.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 700)
            end
        end
    end

    self:SetContextThink("init_think", function()
        self.aiThink = aiThinkStandardSkill
        self:ReloadAiAbility()
        self.FindNewAttackTarget = StandardFindNewAttackTarget
        self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
    end, 0)
end
