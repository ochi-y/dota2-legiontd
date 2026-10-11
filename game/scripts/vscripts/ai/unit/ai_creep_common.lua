require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill
            self.FindNewAttackTarget = StandardFindNewAttackTarget  
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            --
            self.Unstuck = Unstuck
            self.NextWayPoint = NextWayPoint
        end,
        0
    )
end
