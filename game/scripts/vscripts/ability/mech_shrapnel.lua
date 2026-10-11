LinkLuaModifier("modifier_mech_shrapnel", "ability/mech_shrapnel.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if mech_shrapnel == nil then
    mech_shrapnel = class({})
end
function mech_shrapnel:GetIntrinsicModifierName()
    return "modifier_mech_shrapnel"
end
---------------------------------------------------------------------
-- Modifiers
modifier_mech_shrapnel = class({
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
function modifier_mech_shrapnel:OnCreated(params)
    if not self:GetAbility() then return end
    if IsServer() then
    end

    local ability=self:GetAbility()
    self.chance=ability:GetSpecialValueFor("chance")
    self.damage=ability:GetSpecialValueFor("damage")
    self.count=ability:GetSpecialValueFor("count")

end
function modifier_mech_shrapnel:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_mech_shrapnel:OnDestroy()
    if IsServer() then
    end
end
function modifier_mech_shrapnel:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK}
end
function modifier_mech_shrapnel:OnAttack(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end

    if RandomInt(1, 100) <= self.chance then
        local count=self.count
        local damage=self.damage

        local ability = self:GetAbility()
        local target = params.target
        local caster = self:GetParent()

        local targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 300,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		local c=0
		for i = 1,#targets do
            EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage.Launch", caster)
            EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage.Impact", targets[i])
            SimplePlayLink("particles/econ/items/gyrocopter/hero_gyrocopter_atomic/gyro_rocket_barrage_atomic.vpcf",caster,targets[i],nil,nil,"attach_attack1")
            SimpleApplyDamage(self:GetAbility(),caster,targets[i],damage)
            c=c+1
            if c>=count then
                break
            end
		end
    end
end
