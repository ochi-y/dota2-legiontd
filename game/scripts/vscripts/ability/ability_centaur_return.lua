LinkLuaModifier("modifier_ability_centaur_return", "ability/ability_centaur_return", 0)

ability_centaur_return = class({
    GetIntrinsicModifierName = function() return "modifier_ability_centaur_return" end
})


wave_15_champion_return=ability_centaur_return

modifier_ability_centaur_return = class({
    isHidden = function() return true end,
    IsPurgable = function() return false end,
    IsBuff = function() return true end,
    DeclareFunctions = function() return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    } end
})

function modifier_ability_centaur_return:OnCreated()
    self.return_damage = self:GetAbility():GetSpecialValueFor("return_damage")
end

function modifier_ability_centaur_return:OnRefresh()
    self:OnCreated()
end

function modifier_ability_centaur_return:OnAttackLanded(params)

    if not IsServer() then return end

    local victim = params.target

    print(victim == self:GetParent() , victim:PassivesDisabled() == false , not params.attacker:IsOther())
    if victim == self:GetParent() and victim:PassivesDisabled() == false and not params.attacker:IsOther() then
        --local str_damage = victim:GetStrength() / 100 * self.str_to_damage
        local damage = self.return_damage 
        if params.attacker:IsBuilding() then
            damage = damage / 2
        end
        ApplyDamage({
            victim = params.attacker,
            attacker = victim,
            ability = self:GetAbility(),
            damage = damage,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
        })
        local particle = "particles/units/heroes/hero_centaur/centaur_return.vpcf"
	    local fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, victim)
	    ParticleManager:SetParticleControlEnt(fx, 0, victim, PATTACH_POINT_FOLLOW, "attach_hitloc", victim:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(fx, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(fx)
    end
end