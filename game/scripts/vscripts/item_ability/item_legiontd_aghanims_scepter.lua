LinkLuaModifier("modifier_item_legiontd_aghanims_scepter", "item_ability/item_legiontd_aghanims_scepter.lua",
	LUA_MODIFIER_MOTION_NONE)
--Abilities

item_legiontd_aghanims_scepter = class({})

-- function item_legiontd_aghanims_scepter:Spawn()
-- 	if not IsServer() then return end
-- 	local caster = self:GetCaster()
-- 	--
-- 	Timers:CreateTimer(FrameTime(), function()
-- 		self:updateState()
-- 	end)
-- 	--
-- end

function item_legiontd_aghanims_scepter:updateState()
	if not IsServer() then return end

	if self:IsNull() then
		return
	end

	self:updateUltimateAbility()
	-- Timers:CreateTimer(FrameTime(),function ()
	-- 	self:MarkAbilityButtonDirty()	
	-- end)
end

function item_legiontd_aghanims_scepter:OnAbilityPhaseStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local pid = caster:GetPlayerOwnerID()
	-- local gold=caster.gold
	-- local food=caster.food

	local required_round=self:GetSpecialValueFor("required_round")

	if FIGHTER_UPGRADE_ROUND_LIMIT then
		if GamePlay.round < GamePlay:getRoundByName(required_round) then
			SendErrorMessage(pid, "error_active_in_round", {required_round})
			return false
		end
	end

	if caster:GetLevel()==1 then
		SendErrorMessage(pid, "error_need_lv2", {})
		return false
	end

	local gold = GetUnitKV(caster:GetUnitName(), "ultimateAbilityGoldCost", 1) or 0
	if gold and gold > Player:GetGold(pid) then
		SendErrorMessage(pid, "error_need_gold", { gold })
		return false
	end

	return true
end

function item_legiontd_aghanims_scepter:updateUltimateAbility()

	local caster = self:GetCaster()
	local meta = GamePlay:FighterGetMeta(caster.fighterId)
	local f = false
	if meta and meta.learnUltimateAbility then
		f = true
	end
	if not meta and IsInToolsMode() then
		f = true
	end
	-- if not meta then
	-- 	f = true
	-- end

	if f then
		local abName=GetUnitKV(caster:GetUnitName(),"scepterAbility",1)
		if abName then
			AddAbilityAndSetLevel(caster,abName,1)
		end
		local abName1=GetUnitKV(caster:GetUnitName(),"scepterAbility1",1)
		if abName1 then
			AddAbilityAndSetLevel(caster,abName1,1)
		end
		
		caster:TakeItem(self)
		

		Timers:CreateTimer(FrameTime(), function()
			FireGameEvent("dota_ability_changed", {
				entityIndex = caster:entindex()
			})
			print("ReloadAiAbility")
			if caster.ReloadAiAbility then
				caster:ReloadAiAbility()
			end
		end)
	end
end

function item_legiontd_aghanims_scepter:learnAbility()
	local caster = self:GetCaster()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

	local meta = GamePlay:FighterGetMeta(caster.fighterId)
	if meta then
		meta.learnUltimateAbility = true
		meta.gold = caster.gold
	end
	-- caster:AddNewModifier(caster, nil, "modifier_upgrade_fighter_level", {})
	Player:UpdateCreepValue(caster:GetPlayerOwnerID())
	PlayUpgradeParticle(caster, {
		sound = "hud.equip.agh_scepter",
		particle = ""
	})
	self:updateUltimateAbility()


	
end

function item_legiontd_aghanims_scepter:OnSpellStart()
	if not IsServer() then return end

	if not self:OnAbilityPhaseStart() then
		self:EndCooldown()
		return
	end

	local caster = self:GetCaster()

	if not caster.gold then
		caster.gold = 0
	end

	local gold = GetUnitKV(caster:GetUnitName(), "ultimateAbilityGoldCost", 1) or 0
	local pid = caster:GetPlayerOwnerID()

	if gold then
		caster.gold = caster.gold + gold
		Player:ModifyGold(pid, -gold)

		
		PopupGoldGain(caster, gold, {
			usePos = true,
			team = caster:GetTeamNumber()
		})

	end
	self:learnAbility()

	caster:TakeItem(self)
end
