LinkLuaModifier( "modifier_armor_light", "ability/attack/armor_light.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if armor_light == nil then
	armor_light = class({})
end
function armor_light:GetIntrinsicModifierName()
	return "modifier_armor_light"
end
---------------------------------------------------------------------
--Modifiers
modifier_armor_light = class({
	IsHidden                = function(self) return false end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

	function modifier_armor_light:GetTexture()
		return "attack/armor_light"
	end	
function modifier_armor_light:OnCreated(params)
	if IsServer() then
		self:GetParent().armorType="light"
	end
end
function modifier_armor_light:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_armor_light:OnDestroy()
	if IsServer() then
	end
end
function modifier_armor_light:DeclareFunctions()
	return {
	}
end