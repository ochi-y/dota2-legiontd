LinkLuaModifier( "modifier_armor_medium", "ability/attack/armor_medium.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if armor_medium == nil then
	armor_medium = class({})
end
function armor_medium:GetIntrinsicModifierName()
	return "modifier_armor_medium"
end
---------------------------------------------------------------------
--Modifiers
modifier_armor_medium = class({
	IsHidden                = function(self) return false end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

	function modifier_armor_medium:GetTexture()
		return "attack/armor_medium"
	end	

function modifier_armor_medium:OnCreated(params)
	if IsServer() then
		self:GetParent().armorType="medium"
	end
end
function modifier_armor_medium:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_armor_medium:OnDestroy()
	if IsServer() then
	end
end
function modifier_armor_medium:DeclareFunctions()
	return {
	}
end