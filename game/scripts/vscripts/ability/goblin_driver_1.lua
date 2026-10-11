LinkLuaModifier( "modifier_goblin_driver_1", "ability/goblin_driver_1.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if goblin_driver_1 == nil then
	goblin_driver_1 = class({})
end
function goblin_driver_1:GetIntrinsicModifierName()
	return "modifier_goblin_driver_1"
end
---------------------------------------------------------------------
--Modifiers
if modifier_goblin_driver_1 == nil then
	modifier_goblin_driver_1 = class({})
end
function modifier_goblin_driver_1:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.count=ability:GetSpecialValueFor("count")
end
function modifier_goblin_driver_1:IsHidden(params)
	return true
end
function modifier_goblin_driver_1:OnRefresh(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.count=ability:GetSpecialValueFor("count")
end
function modifier_goblin_driver_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_goblin_driver_1:IsPurgable()
    return false
end
function modifier_goblin_driver_1:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end
function modifier_goblin_driver_1:OnDeath( params )
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

			for i = 1, self.count, 1 do
				
				
				local pos = caster:GetAbsOrigin()
				local ability=self:GetAbility()
				local splitCount=1
				local splitUnitName="goblin_clockwreck"
				local pid=caster:GetPlayerOwnerID()
				local hero=PlayerResource:GetSelectedHeroEntity(pid)
				for i = 1, splitCount do
					local tUnit = CreateUnitByName(splitUnitName,pos, false, hero, hero, caster:GetTeamNumber())

					if caster:GetLevel()>tUnit:GetLevel() then
						tUnit:CreatureLevelUp(1)
					end
					
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
	end
	return 0
end
