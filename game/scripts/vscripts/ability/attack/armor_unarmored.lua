LinkLuaModifier( "modifier_armor_unarmored", "ability/attack/armor_unarmored.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if armor_unarmored == nil then
	armor_unarmored = class({})
end
function armor_unarmored:GetIntrinsicModifierName()
	return "modifier_armor_unarmored"
end
---------------------------------------------------------------------
--Modifiers
modifier_armor_unarmored = class({
	IsHidden                = function(self) return false end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

	function modifier_armor_unarmored:GetTexture()
		return "attack/armor_unarmored"
	end	
	
function modifier_armor_unarmored:OnCreated(params)
	if IsServer() then
		self:GetParent().armorType="unarmored"
	end
end
function modifier_armor_unarmored:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_armor_unarmored:OnDestroy()
	if IsServer() then
	end
end
function modifier_armor_unarmored:DeclareFunctions()
	return {
	}
end