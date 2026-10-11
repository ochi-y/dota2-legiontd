LinkLuaModifier( "modifier_poison_attack", "heroes/viper/poison_attack.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if poison_attack == nil then
	poison_attack = class({})
end
function poison_attack:GetIntrinsicModifierName()
	return "modifier_poison_attack"
end
---------------------------------------------------------------------
--Modifiers
if modifier_poison_attack == nil then
	modifier_poison_attack = class({})
end
function modifier_poison_attack:OnCreated(params)
	if IsServer() then
	end
end
function modifier_poison_attack:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_poison_attack:OnDestroy()
	if IsServer() then
	end
end
function modifier_poison_attack:DeclareFunctions()
	return {
	}
end