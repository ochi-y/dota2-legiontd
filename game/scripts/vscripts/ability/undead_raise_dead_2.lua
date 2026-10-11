LinkLuaModifier( "modifier_undead_raise_dead_2", "ability/undead_raise_dead_2.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if undead_raise_dead_2 == nil then
	undead_raise_dead_2 = class({})
end
function undead_raise_dead_2:OnSpellStart()
	local unitName  ="undead_fire_archer_elite"
	local caster=self:GetCaster()
	local pid=caster:GetPlayerOwnerID()
	EmitSoundOn("n_creep_TrollWarlord.RaiseDead", caster)
	local hero=PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())  

	local points=GenPointsForSummon(caster,-64,64,3)

	for _, pos in pairs(points) do
		local newUnit=OnZhaoHuan( unitName,caster,pos,caster:GetTeamNumber(),60,1)  
		local pdata=Player:GetPData(pid)
		if newUnit and pdata then
			table.insert(pdata.creeps,newUnit)
		end
		if newUnit then
			newUnit.wayStep=caster.wayStep
			newUnit.waypoints=caster.waypoints
		end
	end
end
