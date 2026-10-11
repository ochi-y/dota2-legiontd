LinkLuaModifier( "modifier_armor_hero", "ability/attack/armor_hero.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if armor_hero == nil then
	armor_hero = class({})
end
function armor_hero:GetIntrinsicModifierName()
	return "modifier_armor_hero"
end
---------------------------------------------------------------------
--Modifiers
modifier_armor_hero = class({
	IsHidden                = function(self) return false end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})
	function modifier_armor_hero:GetTexture()
		return "attack/armor_hero"
	end

function modifier_armor_hero:OnCreated(params)
	if IsServer() then
		self:GetParent().armorType="hero"
	end
end
function modifier_armor_hero:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_armor_hero:OnDestroy()
	if IsServer() then
	end
end
function modifier_armor_hero:DeclareFunctions()
	return {
	}
end