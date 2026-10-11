LinkLuaModifier( "modifier_ghost_cacophony", "ability/ghost_cacophony.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ghost_cacophony == nil then
	ghost_cacophony = class({})
end
function ghost_cacophony:OnSpellStart()
	local caster=self:GetCaster()

	local count=self:GetSpecialValueFor("count")

	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

	ArrayRemove(units, function(v)
		return v:IsNightmared()
	end)
	local damage=self:GetSpecialValueFor("damage")
	units = Shuffle(units)
	--units = AiOrderByNoModifier(units,"modifier_ghost_nightmare_debuff",true)

	for i = 1, math.min(count,#units) do
		local target=units[i]
		local damage = damage
		-- damage
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self, --Optional.
		}
		ApplyDamage(damageTable)
		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self:GetCaster(),
			PATTACH_POINT_FOLLOW,
			"attach_hitloc",
			self:GetCaster():GetOrigin(), -- unknown
			true -- unknown, true
		)
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			1,
			target,
			PATTACH_POINT_FOLLOW,
			"attach_hitloc",
			target:GetOrigin(), -- unknown
			true -- unknown, true
		)
		ParticleManager:ReleaseParticleIndex( effect_cast )

		-- Create Sound
		EmitSoundOn( "Hero_Bane.BrainSap", self:GetCaster() )
		EmitSoundOn( "Hero_Bane.BrainSap.Target", target )

		caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
	end

end
