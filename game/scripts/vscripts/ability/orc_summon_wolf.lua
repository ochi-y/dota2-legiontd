LinkLuaModifier( "modifier_orc_summon_wolf", "ability/orc_summon_wolf.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if orc_summon_wolf == nil then
	orc_summon_wolf = class({})
end
function orc_summon_wolf:OnSpellStart()
	local unitName  ="orc_wolf"
	local caster=self:GetCaster()

	local pid=caster:GetPlayerOwnerID()
	EmitSoundOn("Hero_Lycan.SummonWolves", caster)

	SimplePlayEffOnUnit(caster,"particles/units/heroes/hero_lycan/lycan_summon_wolves_cast.vpcf")



	local hero=PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())  
	local points=GenPointsForSummon(caster,0,60,1)
	for _, pos in pairs(points) do
		local newUnit=OnZhaoHuan( unitName,caster,pos,caster:GetTeamNumber(),60,1,"particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf")  
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
