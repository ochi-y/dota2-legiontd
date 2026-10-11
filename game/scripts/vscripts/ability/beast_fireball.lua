if beast_fireball == nil then
    beast_fireball = class({})
end

function beast_fireball:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local missile_speed = self:GetSpecialValueFor("missile_speed")

    if not target or not IsValidEntity(target) or not target:IsAlive() then
        return
    end

    local projectile = "particles/econ/items/dragon_knight/dk_2022_immortal/dk_2022_immortal_dragon_tail_dragon_projectile.vpcf"

    SimpleTrackingProjectile(self, caster, target, projectile, missile_speed)
    EmitSoundOn("Hero_AbyssalUnderlord.Firestorm.Cast", caster)
end

function beast_fireball:OnProjectileHit(hTarget, vLocation)
    if not IsServer() then
        return true
    end

    if not hTarget or not IsValidEntity(hTarget) or not hTarget:IsAlive() then
        return true
    end

    local caster = self:GetCaster()
    local origin = hTarget:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")


    EmitSoundOn("Hero_DragonKnight.Fireball.Target", hTarget)

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        origin,
        nil,
        radius,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(),
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        SimpleApplyDamage(self, caster, enemy, damage, DAMAGE_TYPE_MAGICAL)
    end

    return true
end

function beast_fireball:GetAOERadius()
    return tonumber(self:GetSpecialValueFor("radius")) or 0
end
