LinkLuaModifier( "modifier_shadow_conjure_fiend", "ability/shadow_conjure_fiend.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_conjure_fiend == nil then
	shadow_conjure_fiend = class({})
end
function shadow_conjure_fiend:OnSpellStart()
	local unitName  ="shadow_fiend"
	local caster=self:GetCaster()

	local pid=caster:GetPlayerOwnerID()
	--EmitSoundOn("n_creep_TrollWarlord.RaiseDead", caster)
	EmitSoundOn("DOTA_Item.Necronomicon.Activate", caster)
	local hero=PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())  
	local points=GenPointsForSummon(caster,128,50,1)
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
