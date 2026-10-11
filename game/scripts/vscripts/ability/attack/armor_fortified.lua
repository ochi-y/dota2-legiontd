LinkLuaModifier( "modifier_armor_fortified", "ability/attack/armor_fortified.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if armor_fortified == nil then
	armor_fortified = class({})
end
function armor_fortified:GetIntrinsicModifierName()
	return "modifier_armor_fortified"
end
---------------------------------------------------------------------
--Modifiers
modifier_armor_fortified = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_armor_fortified:GetTexture()
	return "attack/armor_fortified"
end

function modifier_armor_fortified:OnCreated(params)
	if IsServer() then
		self:GetParent().armorType="fortified"
	end
end
function modifier_armor_fortified:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_armor_fortified:OnDestroy()
	if IsServer() then
	end
end
function modifier_armor_fortified:DeclareFunctions()
	return {
	}
end