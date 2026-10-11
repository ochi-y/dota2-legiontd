LinkLuaModifier( "modifier_elf_moon_glaive_2", "ability/elf_moon_glaive_2.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if elf_moon_glaive_2 == nil then
	elf_moon_glaive_2 = class({})
end
function elf_moon_glaive_2:GetIntrinsicModifierName()
	return "modifier_elf_moon_glaive_2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_elf_moon_glaive_2 == nil then
	modifier_elf_moon_glaive_2 = class({})
end
function modifier_elf_moon_glaive_2:OnCreated(params)
	if IsServer() then
	end
end
function modifier_elf_moon_glaive_2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_elf_moon_glaive_2:OnDestroy()
	if IsServer() then
	end
end
function modifier_elf_moon_glaive_2:DeclareFunctions()
	return {
	}
end