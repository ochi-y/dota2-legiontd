foulfell_golem_tower_boulder_toss = class({})
LinkLuaModifier("modifier_foulfell_golem_tower_boulder_toss_thinker",
	"ability/foulfell_golem_tower_boulder_toss", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_foulfell_golem_tower_boulder_toss",
	"ability/foulfell_golem_tower_boulder_toss", LUA_MODIFIER_MOTION_NONE)

----------------------------------------------------------------------------------------

function foulfell_golem_tower_boulder_toss:Precache(context)
	PrecacheResource("particle", "particles/neutral_fx/mud_golem_hurl_boulder.vpcf", context)
	PrecacheResource("particle", "particles/neutral_fx/black_dragon_fireball.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite_debuff.vpcf", context)
	PrecacheResource("particle", "particles/status_fx/status_effect_burn.vpcf", context)
	PrecacheResource("particle", "particles/creatures/golem_tower/boulder_toss_ground_preview.vpcf", context)
end

function foulfell_golem_tower_boulder_toss:GetIntrinsicModifierName()
	return "modifier_foulfell_golem_tower_boulder_toss"
end

----------------------------------------------------------------------------------------
function foulfell_golem_tower_boulder_toss:GetAOERadius()
	return self:GetSpecialValueFor("large_radius")
end

function foulfell_golem_tower_boulder_toss:OnSpellStart()
	if IsServer() then
		self.vTargetLoc = self:GetCursorPosition()
		local flGroundHeight = GetGroundHeight(self.vTargetLoc, nil)
		self.vTargetLoc.z = flGroundHeight + 50
		local nRadius = 275
		local nDestinationRadius = nRadius / 2

		EmitSoundOn("GolemTower.Dire.Attack", self:GetCaster())

		self.hThinker = CreateModifierThinker(self:GetCaster(), self,
			"modifier_foulfell_golem_tower_boulder_toss_thinker", { duration = 5 }, self:GetCursorPosition(),
			self:GetCaster():GetTeamNumber(), false)
		if self.hThinker ~= nil then
			local vSourceLoc = self:GetCaster():GetAbsOrigin() + Vector(0, 0, 300)
			local dis = (self:GetCaster():GetAbsOrigin() - self:GetCursorPosition()):Length2D()
			if dis <= 180 and dis >= 100 then
			else
				vSourceLoc = vSourceLoc + self:GetCaster():GetForwardVector() * 150
			end
			local projectile =
			{
				Target = self.hThinker,
				--Source = self:GetCaster(),
				Ability = self,
				EffectName = "particles/neutral_fx/mud_golem_hurl_boulder.vpcf",
				iMoveSpeed = 600,
				vSourceLoc = vSourceLoc,
				bDodgeable = false,
				bProvidesVision = false,
				-- bVisibleToEnemies=false,
				--iSourceAttachment     = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1 ,
			}

			ProjectileManager:CreateTrackingProjectile(projectile)

			-- EmitSoundOn("OgreMagi.Ignite.Cast", self:GetCaster())
		end
	end
end

----------------------------------------------------------------------------------------

function foulfell_golem_tower_boulder_toss:OnProjectileHit(hTarget, vLocation)
	if IsServer() then
		if hTarget then
			-- local damage_to_air = self:GetSpecialValueFor("damage_to_air")


			-- local damage = self:GetCaster():GetAttackDamage()
			-- for _, unit in ipairs(units) do
			-- 	local finalDamage = damage
			-- 	if unit:HasFlyMovementCapability() then
			-- 		finalDamage = damage * damage_to_air / 100
			-- 	end
			-- 	finalDamage = finalDamage * SimpleGetAttackFactor(self:GetCaster(), unit)
			-- 	SimpleApplyDamage(self, self:GetCaster(), unit, finalDamage)
			-- end
			local ability = self
			local damage = self:GetCaster():GetAttackDamage()
			local caster = self:GetCaster()

			local units = FindAbilityTarget(self, hTarget:GetAbsOrigin(), self:GetSpecialValueFor("small_radius"), {})
			local victim = units[1]
			--
			if victim then
				SimpleApplyDamage(ability, caster, victim, damage)
			end
			--
			local splashData = { {
				radius = ability:GetSpecialValueFor("small_radius"),
				damage = ability:GetSpecialValueFor("small_damage_pct") * damage / 100
			}, {
				radius = ability:GetSpecialValueFor("large_radius"),
				damage = ability:GetSpecialValueFor("large_radius_pct") * damage / 100
			} }
			splashAttack(caster, nil, splashData, ability, {
				pos = hTarget:GetAbsOrigin()
			})

			EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Tower.Fire.ProjectileImpact", self:GetCaster())
			UTIL_RemoveImmediate(hTarget)
		end

		-- if self.hThinker ~= nil then
		-- 	-- local hBuff = self.hThinker:FindModifierByName("modifier_foulfell_golem_tower_boulder_toss_thinker")
		-- 	-- if hBuff ~= nil then
		-- 	-- 	hBuff:OnIntervalThink()
		-- 	-- end


		-- 	self.hThinker = nil;
		-- end
	end
	return true
end

----------------------------------------------------------------------------------------
modifier_foulfell_golem_tower_boulder_toss = class({
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
function modifier_foulfell_golem_tower_boulder_toss:AllowIllusionDuplicate()
	return false
end

function modifier_foulfell_golem_tower_boulder_toss:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
end

function modifier_foulfell_golem_tower_boulder_toss:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_golem_tower_boulder_toss:DeclareFunctions()
	return {

	}
end

function modifier_foulfell_golem_tower_boulder_toss:CheckState()
	local state = {
		-- [MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

modifier_foulfell_golem_tower_boulder_toss_thinker = class({})

----------------------------------------------------------------------------------------

function modifier_foulfell_golem_tower_boulder_toss_thinker:OnCreated(kv)
	if IsServer() then
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.area_duration = self:GetAbility():GetSpecialValueFor("area_duration")
		self.linger_duration = self:GetAbility():GetSpecialValueFor("linger_duration")
		self.bImpact = false
	end
end

----------------------------------------------------------------------------------------

function modifier_foulfell_golem_tower_boulder_toss_thinker:OnImpact()
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle("particles/neutral_fx/black_dragon_fireball.vpcf",
			PATTACH_WORLDORIGIN, nil);
		ParticleManager:SetParticleControl(nFXIndex, 0, self:GetParent():GetOrigin());
		ParticleManager:SetParticleControl(nFXIndex, 1, self:GetParent():GetOrigin());
		ParticleManager:SetParticleControl(nFXIndex, 2, Vector(self.area_duration, 0, 0));
		ParticleManager:ReleaseParticleIndex(nFXIndex);

		EmitSoundOn("OgreMagi.Ignite.Target", self:GetParent())

		self:SetDuration(self.area_duration, true)
		self.bImpact = true

		self:StartIntervalThink(0.5)
	end
end

----------------------------------------------------------------------------------------

function modifier_foulfell_golem_tower_boulder_toss_thinker:OnIntervalThink()
	if IsServer() then
		if self.bImpact == false then
			self:OnImpact()
			return
		end

		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(),
			self:GetParent(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
		for _, enemy in pairs(enemies) do
			if enemy ~= nil then
				enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ogre_magi_ignite",
					{ duration = self.linger_duration })
			end
		end
	end
end

----------------------------------------------------------------------------------------
