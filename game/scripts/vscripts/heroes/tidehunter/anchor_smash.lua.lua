LinkLuaModifier( "modifier_anchor_smash", "heroes/tidehunter/anchor_smash.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if anchor_smash == nil then
	anchor_smash = class({})
end
function anchor_smash:GetIntrinsicModifierName()
	return "modifier_anchor_smash"
end
---------------------------------------------------------------------
--Modifiers
if modifier_anchor_smash == nil then
	modifier_anchor_smash = class({})
end
function modifier_anchor_smash:OnCreated(params)
	if IsServer() then
	end
end
function modifier_anchor_smash:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_anchor_smash:OnDestroy()
	if IsServer() then
	end
end
function modifier_anchor_smash:DeclareFunctions()
	return {
	}
end