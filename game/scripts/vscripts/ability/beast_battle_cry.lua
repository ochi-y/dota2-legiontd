LinkLuaModifier( "modifier_beast_battle_cry", "ability/beast_battle_cry.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if beast_battle_cry == nil then
	beast_battle_cry = class({})
end
function beast_battle_cry:OnSpellStart()
	if not IsServer() then return end
	--
	local caster=self:GetCaster()
	-- Create Sound
	EmitSoundOn( "Hero_LoneDruid.BattleCry.Bear", caster )
	caster:AddNewModifier(caster, self, "modifier_beast_battle_cry", {duration=25})
	self:playEffect(caster)

	local radius=self:GetSpecialValueFor("radius")

	local units=SimpleFindFriend(caster:GetTeamNumber(),caster:GetAbsOrigin(),radius)
	for i = 1, #units do
		if units[i]:GetUnitName()=="beast_ogre_grizzly" or units[i]:GetUnitName()=="arctic_polar_bear" then
			self:PlayEffects( units[i] )
			units[i]:AddNewModifier(caster, self, "modifier_beast_battle_cry", {duration=25})
		end
	end
end

function beast_battle_cry:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_cast.vpcf"
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	
end

function beast_battle_cry:playEffect(caster)
	local particle="particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf"
	local fx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(fx)
	
end

modifier_beast_battle_cry = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_beast_battle_cry:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_damage=ability:GetSpecialValueFor("bonus_damage")
	self.bonus_armor=ability:GetSpecialValueFor("bonus_armor")
	--
	local ability=self:GetAbility()
	self.attackBonus=ability:GetSpecialValueFor("attackBonus")
end

function modifier_beast_battle_cry:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_beast_battle_cry:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_beast_battle_cry:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_damage
end

function modifier_beast_battle_cry:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end

function modifier_beast_battle_cry:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_beast_battle_cry:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end
	