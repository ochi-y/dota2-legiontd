demi_human_sonic_wave = {}

function demi_human_sonic_wave:OnSpellStart()
	local caster = self:GetCaster()

	local unit_count = self:GetSpecialValueFor('unit_count')

	local id = ProjectileManager:CreateLinearProjectile({
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		EffectName = "particles/units/heroes/hero_queenofpain/queen_sonic_wave.vpcf",
		fDistance = self:GetSpecialValueFor("distance"),
		fStartRadius = self:GetSpecialValueFor("starting_aoe"),
		fEndRadius = self:GetSpecialValueFor("final_aoe"),
		bHasFrontalCone = false,
		vVelocity = (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("speed"),
		bDeleteOnHit = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES ,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		bProvidesVision = false,

		ExtraData = {
			cast_loc_x = (caster:GetAbsOrigin().x),
			cast_loc_y = (caster:GetAbsOrigin().y),
			cast_loc_z = (caster:GetAbsOrigin().z)
		}
	})

	if not self.projectiles then
		self.projectiles = {}
	end
	self.projectiles[id] = {
		unit_count = unit_count,
		cast_loc_x = (caster:GetAbsOrigin().x),
		cast_loc_y = (caster:GetAbsOrigin().y),
		cast_loc_z = (caster:GetAbsOrigin().z)
	}

	EmitSoundOn("Hero_QueenOfPain.SonicWave", caster)
end

function demi_human_sonic_wave:OnProjectileHitHandle(target, location, id)
	if not target then
		return
	end

	local data = self.projectiles[id]

	if data.unit_count <= 0 then
		return false
	end
	data.unit_count = data.unit_count - 1

	local damage = self:GetSpecialValueFor("damage")

	ApplyDamage({
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self
	})


	local caster = self:GetCaster()

	-- local direction=caster:GetAbsOrigin()
	local castPos = Vector(data.cast_loc_x, data.cast_loc_y, data.cast_loc_z)

	local direction = (target:GetAbsOrigin() - castPos):Normalized()

	local knockback = target:AddNewModifier(
		self:GetCaster(),           -- player source
		self,                       -- ability source
		"modifier_generic_knockback_lua", -- modifier name
		{
			distance = 150,
			height = 0,
			duration = 1,
			direction_x = direction.x,
			direction_y = direction.y,
			IsStun = false,
			stuckByTerrain = true
		} -- kv
	)
end
