LinkLuaModifier( "modifier_buy_barrack_bowman", "barrack/buy_barrack_bowman.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_bowman == nil then
	buy_barrack_bowman = class({})
end
function buy_barrack_bowman:GetIntrinsicModifierName()
	return "modifier_buy_barrack_bowman"
end
---------------------------------------------------------------------
--Modifiers
if modifier_buy_barrack_bowman == nil then
	modifier_buy_barrack_bowman = class({})
end
function modifier_buy_barrack_bowman:OnCreated(params)
	if IsServer() then
	end
end
function modifier_buy_barrack_bowman:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_buy_barrack_bowman:OnDestroy()
	if IsServer() then
	end
end
function modifier_buy_barrack_bowman:DeclareFunctions()
	return {
	}
end