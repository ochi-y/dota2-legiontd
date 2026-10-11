LinkLuaModifier( "modifier_elf_mirana_invis", "ability/elf_mirana_invis.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if elf_mirana_invis == nil then
	elf_mirana_invis = class({})
end
function elf_mirana_invis:OnSpellStart()
	local caster=self:GetCaster()
	local radius=self:GetSpecialValueFor("radius")
	local duration=self:GetSpecialValueFor("duration")

	local units=FindAbilityTarget(self,caster:GetAbsOrigin(),radius,{})

	EmitSoundOn("Ability.MoonlightShadow", caster)

	for index, unit in ipairs(units) do
		
		PlayEffOnUnit("particles/units/heroes/hero_mirana/mirana_moonlight_recipient.vpcf",unit)

		unit:AddNewModifier(unit, self, "modifier_elf_mirana_invis", {
			duration=duration
		})
	end
end

---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_elf_mirana_invis = class({
	IsHidden = function(self)
		return false
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
function modifier_elf_mirana_invis:AllowIllusionDuplicate()
	return false
end
function modifier_elf_mirana_invis:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_movement_speed=ability:GetSpecialValueFor("bonus_movement_speed")
	self.evasion=ability:GetSpecialValueFor("evasion")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
end
function modifier_elf_mirana_invis:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_elf_mirana_invis:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE 
	}
end

function modifier_elf_mirana_invis:GetModifierNegativeEvasion_Constant()
	return self.evasion
end

function modifier_elf_mirana_invis:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movement_speed
end

function modifier_elf_mirana_invis:GetEffectName()
	return "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
end
function modifier_elf_mirana_invis:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end