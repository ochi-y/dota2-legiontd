undead_rage = class({})
LinkLuaModifier( "modifier_undead_rage", "ability/undead_rage", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function undead_rage:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- dispel
	caster:Purge( false, true, false, false, false )

	-- apply modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_undead_rage", -- modifier name
		{ duration = duration } -- kv
	)

	-- play effects
	local sound_cast = "Hero_LifeStealer.Rage"
	EmitSoundOn( sound_cast, caster )

	caster:StartGesture(ACT_DOTA_LIFESTEALER_RAGE)
end

modifier_undead_rage = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_undead_rage:IsHidden()
	return false
end

function modifier_undead_rage:IsDebuff()
	return false
end

function modifier_undead_rage:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_undead_rage:OnCreated( kv )
	-- references
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" ) -- special value
	self.movement_speed_bonus = self:GetAbility():GetSpecialValueFor( "movement_speed_bonus" ) 
	if IsServer() then
		self:PlayEffects()
	end
end

function modifier_undead_rage:OnRefresh( kv )
	-- references
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" ) -- special value
	self.movement_speed_bonus = self:GetAbility():GetSpecialValueFor( "movement_speed_bonus" ) 

end

function modifier_undead_rage:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_undead_rage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE ,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end


function modifier_undead_rage:GetModifierMoveSpeedBonus_Percentage()
	return self.movement_speed_bonus
end

function modifier_undead_rage:GetModifierAttackSpeedPercentage()
	return self.as_bonus
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_undead_rage:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
	return state
end
function modifier_undead_rage:GetStatusEffectName()
	return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end
function modifier_undead_rage:StatusEffectPriority()
	return 3
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_undead_rage:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_attack2",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetParent(),
		PATTACH_CENTER_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	--	assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_color"))(self,effect_cast)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end





