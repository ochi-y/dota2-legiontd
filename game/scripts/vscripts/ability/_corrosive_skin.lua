LinkLuaModifier( "modifier__corrosive_skin", "ability/_corrosive_skin.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if _corrosive_skin == nil then
	_corrosive_skin = class({})
end
function _corrosive_skin:GetIntrinsicModifierName()
	return "modifier__corrosive_skin"
end
---------------------------------------------------------------------
--Modifiers
if modifier__corrosive_skin == nil then
	modifier__corrosive_skin = class({})
end
function modifier__corrosive_skin:OnCreated(params)
	if IsServer() then
	end
end
function modifier__corrosive_skin:OnRefresh(params)
	if IsServer() then
	end
end
function modifier__corrosive_skin:OnDestroy()
	if IsServer() then
	end
end
function modifier__corrosive_skin:DeclareFunctions()
	return {
	}
end