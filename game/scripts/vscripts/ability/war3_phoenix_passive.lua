LinkLuaModifier("modifier_war3_phoenix_passive", "ability/war3_phoenix_passive", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if war3_phoenix_passive == nil then
    war3_phoenix_passive = class({})
end
function war3_phoenix_passive:GetIntrinsicModifierName()
    return "modifier_war3_phoenix_passive"
end
---------------------------------------------------------------------
-- Modifiers

modifier_war3_phoenix_passive = class({
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    IsBuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})

function modifier_war3_phoenix_passive:OnCreated(params)
    local ability = self:GetAbility()
    self.hp_lose = ability:GetSpecialValueFor("hp_lose") / 10

    if not IsServer() then
        return
    end
    self:StartIntervalThink(0.1)
end
function modifier_war3_phoenix_passive:IsHidden(params)
    return true
end
function modifier_war3_phoenix_passive:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_war3_phoenix_passive:OnDestroy()
    if IsServer() then
    end
end
function modifier_war3_phoenix_passive:OnIntervalThink()
    if not IsServer() then
        return
    end
    local parent = self:GetParent()
    local hp = math.max(0, parent:GetHealth() - self.hp_lose)
    if hp == 0 then
        parent:Kill(self:GetAbility(), parent)
    else
        parent:SetHealth(hp)
    end
end
function modifier_war3_phoenix_passive:DeclareFunctions()
    return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_war3_phoenix_passive:OnDeath(params)
    if IsServer() then
        if params.unit == self:GetParent() then

			local attacker=params.attacker
			if attacker and attacker==self:GetCaster() then
				return
			end

				
            local caster = self:GetCaster()
            -- caster:AddEffects(EF_NODRAW) 
            local pos = caster:GetAbsOrigin()
            local pid = caster:GetPlayerOwnerID()
            local hero = PlayerResource:GetSelectedHeroEntity(pid)
            
			-- local tUnit = CreateUnitByName("war3_phoenix_egg", pos, false, hero, hero, caster:GetTeamNumber())

			local tUnit=OnZhaoHuan( "war3_phoenix_egg",caster,pos,caster:GetTeamNumber(),nil,1,"null")  

           -- tUnit:SetControllableByPlayer(pid, true)

            EmitSoundOn("phoenix_phoenix_bird_death_defeat", tUnit)
            SimpleMoveUnit(tUnit, pos)

			Timers:CreateTimer(FrameTime(),function ()
				UTIL_Remove(caster)
			end)
        end
    end
    return 0
end

