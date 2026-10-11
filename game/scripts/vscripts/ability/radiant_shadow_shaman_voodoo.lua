LinkLuaModifier("modifier_radiant_shadow_shaman_voodoo", "ability/radiant_shadow_shaman_voodoo", LUA_MODIFIER_MOTION_NONE)

if radiant_shadow_shaman_voodoo == nil then
	radiant_shadow_shaman_voodoo = class({})
end

--------------------------------------------------------------------------------

function radiant_shadow_shaman_voodoo:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()




	if target:TriggerSpellAbsorb(self) then return end

	local duration = self:GetSpecialValueFor("duration")

	duration = duration * (1 - CalUnitStatusResistance(target))

	EmitSoundOn("Hero_Lion.Voodoo", target)

	if not target:IsIllusion() then
		target:AddNewModifier(caster, self, "modifier_radiant_shadow_shaman_voodoo", { duration = duration })
		local partname = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"
		local part = ParticleManager:CreateParticle(partname, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(part)
		EmitSoundOn("Hero_ShadowShaman.Hex.Target", target)
	else
		target:Kill(self, caster)
	end
end

--------------------------------------------------------------------------------


modifier_radiant_shadow_shaman_voodoo = class({
	IsHidden         = function(self) return false end,
	IsPurgable       = function(self) return false end,
	IsPurgeException = function(self) return true end,
	IsDebuff         = function(self) return true end,
	IsBuff           = function(self) return false end,
	RemoveOnDeath    = function(self) return true end,
	DeclareFunctions = function(self)
		return {
			MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
			MODIFIER_PROPERTY_MODEL_CHANGE
		}
	end,
	CheckState       = function(self)
		return {
			[MODIFIER_STATE_HEXED] = true,
			[MODIFIER_STATE_MUTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_BLOCK_DISABLED] = true,
			[MODIFIER_STATE_EVADE_DISABLED] = true,
			[MODIFIER_STATE_PASSIVES_DISABLED] = true
		}
	end,
})


--------------------------------------------------------------------------------

function modifier_radiant_shadow_shaman_voodoo:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")

	local models = {
		"models/props_gameplay/chicken.vmdl",
		"models/props_gameplay/frog.vmdl",
		"models/props_gameplay/pig.vmdl",
		"models/items/hex/fish_hex/fish_hex.vmdl",
		"models/items/hex/sheep_hex/sheep_hex.vmdl",
	}

	self.model = models[RandomInt(1, #models)]
end

--------------------------------------------------------------------------------

function modifier_radiant_shadow_shaman_voodoo:GetModifierMoveSpeedOverride() return self.movespeed end

function modifier_radiant_shadow_shaman_voodoo:GetModifierModelChange()
	return self.model
end
