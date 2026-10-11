--------------------------------------------------------------------------------
-- Tongue pull ability - Catchy Lick
-- Largo licks the target, pulls it closer, applies a basic dispel and damages enemies
--------------------------------------------------------------------------------

-- Config
local HIT_DELAY = 0.2        -- tongue hit delay in seconds
local PULL_OFFSET = 150      -- minimum distance between the target and the caster
local PULL_SPEED = 2000      -- pull speed

--------------------------------------------------------------------------------
marine_largo_catchy_lick = class({})
LinkLuaModifier("modifier_marine_largo_catchy_lick_pull", "ability/marine_largo_catchy_lick", LUA_MODIFIER_MOTION_HORIZONTAL)

--------------------------------------------------------------------------------
-- Cast start
function marine_largo_catchy_lick:OnSpellStart()
	-- Caster and target
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- Validate the target
	if not target or target:IsInvulnerable() or target:IsOutOfGame() then
		return
	end

	-- Check magic immunity and spell absorption
	if target:TriggerSpellAbsorb(self) then
		return
	end

	-- Play the sound and effect right away
	EmitSoundOn("Hero_Largo.CatchyLick.Cast", caster)
	EmitSoundOn("Hero_Largo.CatchyLick.Target", target)
	self:PlayEffects(caster, target)

	-- Delayed hit
	Timers:CreateTimer(HIT_DELAY, function()
		-- Is the target still valid?
		if not target or target:IsNull() or not target:IsAlive() then
			return
		end

		-- Apply a basic dispel
		-- Purge arguments: remove buffs, remove debuffs, deal damage, remove stuns, remove undispellable effects
		target:Purge(false, true, false, false, false)

		-- Damage the target when it is an enemy
		local isEnemy = target:GetTeamNumber() ~= caster:GetTeamNumber()
		if isEnemy then
			local damage = self:GetSpecialValueFor("damage")
			local damageTable = {
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self,
			}
			ApplyDamage(damageTable)
		end

		-- Add the pull modifier
		target:AddNewModifier(
			caster,                            -- caster
			self,                              -- ability
			"modifier_marine_largo_catchy_lick_pull", -- modifier name
			{}                                 -- parameters
		)
	end)
end

--------------------------------------------------------------------------------
-- Play the effect
function marine_largo_catchy_lick:PlayEffects(caster, target)
	-- Largo tongue pull particle effect
	local particle_cast = "particles/units/heroes/hero_largo/largo_catchy_lick.vpcf"

	-- Create the particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		caster,
		PATTACH_POINT_FOLLOW,
		"attach_mouth",
		Vector(0, 0, 0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0, 0, 0),
		true
	)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

--------------------------------------------------------------------------------
-- Pull modifier
--------------------------------------------------------------------------------
modifier_marine_largo_catchy_lick_pull = class({})

function modifier_marine_largo_catchy_lick_pull:IsHidden()
	return false
end

function modifier_marine_largo_catchy_lick_pull:IsDebuff()
	return self.isEnemy
end

function modifier_marine_largo_catchy_lick_pull:IsStunDebuff()
	return true
end

function modifier_marine_largo_catchy_lick_pull:IsPurgable()
	return false
end

function modifier_marine_largo_catchy_lick_pull:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------
-- Initialise
function modifier_marine_largo_catchy_lick_pull:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()

	if not IsServer() then return end

	-- Config values
	self.offset = PULL_OFFSET -- offset from the caster
	self.speed = PULL_SPEED   -- pull speed

	-- Is the target an enemy?
	self.isEnemy = self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber()
	self.stunned = self.isEnemy and (not self.parent:IsMagicImmune())

	-- Current distance
	local currentPos = self.parent:GetOrigin()
	local casterPos = self.caster:GetOrigin()
	local distanceVec = casterPos - currentPos
	distanceVec.z = 0
	local currentDistance = distanceVec:Length2D()

	-- Already within the minimum distance, so no pull is needed
	if currentDistance <= self.offset then
		self:Destroy()
		return
	end

	-- Pull direction and distance
	self.direction = distanceVec:Normalized()
	self.distance = currentDistance - self.offset

	-- Duration
	self.duration = self.distance / self.speed
	self:SetDuration(self.duration, true)

	-- Face the caster
	self.parent:SetForwardVector(self.direction)

	-- Apply the horizontal motion controller
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end
end

function modifier_marine_largo_catchy_lick_pull:OnDestroy()
	if not IsServer() then return end

	-- Remove the horizontal motion controller
	self.parent:RemoveHorizontalMotionController(self)

	-- Make sure the position is legal, adjusted only when a pull happened
	if self.direction and self.offset then
		local targetPos = self.caster:GetOrigin() - self.direction * self.offset
		FindClearSpaceForUnit(self.parent, targetPos, true)
	end

	-- After the pull, make the caster attack the target right away
	if self.caster and not self.caster:IsNull() and self.caster:IsAlive() then
		if self.parent and not self.parent:IsNull() and self.parent:IsAlive() then
			-- Attack immediately when the target is an enemy
			if self.isEnemy then
				self.caster:MoveToTargetToAttack(self.parent)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Modifier effects
function modifier_marine_largo_catchy_lick_pull:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_marine_largo_catchy_lick_pull:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------
-- State
function modifier_marine_largo_catchy_lick_pull:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = self.stunned,
	}
end

--------------------------------------------------------------------------------
-- Motion
function modifier_marine_largo_catchy_lick_pull:UpdateHorizontalMotion(me, dt)
	-- Next position
	local nextPos = me:GetOrigin() + self.direction * self.speed * dt
	nextPos = GetGroundPosition(nextPos, me)
	me:SetOrigin(nextPos)

	-- Has it reached the destination?
	local currentDistance = (me:GetOrigin() - self.caster:GetOrigin()):Length2D()
	if currentDistance <= self.offset then
		self:Destroy()
	end
end

function modifier_marine_largo_catchy_lick_pull:OnHorizontalMotionInterrupted()
	if not IsServer() then return end
	self:Destroy()
end
