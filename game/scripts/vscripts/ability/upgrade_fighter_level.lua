LinkLuaModifier("modifier_upgrade_fighter_level", "ability/upgrade_fighter_level.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if upgrade_fighter_level == nil then
	upgrade_fighter_level = class({})
end

function upgrade_fighter_level:Spawn()
	if not IsServer() then return end
	local caster = self:GetCaster()
	
	Timers:CreateTimer(FrameTime(), function()
		if caster:GetLevel() > 1 then 
			--caster:AddNewModifier(caster, nil, "modifier_upgrade_fighter_level", {})
			Timers:CreateTimer(FrameTime(), function()
				caster:RemoveAbility("upgrade_fighter_level")
			end)
		end
		if FIGHTER_UPGRADE_ROUND_LIMIT then
			local start_round = self:GetSpecialValueFor("start_round")
			if GamePlay.round < GamePlay:getRoundByName(start_round) then
				self:SetActivated(false)
			end
		end
	end)
end

function upgrade_fighter_level:OnAbilityPhaseStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local pid = caster:GetPlayerOwnerID()
	local gold = caster.gold
	local food = caster.food
	if gold and gold > Player:GetGold(pid) then
		SendErrorMessage(pid, "error_need_gold", { gold })
		return false
	end
	if food and food > Player:GetFood(pid) then
		SendErrorMessage(pid, "error_need_food", { food })
		return false
	end
	return true
end

function upgrade_fighter_level:OnSpellStart()
	if not IsServer() then return end

	if not self:OnAbilityPhaseStart() then
		self:EndCooldown()
		return
	end

	local caster = self:GetCaster()

	local gold = caster.gold
	local food = caster.food
	local pid = caster:GetPlayerOwnerID()

	if gold then
		caster.gold = caster.gold + gold
		Player:ModifyGold(pid, -gold)
	end
	if food then
		caster.food = caster.food + food
		Player:ModifyFood(pid, -food)
	end

	local meta = GamePlay:FighterGetMeta(caster.fighterId)
	if meta then
		meta.gold = caster.gold
		meta.wood = caster.wood
		meta.food = caster.food
	end
	self:fighterLevelUp()

	Timers:CreateTimer(FrameTime(), function()
		FireGameEvent("dota_ability_changed", {
			entityIndex = caster:entindex()
		})
	end)
end

function upgrade_fighter_level:fighterLevelUp()
	if not IsServer() then return end

	local caster = self:GetCaster()

	local pid = caster:GetPlayerOwnerID()

	caster:CreatureLevelUp(1)
	caster:StartGesture(ACT_DOTA_ATTACK)
	local meta = GamePlay:FighterGetMeta(caster.fighterId)
	if meta then
		meta.level = caster:GetLevel()
	end
	-- SimplePlayEffOnUnit(caster,"particles/econ/events/ti10/hero_levelup_ti10.vpcf")
	-- EmitSoundOnLocationForAllies(caster:GetAbsOrigin(),"Hero_Chen.DivineFavor.Target", caster)
	-- caster:AddNewModifier(caster, nil, "modifier_upgrade_fighter_level", {})

	Timers:CreateTimer(FrameTime(), function()
		caster:RemoveAbility("upgrade_fighter_level")

		local ab = caster:FindAbilityByName("learn_fighter_ultimate_ability")
		if ab then
			ab:updateState()
		end
	end)

	Player:UpdateCreepValue(caster:GetPlayerOwnerID())

	PlayUpgradeParticle(caster, {
		sound = "Hero_Chen.DivineFavor.Target",
		particle = "particles/units/heroes/hero_chen/chen_teleport_flash.vpcf"
	})
end

-- function upgrade_fighter_level:GetHealthCost(level)
-- 	if IsServer() then
-- 		return 0
-- 	else
-- 		return self:GetSpecialValueFor("gold")
-- 	end
-- end

-------------------------------------------------------------------------------------------------------
modifier_upgrade_fighter_level = class({
	IsHidden = function(self)
		return true
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
function modifier_upgrade_fighter_level:AllowIllusionDuplicate()
	return false
end

function modifier_upgrade_fighter_level:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
	if not IsServer() then return end
	-- local parent=self:GetParent()
	-- parent:SetBaseDamageMin(0.95 * parent:GetBaseDamageMin())
	-- parent:SetBaseDamageMax(0.95 * parent:GetBaseDamageMax())
end

function modifier_upgrade_fighter_level:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_upgrade_fighter_level:DeclareFunctions()
	return {
		--MODIFIER_PROPERTY_MODEL_SCALE,
		--MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}
end

function modifier_upgrade_fighter_level:GetEffectName()
	return "particles/items5_fx/helm_of_the_dominator_buff.vpcf"
end

function modifier_upgrade_fighter_level:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_upgrade_fighter_level:GetModifierModelScale()
	return 10
end

function modifier_upgrade_fighter_level:GetModifierExtraHealthPercentage()
	return -5
end

function modifier_upgrade_fighter_level:GetTexture()
	return "war3r/BTNDrektharsSpellBook"
end
