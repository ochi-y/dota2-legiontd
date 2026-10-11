LinkLuaModifier( "modifier_item_test_kill", "item_ability/item_test_kill.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_test_kill == nil then
	item_test_kill = class({})
end

function item_test_kill:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end
function item_test_kill:OnSpellStart()
	local caster = self:GetCaster()
	--local target = self:GetCursorTarget()
	local target_position = self:GetCastPosition()
	local radius = self:GetAOERadius()
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_position, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 
	DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	, FIND_ANY_ORDER, false)

	if #enemies > 0 then
		for _, enemy in pairs(enemies) do
            --enemy:ForceKill(true)
			enemy:Kill(self,caster)
        end
	end
end
