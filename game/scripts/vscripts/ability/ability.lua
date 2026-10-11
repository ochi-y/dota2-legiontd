LinkLuaModifier( "modifier_ability", "ability/ability.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability == nil then
	ability = class({})
end
function ability:GetIntrinsicModifierName()
	return "modifier_ability"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability == nil then
	modifier_ability = class({})
end
function modifier_ability:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability:DeclareFunctions()
	return {
	}
end