require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkSwitchTarget
            self.FindNewAttackTarget = function (entity)
                if self:HasModifier("modifier_toggle_debuff_maker") then
                    return FindNewAttackTargetNoModifier(entity,"modifier_beast_gnoll_poison_debuff")    
                else
                    return StandardFindNewAttackTarget(entity)
                end
            end  
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            --
            self.Unstuck = Unstuck
            self.NextWayPoint = NextWayPoint
        end,
        0
    )
end
