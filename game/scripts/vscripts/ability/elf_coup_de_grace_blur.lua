LinkLuaModifier( "modifier_elf_coup_de_grace_blur", "ability/elf_coup_de_grace_blur.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if elf_coup_de_grace_blur == nil then
	elf_coup_de_grace_blur = class({})
end
function elf_coup_de_grace_blur:GetIntrinsicModifierName()
	return "modifier_elf_coup_de_grace_blur"
end
---------------------------------------------------------------------
--Modifiers
modifier_elf_coup_de_grace_blur = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_elf_coup_de_grace_blur:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.evasion_chance_pct=ability:GetSpecialValueFor("bonus_evasion")
end
function modifier_elf_coup_de_grace_blur:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_elf_coup_de_grace_blur:OnDestroy()
	if IsServer() then
	end
end
function modifier_elf_coup_de_grace_blur:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
end

function modifier_elf_coup_de_grace_blur:GetModifierEvasion_Constant()
	return self.evasion_chance_pct
end