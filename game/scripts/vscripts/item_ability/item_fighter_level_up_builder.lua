LinkLuaModifier( "modifier_item_fighter_level_up_builder", "item_ability/item_fighter_level_up_builder.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
item_fighter_level_up_builder = class({})

-- function item_fighter_level_up_builder:Spawn()
-- 	if not IsServer() then return end
-- 	-- Timers:CreateTimer(FrameTime(),function ()
-- 	-- 	self:SetActivated(false)
-- 	-- end)
-- 	Timers:CreateTimer(FrameTime(), function()
-- 		local caster = self:GetCaster()
-- 		-- print(caster)
-- 		if caster:GetLevel() > 1 then 
-- 			Timers:CreateTimer(FrameTime(), function()
-- 				caster:RemoveItem(self)
-- 			end)
-- 		end
-- 		if FIGHTER_UPGRADE_ROUND_LIMIT then
-- 			local start_round = self:GetSpecialValueFor("start_round")
-- 			if GamePlay.round < GamePlay:getRoundByName(start_round) then
-- 				self:SetActivated(false)
-- 			end
-- 		end
-- 	end)
-- end

function item_fighter_level_up_builder:OnAbilityPhaseStart()
	if not IsServer() then return end
	local caster = self:GetCaster()

	local pid = caster:GetPlayerOwnerID()

	local target =self:GetCursorTarget()


	local start_round = self:GetSpecialValueFor("start_round")

	if GamePlay.round < GamePlay:getRoundByName(start_round) then
		SendErrorMessage(pid, "error_active_in_round", {start_round})
		return false
	end
	
	if caster:GetPlayerOwnerID()~=target:GetPlayerOwnerID() or not IsCustomBuilding(target) or not target.fighterId then
		SendErrorMessage(pid, "error_illegal_operation", {  })
		return false
	end

	if not GamePlay:canBeUpgraded(target) then
		SendErrorMessage(pid, "error_illegal_operation", {  })
		return false
	end

	if target:GetLevel()>1 then
		SendErrorMessage(pid, "error_illegal_operation", {  })
		return false
	end

	

	local gold = target.gold
	local food = target.food
	if gold and gold > Player:GetGold(pid) then
		SendErrorMessage(pid, "error_need_gold_food", { gold,food })
		return false
	end
	if food and food > Player:GetFood(pid) then
		SendErrorMessage(pid, "error_need_gold_food", { gold,food })
		return false
	end
	return true
end

function item_fighter_level_up_builder:OnSpellStart()
	if not IsServer() then return end

	if not self:OnAbilityPhaseStart() then
		self:EndCooldown()
		return
	end

	local caster = self:GetCaster()

	local target =self:GetCursorTarget()

	local gold = target.gold
	local food = target.food
	local pid = target:GetPlayerOwnerID()

	if gold then
		target.gold = target.gold + gold
		Player:ModifyGold(pid, -gold)
	end
	if food then
		target.food = target.food + food
		Player:ModifyFood(pid, -food)
	end

	PopupGoldGain(target, gold, {
		usePos = true,
		team = target:GetTeamNumber()
	})
	PopupLumber(target, food)

	local meta = GamePlay:FighterGetMeta(target.fighterId)
	if meta then
		meta.gold = target.gold
		meta.wood = target.wood
		meta.food = target.food
	end

	GamePlay:fighterLevelUp(target)

	-- caster:RemoveItem(self)
	-- Timers:CreateTimer(FrameTime(), function()
	-- 	FireGameEvent("dota_ability_changed", {
	-- 		entityIndex = caster:entindex()
	-- 	})
	-- end)
end

-- function item_fighter_level_up_builder:fighterLevelUp()
-- 	if not IsServer() then return end

-- 	local caster = self:GetCaster()

-- 	local pid = caster:GetPlayerOwnerID()

-- 	caster:CreatureLevelUp(1)
-- 	caster:StartGesture(ACT_DOTA_ATTACK)
-- 	local meta = GamePlay:FighterGetMeta(caster.fighterId)
-- 	if meta then
-- 		meta.level = caster:GetLevel()
-- 	end
-- 	-- SimplePlayEffOnUnit(caster,"particles/econ/events/ti10/hero_levelup_ti10.vpcf")
-- 	-- EmitSoundOnLocationForAllies(caster:GetAbsOrigin(),"Hero_Chen.DivineFavor.Target", caster)
-- 	-- caster:AddNewModifier(caster, nil, "modifier_item_fighter_level_up_builder", {})

-- 	Timers:CreateTimer(FrameTime(), function()
-- 		caster:RemoveAbility("item_fighter_level_up_builder")

-- 		local ab = caster:FindAbilityByName("learn_fighter_ultimate_ability")
-- 		if ab then
-- 			ab:updateState()
-- 		end
-- 	end)
-- 	Player:UpdateCreepValue(caster:GetPlayerOwnerID())

-- 	PlayUpgradeParticle(caster, {
-- 		sound = "Item.TomeOfKnowledge",
-- 		particle = "particles/generic_hero_status/hero_levelup_fallback.vpcf"
-- 	})
-- end

-- function item_fighter_level_up_builder:GetHealthCost(level)
-- 	if IsServer() then
-- 		return 0
-- 	else
-- 		return self:GetSpecialValueFor("gold")
-- 	end
-- end

-------------------------------------------------------------------------------------------------------
modifier_item_fighter_level_up_builder = class({
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
function modifier_item_fighter_level_up_builder:AllowIllusionDuplicate()
	return false
end

function modifier_item_fighter_level_up_builder:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
	if not IsServer() then return end
	-- local parent=self:GetParent()
	-- parent:SetBaseDamageMin(0.95 * parent:GetBaseDamageMin())
	-- parent:SetBaseDamageMax(0.95 * parent:GetBaseDamageMax())
end

function modifier_item_fighter_level_up_builder:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_item_fighter_level_up_builder:DeclareFunctions()
	return {
		--MODIFIER_PROPERTY_MODEL_SCALE,
		--MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}
end

function modifier_item_fighter_level_up_builder:GetEffectName()
	return "particles/items5_fx/helm_of_the_dominator_buff.vpcf"
end

function modifier_item_fighter_level_up_builder:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_item_fighter_level_up_builder:GetModifierModelScale()
	return 10
end

function modifier_item_fighter_level_up_builder:GetModifierExtraHealthPercentage()
	return -5
end

function modifier_item_fighter_level_up_builder:GetTexture()
	return "war3r/BTNDrektharsSpellBook"
end
