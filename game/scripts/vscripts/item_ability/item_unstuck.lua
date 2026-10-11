

LinkLuaModifier( "modifier_item_unstuck", "item_ability/item_unstuck.lua", LUA_MODIFIER_MOTION_NONE )


--Abilities
if item_unstuck == nil then
	item_unstuck = class({})
end



-- function item_unstuck:OnAbilityPhaseStart()
-- 	local caster=self:GetCaster()
-- 	local target=self:GetCursorTarget()



	
-- 	return true
-- end


function item_unstuck:OnSpellStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local pid=caster:GetPlayerOwnerID()
	local pdata=Player:GetPData(pid)

	local unit_cooldown=self:GetSpecialValueFor("unit_cooldown")
	--
	local pos=self:GetCursorPosition()
	--	EmitSoundOnLocationForPlayer("Item.Bullwhip.Ally",pos ,pid)
	
	EmitSoundOnLocationForPlayer("Hero_Sven.WarCry",pos ,pid)
	
	local dir= (pos-caster:GetAbsOrigin()):Normalized()


	--PlayEffOnUnit("particles/items4_fx/bull_whip_self.vpcf",unit)

	-- PlayEffOnLocation("particles/items4_fx/bull_whip_self.vpcf", pos, {
	-- 	cps={0,1},
	-- 	team=caster:GetTeamNumber()
	-- })

	PlayEffOnLocation("particles/legiontd/gameplay/item_unstuck.vpcf", pos, {
		cb=function (effect_cast)
			ParticleManager:SetParticleControlForward(effect_cast,0,dir)
		end
		,
		team=caster:GetTeamNumber()
	})
	local units=SimpleFindFriend(caster:GetTeamNumber(), self:GetCursorPosition(), 300)
	for key, unit in pairs(units) do
		if unit:IsCreep() and unit:GetPlayerOwnerID()==pid and not IsActiveBuilding(unit)  then
			-- unit:AddNewModifier(unit, nil, "modifier_phased", {
			-- 	duration = 0.1
			-- })
			if not unit:HasModifier("modifier_item_unstuck") then

				

				unit:AddNewModifier(unit, self, "modifier_item_unstuck", {
					duration = unit_cooldown
				})
				--GamePlay:moveCreep(unit,unit.path,unit.subPath,true)
				GamePlay:moveTowerSpawnUnit(unit)
			end
			
		end
	end

	-- local units=SimpleFindEnemy(caster:GetTeamNumber(), self:GetCursorPosition(), 300)
	-- for _, unit in pairs(units) do
	-- 	aiThinkStandard(unit)
	-- end
end

function item_unstuck:GetAOERadius()
	return 300
end

-------------------------------------------------------------------------------------------------------
modifier_item_unstuck = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return false
	end,
	IsBuff = function(self)
		return true
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_item_unstuck:AllowIllusionDuplicate()
	return false
end
function modifier_item_unstuck:OnCreated(params)
end
function modifier_item_unstuck:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_item_unstuck:DeclareFunctions()
	return {
	}
end
