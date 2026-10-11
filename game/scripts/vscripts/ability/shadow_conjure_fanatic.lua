LinkLuaModifier( "modifier_shadow_conjure_fanatic", "ability/shadow_conjure_fanatic.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_conjure_fanatic == nil then
	shadow_conjure_fanatic = class({})
end
function shadow_conjure_fanatic:OnSpellStart()
	local unitName  ="shadow_fanatic"
	local caster=self:GetCaster()

	local pid=caster:GetPlayerOwnerID()
	--EmitSoundOn("n_creep_TrollWarlord.RaiseDead", caster)
	EmitSoundOn("DOTA_Item.Necronomicon.Activate", caster)

	local duration=self:GetSpecialValueFor("duration")

	local hero=PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())  
	
	local points=GenPointsForSummon(caster,128,50,1)
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
