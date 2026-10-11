LinkLuaModifier( "modifier_marine_mitosis", "ability/marine_mitosis.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if marine_mitosis == nil then
	marine_mitosis = class({})
end
function marine_mitosis:GetIntrinsicModifierName()
	return "modifier_marine_mitosis"
end
---------------------------------------------------------------------
--Modifiers
if modifier_marine_mitosis == nil then
	modifier_marine_mitosis = class({})
end
function modifier_marine_mitosis:IsHidden(params)
	return true
end
function modifier_marine_mitosis:OnCreated(params)
	if IsServer() then
	end
end
function modifier_marine_mitosis:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_marine_mitosis:OnDestroy()
	if IsServer() then
	end
end
function modifier_marine_mitosis:IsPurgable()
    return false
end
function modifier_marine_mitosis:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end
function modifier_marine_mitosis:OnDeath( params )
	if IsServer() then

		if params.unit == self:GetCaster() then

			local attacker=params.attacker
			if attacker and attacker==self:GetCaster() then
				return
			end
			if not attacker then
				return
			end
			
			local caster=self:GetCaster()
			if caster:HasModifier("modifier_tower") then
				return
			end

			local pos = caster:GetAbsOrigin()
			local ability=self:GetAbility()
			local splitCount=3
			local splitUnitName="marine_hydra_mini"
			local pid=caster:GetPlayerOwnerID()
			local hero=PlayerResource:GetSelectedHeroEntity(pid)
			for i = 1, splitCount do
					local tUnit = CreateUnitByName(splitUnitName,pos, false, hero, hero, caster:GetTeamNumber())
				SimpleMoveUnit(tUnit,pos)

				if caster:GetLevel()>tUnit:GetLevel() then
					tUnit:CreatureLevelUp(1)
				end

				tUnit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.1})
				alignAngle(tUnit,caster)
				local pdata=Player:GetPData(caster:GetPlayerOwnerID())
				if tUnit and pdata then
					table.insert(pdata.creeps,tUnit)
				end
				if tUnit then
					tUnit.wayStep=caster.wayStep
					tUnit.waypoints=caster.waypoints
				end
			end
		end
	end
	return 0
end
