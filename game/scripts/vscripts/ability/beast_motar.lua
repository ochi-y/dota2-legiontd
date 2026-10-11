LinkLuaModifier( "modifier_beast_motar", "ability/beast_motar.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if beast_motar == nil then
	beast_motar = class({})
end
function beast_motar:GetIntrinsicModifierName()
	return "modifier_beast_motar"
end
---------------------------------------------------------------------
--Modifiers
if modifier_beast_motar == nil then
	modifier_beast_motar = class({})
end
function modifier_beast_motar:OnCreated(params)
	if IsServer() then
	end
end
function modifier_beast_motar:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_beast_motar:OnDestroy()
	if IsServer() then
	end
end
function modifier_beast_motar:DeclareFunctions()
	return {
	}
end