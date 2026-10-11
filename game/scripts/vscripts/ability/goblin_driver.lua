LinkLuaModifier( "modifier_goblin_driver", "ability/goblin_driver.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if goblin_driver == nil then
	goblin_driver = class({})
end
function goblin_driver:GetIntrinsicModifierName()
	return "modifier_goblin_driver"
end
---------------------------------------------------------------------
--Modifiers
if modifier_goblin_driver == nil then
	modifier_goblin_driver = class({})
end
function modifier_goblin_driver:OnCreated(params)
	if IsServer() then
	end
end
function modifier_goblin_driver:IsHidden(params)
	return true
end
function modifier_goblin_driver:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_goblin_driver:OnDestroy()
	if IsServer() then
	end
end
function modifier_goblin_driver:IsPurgable()
    return false
end
function modifier_goblin_driver:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end
function modifier_goblin_driver:OnDeath( params )
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
			local splitCount=1
			local splitUnitName="goblin_geomancer"
			local pid=caster:GetPlayerOwnerID()
			local hero=PlayerResource:GetSelectedHeroEntity(pid)
			for i = 1, splitCount do
				local tUnit = CreateUnitByName(splitUnitName,pos, false, hero, hero, caster:GetTeamNumber())
				SimpleMoveUnit(tUnit,pos)
				tUnit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.1})
				
				tUnit.isInDefense=caster.isInDefense

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
