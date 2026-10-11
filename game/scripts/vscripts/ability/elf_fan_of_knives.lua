LinkLuaModifier( "modifier_elf_fan_of_knives", "ability/elf_fan_of_knives.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if elf_fan_of_knives == nil then
	elf_fan_of_knives = class({})
end

function elf_fan_of_knives:GetIntrinsicModifierName()
	return "modifier_elf_fan_of_knives"
end

function elf_fan_of_knives:OnSpellStart()
	if not IsServer() then return end

	local damage=60
	local radius=350

	-- unit identifier
	local caster = self:GetCaster()
	local speed = 1000
	local start_radius = 0
	local end_radius = radius
	-- create ring
	local ring = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_generic_ring_lua", -- modifier name
		{
			start_radius = start_radius,
			end_radius = end_radius,
			speed = speed,
			target_team = DOTA_UNIT_TARGET_TEAM_ENEMY,
			target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			IsCircle = 0,
		} -- kv
	)
	local count=0
	ring:SetCallback( function( enemy )
		count=count+1
		if count<=5 then
			local damageTable = {
				victim = enemy,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self
			}
			ApplyDamage(damageTable)
		end
	end)
	-- play effects
	self:PlayEffects( ring, speed )
end
	
function elf_fan_of_knives:PlayEffects( modifier, speed )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_shard_fan_of_knives.vpcf"
	local sound_cast = "Hero_PhantomAssassin.FanOfKnives.Cast"
	-- get data
	local duration = 1
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	--ParticleManager:SetParticleControl( effect_cast, 1, Vector( speed, duration, speed ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end


modifier_elf_fan_of_knives = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

-- function modifier_elf_fan_of_knives:GetEffectName()
-- 	return "particles/econ/items/templar_assassin/templar_assassin_focal/ta_focal_ambient.vpcf"
-- end
-- function modifier_elf_fan_of_knives:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end