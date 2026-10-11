
--------------------------------------------------------------------------------
shadow_chronosphere = class({})
LinkLuaModifier( "modifier_shadow_chronosphere_thinker", "ability/shadow_chronosphere", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_chronosphere_effect", "ability/shadow_chronosphere", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function shadow_chronosphere:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end
-- function shadow_chronosphere:GetCooldown( level )

-- 	return self.BaseClass.GetCooldown( self, level )
-- end

--------------------------------------------------------------------------------
-- Ability Start
function shadow_chronosphere:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local duration = self:GetSpecialValueFor("duration")
	local vision = self:GetSpecialValueFor("vision_radius")

	-- create thinker
	self.thinker = CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_shadow_chronosphere_thinker", -- modifier name
		{ duration = duration }, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)
	self.thinker = self.thinker:FindModifierByName("modifier_shadow_chronosphere_thinker")

	-- create fov
	AddFOWViewer( self:GetCaster():GetTeamNumber(), point, vision, duration, false)
end

--------------------------------------------------------------------------------
modifier_shadow_chronosphere_thinker = class({})

--------------------------------------------------------------------------------
-- Initializations
function modifier_shadow_chronosphere_thinker:OnCreated( kv )
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	if IsServer() then
		self:PlayEffects()
	end
end

function modifier_shadow_chronosphere_thinker:OnRefresh( kv )
	
end

function modifier_shadow_chronosphere_thinker:OnRemoved()
end

function modifier_shadow_chronosphere_thinker:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Status Effects

-- function modifier_shadow_chronosphere_thinker:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_FROZEN] = true,
-- 	}

-- 	return state
-- end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_shadow_chronosphere_thinker:IsAura()
	return true
end

function modifier_shadow_chronosphere_thinker:GetModifierAura()
	return "modifier_shadow_chronosphere_effect"
end

function modifier_shadow_chronosphere_thinker:GetAuraRadius()
	return self.radius
end

function modifier_shadow_chronosphere_thinker:GetAuraDuration()
	return 0.01
end

function modifier_shadow_chronosphere_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_shadow_chronosphere_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_shadow_chronosphere_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_shadow_chronosphere_thinker:GetAuraEntityReject( hEntity )
	if IsServer() then
		-- -- reject if owner
		-- if hEntity==self:GetCaster() then return true end

		-- -- reject if owner controlled
		-- if hEntity:GetPlayerOwnerID()==self:GetCaster():GetPlayerOwnerID() then return true end

		-- reject if unit is named faceless void
		if hEntity:GetUnitName()=="npc_dota_faceless_void" then return true end
	end

	return false
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_shadow_chronosphere_thinker:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf"
	local sound_cast = "Hero_FacelessVoid.Chronosphere"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	-- local effect_cast = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end


--------------------------------------------------------------------------------
modifier_shadow_chronosphere_effect = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_shadow_chronosphere_effect:IsHidden()
	return false
end

function modifier_shadow_chronosphere_effect:IsDebuff()
	return not self:NotAffected()
end

function modifier_shadow_chronosphere_effect:IsStunDebuff()
	return not self:NotAffected()
end

function modifier_shadow_chronosphere_effect:IsPurgable()
	return false
end

function modifier_shadow_chronosphere_effect:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_shadow_chronosphere_effect:NotAffected()
	-- true owner
	if self:GetParent()==self:GetCaster() then return true end

	local parent=self:GetParent()

	if parent:GetUnitName()=="shadow_nightmare" or parent:GetUnitName()=="shadow_doppelganger"  then
		return true
	end

	-- true if owner controlled
	-- if self:GetParent():GetPlayerOwnerID()==self:GetCaster():GetPlayerOwnerID() then return true end
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_shadow_chronosphere_effect:OnCreated( kv )
	self.speed = 1000

	if IsServer() then
		if not self:NotAffected() then
			self:GetParent():InterruptMotionControllers( false )
		else
			self:PlayEffects()
		end
	end
end

function modifier_shadow_chronosphere_effect:OnRefresh( kv )
	
end

function modifier_shadow_chronosphere_effect:OnRemoved()
end

function modifier_shadow_chronosphere_effect:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_shadow_chronosphere_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
	}

	return funcs
end

function modifier_shadow_chronosphere_effect:GetModifierMoveSpeed_AbsoluteMin()
	if self:NotAffected() then return self.speed end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_shadow_chronosphere_effect:CheckState()
	local state1 = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	local state2 = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}
	if self:NotAffected() then return state1 else return state2 end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
-- function modifier_shadow_chronosphere_effect:GetEffectName()
-- 	return "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf"
-- end

-- function modifier_shadow_chronosphere_effect:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

-- function modifier_shadow_chronosphere_effect:GetStatusEffectName()
-- 	return "status/effect/here.vpcf"
-- end

function modifier_shadow_chronosphere_effect:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	-- ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end