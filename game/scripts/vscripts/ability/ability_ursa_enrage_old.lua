LinkLuaModifier( "modifier_ability_ursa_enrage_old", "ability/ability_ursa_enrage_old.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_ursa_enrage_old == nil then
	ability_ursa_enrage_old = class({})
end
function ability_ursa_enrage_old:GetIntrinsicModifierName()
	return "modifier_ability_ursa_enrage_old"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability_ursa_enrage_old == nil then
	modifier_ability_ursa_enrage_old = class({})
end
function modifier_ability_ursa_enrage_old:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_ursa_enrage_old:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_ursa_enrage_old:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_ursa_enrage_old:DeclareFunctions()
	return {
	}
end