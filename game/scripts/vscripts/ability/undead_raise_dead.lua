LinkLuaModifier( "modifier_undead_raise_dead", "ability/undead_raise_dead.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if undead_raise_dead == nil then
	undead_raise_dead = class({})
end
function undead_raise_dead:OnSpellStart()
	local unitName  ="undead_fire_archer"
	local caster=self:GetCaster()

	local pid=caster:GetPlayerOwnerID()
	EmitSoundOn("n_creep_TrollWarlord.RaiseDead", caster)
	local hero=PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())  

	local duration=self:GetSpecialValueFor("duration")
	local count=self:GetSpecialValueFor("count")


	local points=GenPointsForSummon(caster,-50,40,count)
	for _, pos in pairs(points) do
		local newUnit=OnZhaoHuan( unitName,caster,pos,caster:GetTeamNumber(),duration,1)  
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
