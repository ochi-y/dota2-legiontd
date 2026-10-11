LinkLuaModifier( "modifier_shadow_diablo", "ability/shadow_diablo.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_diablo == nil then
	shadow_diablo = class({})
end
function shadow_diablo:OnSpellStart()
	local unitName  ="shadow_diablo"
	local caster=self:GetCaster()

	local pid=caster:GetPlayerOwnerID()
	--EmitSoundOn("n_creep_TrollWarlord.RaiseDead", caster)
	EmitSoundOn("DOTA_Item.Necronomicon.Activate", caster)
	local hero=PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())  

	local duration=self:GetSpecialValueFor("duration")

	local points=GenPointsForSummon(caster,100,40,1)
	for _, pos in pairs(points) do
		local newUnit=OnZhaoHuan( unitName,caster,pos,caster:GetTeamNumber(),duration,1,"particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf")

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
