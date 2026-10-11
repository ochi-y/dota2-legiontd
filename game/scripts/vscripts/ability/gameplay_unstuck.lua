LinkLuaModifier( "modifier_gameplay_unstuck", "ability/gameplay_unstuck.lua", LUA_MODIFIER_MOTION_NONE )

--Abilities
if gameplay_unstuck == nil then
	gameplay_unstuck = class({})
end
function gameplay_unstuck:OnSpellStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local pid=caster:GetPlayerOwnerID()
	local pdata=Player:GetPData(pid)
	--
	local units=SimpleFindFriend(caster:GetTeamNumber(), self:GetCursorPosition(), 300)
	for key, unit in pairs(units) do
		if unit:IsCreep() and unit:GetPlayerOwnerID()==pid then
			-- unit:AddNewModifier(unit, nil, "modifier_phased", {
			-- 	duration = 0.1
			-- })
			--GamePlay:moveCreep(unit,unit.path,unit.subPath,true)
			GamePlay:moveTowerSpawnUnit(unit)
		end
	end

	-- local units=SimpleFindEnemy(caster:GetTeamNumber(), self:GetCursorPosition(), 300)
	-- for _, unit in pairs(units) do
	-- 	aiThinkStandard(unit)
	-- end
end

function gameplay_unstuck:GetAOERadius()
	return 300
end
