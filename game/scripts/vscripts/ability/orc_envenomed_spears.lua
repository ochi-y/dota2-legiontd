-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
orc_envenomed_spears = class({})
LinkLuaModifier( "modifier_orc_envenomed_spears", "ability/orc_envenomed_spears", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_orc_envenomed_spears_stack", "ability/orc_envenomed_spears", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_orb_effect_lua", "lua_abilities/generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function orc_envenomed_spears:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

--------------------------------------------------------------------------------
-- Orb Effects
function orc_envenomed_spears:GetProjectileName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear.vpcf"
end

function orc_envenomed_spears:OnOrbFire( params )


	-- health cost
	local damageTable = {
		victim = self:GetCaster(),
		attacker = self:GetCaster(),
		damage = self:GetSpecialValueFor("health_cost"),
		damage_type = DAMAGE_TYPE_PURE,
		ability = self, --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS, --Optional.
	}
	ApplyDamage(damageTable)
end

function orc_envenomed_spears:OnOrbImpact( params )


	local duration=self:GetSpecialValueFor("duration")

	params.target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_orc_envenomed_spears", -- modifier name
		{ duration = duration } -- kv
	)

	-- play effects
	local sound_cast = "Hero_Huskar.Burning_Spear.Cast"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

--------------------------------------------------------------------------------
-- Ability Start
function orc_envenomed_spears:OnSpellStart()
end


----------------------------------------------------------------------------------------------

-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_orc_envenomed_spears = class({})
local tempTable = require("utils/tempTable")

--------------------------------------------------------------------------------
-- Classifications
function modifier_orc_envenomed_spears:IsHidden()
	return false
end

function modifier_orc_envenomed_spears:IsDebuff()
	return true
end

function modifier_orc_envenomed_spears:IsStunDebuff()
	return false
end

function modifier_orc_envenomed_spears:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_orc_envenomed_spears:OnCreated( kv )
	if not self:GetAbility() then return end
	-- references
	self.dps = self:GetAbility():GetSpecialValueFor( "burn_damage" )

	if IsServer() then
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		
		-- add stack modifier
		local this = tempTable:AddATValue( self )
		self:GetParent():AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_orc_envenomed_spears_stack", -- modifier name
			{
				duration = duration,
				modifier = this,
			} -- kv
		)

		-- increment stack
		self:SetStackCount(self:GetStackCount() + 1)

		-- precache damage
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			-- damage = 500,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
		}

		-- start interval
		self:StartIntervalThink( 1 )
	end
end

function modifier_orc_envenomed_spears:OnRefresh( kv )
	if not self:GetAbility() then return end
	-- references
	self.dps = self:GetAbility():GetSpecialValueFor( "burn_damage" )

	if IsServer() then
		local duration = self:GetAbility():GetSpecialValueFor("duration")

		-- add stack
		local this = tempTable:AddATValue( self )
		self:GetParent():AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_orc_envenomed_spears_stack", -- modifier name
			{
				duration = duration,
				modifier = this,
			} -- kv
		)
		
		-- increment stack
		self:SetStackCount(self:GetStackCount() + 1)
		
	end
end

function modifier_orc_envenomed_spears:OnRemoved()
	-- stop effects
	local sound_cast = "Hero_Huskar.Burning_Spear"
	StopSoundOn( sound_cast, self:GetParent() )
end

function modifier_orc_envenomed_spears:OnDestroy()
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_orc_envenomed_spears:OnIntervalThink()
	-- apply dot damage
	self.damageTable.damage = self:GetStackCount() * self.dps
	local damage=self:GetStackCount() * self.dps
	-- 
	self.damageTable.damage=damage
	-- 
	ApplyDamage( self.damageTable )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_orc_envenomed_spears:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_orc_envenomed_spears:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-- function modifier_orc_envenomed_spears:GetStatusEffectName()
-- 	return "status/effect/here.vpcf"
-- end

-- function modifier_orc_envenomed_spears:PlayEffects()
-- 	-- Get Resources
-- 	local particle_cast = "particles/units/heroes/hero_heroname/heroname_ability.vpcf"
-- 	local sound_cast = "string"

-- 	-- Get Data

-- 	-- Create Particle
-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_NAME, hOwner )
-- 	ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		iControlPoint,
-- 		hTarget,
-- 		PATTACH_NAME,
-- 		"attach_name",
-- 		vOrigin, -- unknown
-- 		bool -- unknown, true
-- 	)
-- 	ParticleManager:SetParticleControlForward( effect_cast, iControlPoint, vForward )
-- 	SetParticleControlOrientation( effect_cast, iControlPoint, vForward, vRight, vUp )
-- 	ParticleManager:ReleaseParticleIndex( effect_cast )

-- 	-- buff particle
-- 	self:AddParticle(
-- 		effect_cast,
-- 		false, -- bDestroyImmediately
-- 		false, -- bStatusEffect
-- 		-1, -- iPriority
-- 		false, -- bHeroEffect
-- 		false -- bOverheadEffect
-- 	)

-- 	-- Create Sound
-- 	EmitSoundOnLocationWithCaster( vTargetPosition, sound_location, self:GetCaster() )
-- 	EmitSoundOn( sound_target, target )
-- end

---------------------------------------------------------------------------------------------------

-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_orc_envenomed_spears_stack = class({})
local tempTable = require("utils/tempTable")

--------------------------------------------------------------------------------
-- Classifications
function modifier_orc_envenomed_spears_stack:IsHidden()
	return true
end

function modifier_orc_envenomed_spears_stack:IsPurgable()
	return false
end

function modifier_orc_envenomed_spears_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_orc_envenomed_spears_stack:OnCreated( kv )
	if IsServer() then
		-- get references
		self.modifier = tempTable:RetATValue( kv.modifier )
	end

	-- play effects
	local sound_cast = "Hero_Huskar.Burning_Spear"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_orc_envenomed_spears_stack:OnRemoved()
	if IsServer() then
		-- decrement stack
		if not self.modifier:IsNull() then
			--self.modifier:DecrementStackCount()
			self.modifier:SetStackCount(self.modifier:GetStackCount() - 1)
		end
	end
end

function modifier_orc_envenomed_spears_stack:OnDestroy()
end