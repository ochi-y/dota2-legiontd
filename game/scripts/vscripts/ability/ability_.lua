LinkLuaModifier( "modifier_ability_", "ability/ability_.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_ == nil then
	ability_ = class({})
end
function ability_:GetIntrinsicModifierName()
	return "modifier_ability_"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability_ == nil then
	modifier_ability_ = class({})
end
function modifier_ability_:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_:DeclareFunctions()
	return {
	}
end