LinkLuaModifier( "modifier_ability_rock_destroy", "ability/ability_rock_destroy.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
ability_rock_destroy = class({})

wave_6_champion_rock_destroy=ability_rock_destroy

function ability_rock_destroy:GetIntrinsicModifierName()
	return "modifier_ability_rock_destroy"
end

---------------------------------------------------------------------
--Modifiers
if modifier_ability_rock_destroy == nil then
	modifier_ability_rock_destroy = class({})
end
function modifier_ability_rock_destroy:IsHidden(params)
	return true
end
function modifier_ability_rock_destroy:OnCreated(params)
	local ability=self:GetAbility()
	self.life_duration=ability:GetSpecialValueFor("life_duration")
end
function modifier_ability_rock_destroy:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_rock_destroy:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_rock_destroy:IsPurgable()
    return false
end
function modifier_ability_rock_destroy:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end
function modifier_ability_rock_destroy:OnDeath( params )
	if IsServer() then

		if params.unit == self:GetCaster() then

			local attacker=params.attacker
			if attacker and attacker==self:GetCaster() then
				return
			end

			local caster=self:GetCaster()
			local pos = caster:GetAbsOrigin()
			local ability=self:GetAbility()
			local splitCount=2
			local splitUnitName="wave_6_champion_mini"
			local pid=caster:GetPlayerOwnerID()
			local hero=PlayerResource:GetSelectedHeroEntity(pid)


			for i = 1, splitCount do
				local tUnit = CreateUnitByName(splitUnitName,pos, false, hero, hero, caster:GetTeamNumber())
				SimpleMoveUnit(tUnit,pos)
				tUnit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.1})
				alignAngle(tUnit,caster)


				if self.life_duration then
					tUnit:AddNewModifier(caster, nil, "modifier_kill", {
						duration = self.life_duration
					})
				end
				GamePlay:afterWaveCreepSummon(caster, tUnit)
			end
		end
	end
	return 0
end
