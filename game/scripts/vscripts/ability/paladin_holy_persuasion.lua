LinkLuaModifier( "modifier_paladin_holy_persuasion", "ability/paladin_holy_persuasion.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if paladin_holy_persuasion == nil then
	paladin_holy_persuasion = class({})
end

function paladin_holy_persuasion:OnSpellStart()
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()
end


if modifier_paladin_holy_persuasion == nil then
	modifier_paladin_holy_persuasion = class({})
end

function modifier_paladin_holy_persuasion:OnCreated(params)
	if IsServer() then
	end
end

function modifier_paladin_holy_persuasion:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_paladin_holy_persuasion:OnDestroy()
	if IsServer() then
	end
end
function modifier_paladin_holy_persuasion:DeclareFunctions()
	return {
	}
end