LinkLuaModifier("modifier_foulfell_medusa_mystic_snake", "ability/foulfell_medusa_mystic_snake.lua",
	LUA_MODIFIER_MOTION_NONE)


foulfell_medusa_mystic_snake = {}

function foulfell_medusa_mystic_snake:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local mana_steal = self:GetSpecialValueFor("snake_mana_steal") / 100
	local jumps = self:GetSpecialValueFor("snake_jumps")
	local radius = self:GetSpecialValueFor("radius")
	local base_damage = self:GetSpecialValueFor("snake_damage")
	local mult_damage = self:GetSpecialValueFor("snake_scale") / 100

	local base_stun = 0
	local mult_stun = 0
	-- if caster:HasScepter() then
	-- 	local ability = caster:FindAbilityByName("medusa_stone_gaze_lua")

	-- 	if self:IsStolen() or (ability and ability:GetLevel() > 0) then
	-- 		base_stun = self:GetSpecialValueFor("stone_form_scepter_base")
	-- 		mult_stun = self:GetSpecialValueFor("stone_form_scepter_increment")
	-- 	end
	-- end

	local index = self:GetUniqueInt()

	local info = {
		Target = target,
		Source = caster,
		Ability = self,

		EffectName = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("initial_speed"),
		bDodgeable = false,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,

		bDrawsOnMinimap = false,
		bVisibleToEnemies = true,
		bProvidesVision = true,
		iVisionRadius = 100,
		iVisionTeamNumber = caster:GetTeamNumber(),

		ExtraData = {
			index = index,
		}
	}
	ProjectileManager:CreateTrackingProjectile(info)

	local data = {}
	data.jump = 0
	data.mana_stolen = 0
	data.isReturning = false
	data.hit_units = {}

	data.jumps = jumps
	data.radius = radius
	data.base_damage = base_damage
	data.mult_damage = mult_damage
	data.base_stun = base_stun
	data.mult_stun = mult_stun
	data.mana_steal = mana_steal
	data.projectile_info = info

	self.projectiles[index] = data

	EmitSoundOn("Hero_Medusa.MysticSnake.Cast", caster)
end

foulfell_medusa_mystic_snake.projectiles = {}

function foulfell_medusa_mystic_snake:OnProjectileHit_ExtraData(target, location, ExtraData)
	local data = self.projectiles[ExtraData.index]

	if data.isReturning then
		self:Returned(data)
		return
	end

	if target and (not target:IsMagicImmune()) and (not target:IsInvulnerable()) then
		data.hit_units[target] = true

		local duration = self:GetSpecialValueFor("duration")
		duration = duration * (1 - CalUnitStatusResistance(target))

		target:AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_foulfell_medusa_mystic_snake",
			{
				duration = duration,
				physical_bonus = self:GetSpecialValueFor("physical_damage_amp"),
				center_unit = self:GetCaster():entindex()
			}
		)

		local damage_type = self:GetAbilityDamageType()
		-- if target:HasModifier("modifier_medusa_stone_gaze_lua_petrified") then
		-- 	damage_type = DAMAGE_TYPE_PURE
		-- end

		local damage = data.base_damage + data.base_damage * data.mult_damage * data.jump
		local damageTable = {
			victim = target,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = damage_type,
			ability = self,
		}

		ApplyDamage(damageTable)

		local mana_taken = math.min(target:GetMaxMana() * data.mana_steal, target:GetMana())
		-- target:ReduceMana( mana_taken )
		data.mana_stolen = data.mana_stolen + mana_taken

		EmitSoundOn("Hero_Medusa.MysticSnake.Target", target)

		data.jump = data.jump + 1

		if data.jump >= data.jumps then
			self:Returning(data, target)
			return
		end
	end

	local pos = location

	if target then
		pos = target:GetOrigin()
	end

	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		pos,
		nil,
		data.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		FIND_CLOSEST,
		false
	)

	local next_target = nil

	for _, enemy in pairs(enemies) do
		local found = false

		for unit, _ in pairs(data.hit_units) do
			if enemy == unit then
				found = true

				break
			end
		end

		if not found then
			next_target = enemy

			break
		end
	end

	if not next_target then
		self:Returning(data, target)
		return
	end

	data.projectile_info.Target = next_target
	data.projectile_info.Source = target
	ProjectileManager:CreateTrackingProjectile(data.projectile_info)
end

function foulfell_medusa_mystic_snake:Returning(data, target)
	if not target then
		self:Returned(data)

		return
	end

	data.isReturning = true

	data.projectile_info.Target = self:GetCaster()
	data.projectile_info.Source = target
	data.projectile_info.EffectName = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile_return.vpcf"
	ProjectileManager:CreateTrackingProjectile(data.projectile_info)
end

function foulfell_medusa_mystic_snake:Returned(data)
	local index = data.projectile_info.ExtraData.index
	self.projectiles[index] = nil
	self:DelUniqueInt(index)

	if not self:GetCaster():IsAlive() then return end

	self:GetCaster():GiveMana(data.mana_stolen)

	local sound_cast = "Hero_Medusa.MysticSnake.Return"
	EmitSoundOn(sound_cast, self:GetCaster())
	SendOverheadEventMessage(
		nil,
		OVERHEAD_ALERT_MANA_ADD,
		self:GetCaster(),
		data.mana_stolen,
		self:GetCaster():GetPlayerOwner()
	)
end

foulfell_medusa_mystic_snake.unique = {}
foulfell_medusa_mystic_snake.i = 0
foulfell_medusa_mystic_snake.max = 65536

function foulfell_medusa_mystic_snake:GetUniqueInt()
	while self.unique[self.i] do
		self.i = self.i + 1
		if self.i == self.max then self.i = 0 end
	end

	self.unique[self.i] = true
	return self.i
end

function foulfell_medusa_mystic_snake:DelUniqueInt(i)
	self.unique[i] = nil
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

modifier_foulfell_medusa_mystic_snake = {}

function modifier_foulfell_medusa_mystic_snake:IsHidden()
	return false
end

function modifier_foulfell_medusa_mystic_snake:IsDebuff()
	return true
end

function modifier_foulfell_medusa_mystic_snake:IsStunDebuff()
	return true
end

function modifier_foulfell_medusa_mystic_snake:IsPurgable()
	return true
end

function modifier_foulfell_medusa_mystic_snake:OnCreated(kv)
	if not IsServer() then return end

	self.physical_bonus = kv.physical_bonus
	self.center_unit = EntIndexToHScript(kv.center_unit)

	local effect_cast = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff_stoned.vpcf", PATTACH_ABSORIGIN_FOLLOW,
		self:GetParent())
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self.center_unit,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0, 0, 0),
		true
	)

	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
	EmitSoundOnClient("Hero_Medusa.StoneGaze.Stun", self:GetParent():GetPlayerOwner())
end

modifier_foulfell_medusa_mystic_snake.OnRefresh = modifier_foulfell_medusa_mystic_snake.OnCreated

function modifier_foulfell_medusa_mystic_snake:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS 
	}
end

function modifier_foulfell_medusa_mystic_snake:GetModifierMagicalResistanceBonus()
	return 100
end

function modifier_foulfell_medusa_mystic_snake:GetModifierIncomingDamage_Percentage(params)
	if params.damage_type == DAMAGE_TYPE_PHYSICAL then
		return self.physical_bonus
	end
end

function modifier_foulfell_medusa_mystic_snake:CheckState()
	return {
		[MODIFIER_STATE_STUNNED ] = true,
		[MODIFIER_STATE_FROZEN  ] = true,

	}
end

function modifier_foulfell_medusa_mystic_snake:GetStatusEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function modifier_foulfell_medusa_mystic_snake:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end
