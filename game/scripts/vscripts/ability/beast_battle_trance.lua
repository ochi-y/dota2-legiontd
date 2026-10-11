LinkLuaModifier( "modifier_beast_battle_trance", "ability/beast_battle_trance.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if beast_battle_trance == nil then
	beast_battle_trance = class({})
end
function beast_battle_trance:GetIntrinsicModifierName()
	return "modifier_beast_battle_trance"
end
---------------------------------------------------------------------
--Modifiers
if modifier_beast_battle_trance == nil then
	modifier_beast_battle_trance = class({})
end
function modifier_beast_battle_trance:OnCreated(params)
	if IsServer() then
	end
end
function modifier_beast_battle_trance:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_beast_battle_trance:OnDestroy()
	if IsServer() then
	end
end
function modifier_beast_battle_trance:DeclareFunctions()
	return {
	}
end