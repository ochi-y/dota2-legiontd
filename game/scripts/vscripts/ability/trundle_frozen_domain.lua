LinkLuaModifier( "modifier_trundle_frozen_domain", "ability/trundle_frozen_domain.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if trundle_frozen_domain == nil then
	trundle_frozen_domain = class({})
end
function trundle_frozen_domain:GetIntrinsicModifierName()
	return "modifier_trundle_frozen_domain"
end
---------------------------------------------------------------------
--Modifiers
if modifier_trundle_frozen_domain == nil then
	modifier_trundle_frozen_domain = class({})
end
function modifier_trundle_frozen_domain:OnCreated(params)
	if IsServer() then
	end
end
function modifier_trundle_frozen_domain:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_trundle_frozen_domain:OnDestroy()
	if IsServer() then
	end
end
function modifier_trundle_frozen_domain:DeclareFunctions()
	return {
	}
end