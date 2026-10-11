LinkLuaModifier( "modifier_shadow_invoke_inferno", "ability/shadow_invoke_inferno.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_invoke_inferno == nil then
	shadow_invoke_inferno = class({})
end
function shadow_invoke_inferno:OnSpellStart()
	local unitName  ="shadow_inferno"
	local caster=self:GetCaster()

	local pid=caster:GetPlayerOwnerID()
	--EmitSoundOn("n_creep_TrollWarlord.RaiseDead", caster)
	EmitSoundOn("DOTA_Item.Necronomicon.Activate", caster)
	local hero=PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())  

	local duration=self:GetSpecialValueFor("duration")

	local points=GenPointsForSummon(caster,0,75,1)
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
