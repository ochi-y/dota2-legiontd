LinkLuaModifier( "modifier_gameplay_nogold", "ability/gameplay_nogold.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if gameplay_nogold == nil then
	gameplay_nogold = class({})
end
function gameplay_nogold:GetIntrinsicModifierName()
	return "modifier_gameplay_nogold"
end
---------------------------------------------------------------------
--Modifiers
modifier_gameplay_nogold = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_gameplay_nogold:GetTexture()
	return "bounty_hunter_track"
end

function modifier_gameplay_nogold:OnCreated(params)
	if IsServer() then
	end
end
function modifier_gameplay_nogold:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_gameplay_nogold:OnDestroy()
	if IsServer() then
	end
end
function modifier_gameplay_nogold:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP
	}
end
function modifier_gameplay_nogold:OnTooltip( params )
	return self:GetStackCount()
end
