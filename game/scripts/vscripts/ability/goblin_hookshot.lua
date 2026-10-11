goblin_hookshot = class({})


function goblin_hookshot:FireLinearProjectile(FX, velocity, distance, width, data, bDelete, bVision, vision)
	local internalData = data or {}
	local delete = false
	if bDelete then delete = bDelete end
	local provideVision = true
	if bVision then provideVision = bVision end
	local info = {
		EffectName = FX,
		Ability = self,
		vSpawnOrigin = internalData.origin or self:GetCaster():GetAbsOrigin(),
		fStartRadius = width,
		fEndRadius = internalData.width_end or width,
		vVelocity = velocity,
		fDistance = distance or 1000,
		Source = internalData.source or self:GetCaster(),
		iUnitTargetTeam = internalData.team or DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = internalData.type or DOTA_UNIT_TARGET_CREEP,
		iUnitTargetFlags = internalData.type or DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iSourceAttachment = internalData.attach or DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		bDeleteOnHit = delete,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bProvidesVision = provideVision,
		iVisionRadius = vision or 100,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		ExtraData = internalData.extraData
	}
	local projectile = ProjectileManager:CreateLinearProjectile(info)
	return projectile
end

function goblin_hookshot:OnSpellStart()
	local caster = self:GetCaster()
	local direction = (self:GetCursorPosition() - caster:GetOrigin()):Normalized()
	direction.z = 0

	local speed = self:GetSpecialValueFor("speed")
	local distance = self:GetCastRange(self:GetCursorPosition(), nil)
	local width = self:GetSpecialValueFor("latch_radius")
	local duration = (distance / speed) * 2
	local endPos = caster:GetAbsOrigin() + direction * distance

	self.hookFX = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf",
		PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(self.hookFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1",
		caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.hookFX, 1, endPos)
	ParticleManager:SetParticleControl(self.hookFX, 2, Vector(speed, 1, 1))
	ParticleManager:SetParticleControl(self.hookFX, 3, Vector(duration, 1, 1))
	EmitSoundOn("Hero_Rattletrap.Hookshot.Fire", caster)

	if caster:GetName() == "npc_dota_hero_rattletrap" and caster:GetTogglableWearable(DOTA_LOADOUT_TYPE_WEAPON) then
		caster:GetTogglableWearable(DOTA_LOADOUT_TYPE_WEAPON):AddEffects(EF_NODRAW)
	end
	self:FireLinearProjectile("", direction * speed, distance, width,
		{ team = DOTA_UNIT_TARGET_TEAM_ENEMY, origin = caster:GetAbsOrigin() + direction * 32 }, true, true, width * 2)
end

function goblin_hookshot:OnProjectileHit(target, position)

	print("OnProjectileHit")
	local caster = self:GetCaster()
	if target then
		local distance = #(caster:GetOrigin() - target:GetOrigin())
		local speed = self:GetSpecialValueFor("speed")

		ParticleManager:SetParticleControlEnt(self.hookFX, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc",
			target:GetAbsOrigin(), true)
		local duration=self:GetSpecialValueFor("duration")
		duration = duration * (1 - CalUnitStatusResistance(target))
		target:AddNewModifier(caster, self, 'modifier_stunned', {
			duration = duration
		})
		print("dur",distance / speed)
		target:AddNewModifier(caster, self, "modifier_goblin_hookshot_hook", { duration = distance / speed })
	else
		ParticleManager:SetParticleControl(self.hookFX, 1, caster:GetAbsOrigin())
	end
	StopSoundOn("Hero_Rattletrap.Hookshot.Fire", caster)
	EmitSoundOn("Hero_Rattletrap.Hookshot.Retract", caster)
	return true
end

LinkLuaModifier("modifier_goblin_hookshot_hook", "ability/goblin_hookshot", LUA_MODIFIER_MOTION_NONE)
modifier_goblin_hookshot_hook = class({
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_MULTIPLE
	end
})

if IsServer() then
	function modifier_goblin_hookshot_hook:OnCreated()
		print("OnCreated")
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self.speed = self:GetAbility():GetSpecialValueFor("speed") * FrameTime()
		self.direction = CalculateDirection(parent, caster)
		self.distance = CalculateDistance(self:GetParent(), caster) -
		(caster:GetHullRadius() + parent:GetHullRadius() + caster:GetCollisionPadding() + parent:GetCollisionPadding() + 64)
		self.radius = self:GetAbility():GetSpecialValueFor("stun_radius")
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self.duration = self:GetAbility():GetSpecialValueFor("duration")
		-- 
		self.enemiesHit = {}
		self.endSoundFlag=false

		self.thinkTick=0
		caster:StartGesture(ACT_DOTA_RATTLETRAP_HOOKSHOT_LOOP)
		self:StartMotionController()
	end

	function modifier_goblin_hookshot_hook:OnDestroy()
		print("OnDestroy")
		local caster = self:GetCaster()
		ResolveNPCPositions(caster:GetAbsOrigin(), caster:GetHullRadius() + caster:GetCollisionPadding())
		if self.thinkTick==0 then
			self:DoControlledMotion()
		end
		self:StopMotionController()
		caster:RemoveGesture(ACT_DOTA_RATTLETRAP_HOOKSHOT_LOOP)
		caster:StartGesture(ACT_DOTA_RATTLETRAP_HOOKSHOT_END)
		ParticleManager:DestroyParticle(self:GetAbility().hookFX, true)
		ParticleManager:ReleaseParticleIndex(self:GetAbility().hookFX)

		EmitSoundOn("Hero_Rattletrap.Hookshot.Impact", self:GetParent())
		StopSoundOn("Hero_Rattletrap.Hookshot.Retract", caster)
		-- if caster:GetName() == "npc_dota_hero_rattletrap" and caster:GetTogglableWearable(DOTA_LOADOUT_TYPE_WEAPON) then
		-- 	caster:GetTogglableWearable(DOTA_LOADOUT_TYPE_WEAPON):RemoveEffects(EF_NODRAW)
		-- end
	end

	function modifier_goblin_hookshot_hook:DoControlledMotion()
		self.thinkTick=self.thinkTick+1
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local enemies = FindUnitsInRadius(caster:GetTeam(),
			caster:GetAbsOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)

		for _, enemy in ipairs(enemies) do
			if not self.enemiesHit[enemy:entindex()] then
				ApplyDamage({
					victim = enemy,
					attacker = caster,
					damage = self.damage,
					ability = ability,
					damage_type = ability:GetAbilityDamageType(),
				})

				local duration=self.duration
				duration = duration * (1 - CalUnitStatusResistance(enemy))
				enemy:AddNewModifier(caster, self, 'modifier_stunned', {
					duration = duration
				})
				self.enemiesHit[enemy:entindex()] = true
				if not self.endSoundFlag then
					EmitSoundOn("Hero_Rattletrap.Hookshot.Damage", enemy)	
					self.endSoundFlag=true
				end
				
			end
		end
		if caster:IsAlive() and self.distance > 0 then
			local newPos = GetGroundPosition(caster:GetAbsOrigin(), caster) + self.direction * self.speed
			self.distance = self.distance - self.speed
			caster:SetAbsOrigin(newPos)
		else
			self:Destroy()
			return
		end
	end
end

function modifier_goblin_hookshot_hook:IsHidden()
	return true
end
