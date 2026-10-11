LinkLuaModifier( "modifier_shadow_imp", "ability/shadow_imp.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_imp == nil then
	shadow_imp = class({})
end
function shadow_imp:OnSpellStart()
	local unitNameList  ={"shadow_imp"}
	local caster=self:GetCaster()

	local pid=caster:GetPlayerOwnerID()
	--EmitSoundOn("n_creep_TrollWarlord.RaiseDead", caster)
	EmitSoundOn("DOTA_Item.Necronomicon.Activate", caster)
	local hero=PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())  

	local duration=self:GetSpecialValueFor("duration")
	local count=self:GetSpecialValueFor("count")


	local points=GenPointsForSummon(caster,128,64,count)
	for index, pos in pairs(points) do
		local newUnit=OnZhaoHuan( unitNameList[index%#unitNameList+1],caster,pos,caster:GetTeamNumber(),duration,1,"particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf")
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
