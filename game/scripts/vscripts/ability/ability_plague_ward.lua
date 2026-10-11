LinkLuaModifier("modifier_ability_plague_ward", "ability/ability_plague_ward.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if ability_plague_ward == nil then
	ability_plague_ward = class({})
end

wave_5_champion_plague_ward = ability_plague_ward
function ability_plague_ward:OnSpellStart()
	if not IsServer() then return end
	-- local caster = self:GetCaster()
	-- local pos = self:GetCursorPosition()
	-- local life_duration = self:GetSpecialValueFor("duration")

	-- local unit = caster:SummonUnit("npc_Advanced_Plague_Ward",life_duration,pos,nil,self,0,heal,0,damage,armor,1,1)

	-- unit:EmitSound("Hero_Venomancer.Plague_Ward")


	local unitName = "wave_plague_ward_1"
	local caster   = self:GetCaster()

	local pid      = caster:GetPlayerOwnerID()
	EmitSoundOn("Hero_Venomancer.Plague_Ward", caster)

	local duration = self:GetSpecialValueFor("duration")
	local count = 1

	--local points=GenPointsForSummon(caster,0,0,count)

	local pfx_cast = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_venomancer/venomancer_ward_cast.vpcf", PATTACH_CUSTOMORIGIN, caster)
	for i = 0, 1 do
		ParticleManager:SetParticleControlEnt(pfx_cast, i, caster, PATTACH_POINT_FOLLOW, "attach_attack" .. (i + 1),
			caster:GetAbsOrigin(), true)
	end
	ParticleManager:ReleaseParticleIndex(pfx_cast)

	local points = { self:GetCursorPosition() }

	for _, pos in pairs(points) do
		local newUnit = CreateUnitByName(unitName, pos, false, nil, nil, caster:GetTeamNumber())
		newUnit:AddNewModifier(caster, nil, "modifier_kill", {
			duration = duration
		})
		local pdata = Player:GetPData(pid)
		-- if newUnit and pdata then
		-- 	table.insert(pdata.creeps,newUnit)
		-- end
		GamePlay:afterWaveCreepSummon(caster, newUnit)



		local pfx = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_venomancer/venomancer_ward_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, newUnit)
		ParticleManager:ReleaseParticleIndex(pfx)
		-- ward:AddNewModifier(caster, self, "modifier_Primary_Plague_Ward_think", {duration = life_duration})
		-- ward:AddNewModifier(caster, self, "modifier_kill", {duration = life_duration})
	end
end
