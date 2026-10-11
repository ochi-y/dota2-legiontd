LinkLuaModifier( "modifier_arctic_cold_embrace", "ability/arctic_cold_embrace.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if arctic_cold_embrace == nil then
	arctic_cold_embrace = class({})
end
function arctic_cold_embrace:GetIntrinsicModifierName()
	return "modifier_arctic_cold_embrace"
end
---------------------------------------------------------------------
--Modifiers
if modifier_arctic_cold_embrace == nil then
	modifier_arctic_cold_embrace = class({})
end
function modifier_arctic_cold_embrace:OnCreated(params)
	if IsServer() then
	end
end
function modifier_arctic_cold_embrace:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_arctic_cold_embrace:OnDestroy()
	if IsServer() then
	end
end
function modifier_arctic_cold_embrace:DeclareFunctions()
	return {
	}
end