demi_human_fissure = class({})

function demi_human_fissure:OnSpellStart()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local duration_creeps = self:GetSpecialValueFor("duration_creeps")
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage")

    local clap_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf",
        PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(clap_particle, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(clap_particle)

    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	--
    self:GetCaster():EmitSound("Hero_Centaur.HoofStomp")

    for k, v in pairs(units) do
        if not v:HasFlyMovementCapability() then
            ApplyDamage({
                victim = v,
                attacker = caster,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self
            })
			v:AddNewModifier(caster, self, 'modifier_stunned', {
                duration = 2
            })
        end
    end
end
