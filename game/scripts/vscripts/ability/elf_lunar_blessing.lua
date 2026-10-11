LinkLuaModifier( "modifier_elf_lunar_blessing", "ability/elf_lunar_blessing", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_elf_lunar_blessing_bonus", "ability/elf_lunar_blessing", LUA_MODIFIER_MOTION_NONE )

elf_lunar_blessing = {}


-- function elf_lunar_blessing:OnSpellStart()
-- 	local caster=self:GetCaster()
-- 	caster:AddNewModifier(caster, self, "modifier_elf_lunar_blessing", {
-- 	})
-- end


function elf_lunar_blessing:GetIntrinsicModifierName()
	if self:GetLevel()>0 then
		return "modifier_elf_lunar_blessing"
	end
end

modifier_elf_lunar_blessing = {}

function modifier_elf_lunar_blessing:IsHidden()
	return true
end

function modifier_elf_lunar_blessing:IsAura()
	if self:GetParent():PassivesDisabled() then return false end
	return true
end

function modifier_elf_lunar_blessing:GetModifierAura()
	return "modifier_elf_lunar_blessing_bonus"
end

function modifier_elf_lunar_blessing:GetAuraRadius()
	if self:GetParent():PassivesDisabled() then return 0 end
	return self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_elf_lunar_blessing:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_elf_lunar_blessing:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP+DOTA_UNIT_TARGET_HERO
end

function modifier_elf_lunar_blessing:GetAuraEntityReject(unit)
	return unit:GetLevel()<2
end

-------------------------------------------------------------------------------------------------------
modifier_elf_lunar_blessing_bonus = class({
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
function modifier_elf_lunar_blessing_bonus:AllowIllusionDuplicate()
	return false
end
function modifier_elf_lunar_blessing_bonus:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_night_vision=ability:GetSpecialValueFor("bonus_night_vision")
	self.bonus_damage=ability:GetSpecialValueFor("bonus_damage")
	if not IsServer() then return end
end
function modifier_elf_lunar_blessing_bonus:OnRefresh(params)
	self:OnCreated(params)
end

modifier_elf_lunar_blessing_bonus = {}

function modifier_elf_lunar_blessing_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
end

function modifier_elf_lunar_blessing_bonus:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor( "bonus_night_vision" )
end

function modifier_elf_lunar_blessing_bonus:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor( "bonus_damage" )
end

