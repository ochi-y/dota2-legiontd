LinkLuaModifier( "modifier_learn_fighter_ultimate_ability", "ability/learn_fighter_ultimate_ability.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if learn_fighter_ultimate_ability == nil then
	learn_fighter_ultimate_ability = class({})
end

function learn_fighter_ultimate_ability:Spawn()
	if not IsServer() then return end
	local caster=self:GetCaster()
	Timers:CreateTimer(FrameTime(),function ()
		self:updateState()
	end)
end

function learn_fighter_ultimate_ability:updateState()
	if not IsServer() then return end
	
	if self:IsNull() then
		return
	end

	local caster=self:GetCaster()
	local required_round=self:GetSpecialValueFor("required_round")
	local required_level=self:GetSpecialValueFor("required_level")
	
	-- print(1234, GamePlay.round,required_round)
	-- print(GamePlay.round<required_round , caster:GetLevel()<required_level)

	if FIGHTER_UPGRADE_ROUND_LIMIT then
		if GamePlay.round<GamePlay:getRoundByName(required_round) or caster:GetLevel()<required_level  then
			self:SetActivated(false)
		else
			self:SetActivated(true)
		end	
	end
	self:updateUltimateAbility()
	-- Timers:CreateTimer(FrameTime(),function ()
	-- 	self:MarkAbilityButtonDirty()	
	-- end)
end

function learn_fighter_ultimate_ability:OnAbilityPhaseStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local pid = caster:GetPlayerOwnerID()
	
	-- local gold=caster.gold
	-- local food=caster.food
	local gold=GetUnitKV(caster:GetUnitName(),"ultimateAbilityGoldCost",1) or 0
	if gold and gold>Player:GetGold(pid) then
		SendErrorMessage(pid, "error_need_gold",{gold})
		return false
	end
    return true
end

function learn_fighter_ultimate_ability:updateUltimateAbility()

	print("updateUltimateAbility")
	local caster=self:GetCaster()
	local meta=GamePlay:FighterGetMeta(caster.fighterId)
	local f=false
	if meta and meta.learnUltimateAbility then
		f=true
	end
	if not meta then
		f=true
	end
	local abilityCount = caster:GetAbilityCount() or 0
	for i = 0, abilityCount - 1 do
		local ab=caster:GetAbilityByIndex(i)
		if ab and GetAbilityKV(ab:GetAbilityName(),"isUltimateAbility")==1 then
			if f then
				ab:SetActivated(true)
			else
				ab:SetActivated(false)
			end
		end
	end
	if f then
		-- Timers:CreateTimer(FrameTime(),function ()
		-- 	caster:RemoveAbility("learn_fighter_ultimate_ability")
		-- end)
		caster:RemoveAbility("learn_fighter_ultimate_ability")
	end
end

function learn_fighter_ultimate_ability:learnAbility()
	local caster=self:GetCaster()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

	local meta=GamePlay:FighterGetMeta(caster.fighterId)
	if meta then
		meta.learnUltimateAbility=true
		meta.gold=caster.gold
	end
	-- caster:AddNewModifier(caster, nil, "modifier_upgrade_fighter_level", {})
	Player:UpdateCreepValue(caster:GetPlayerOwnerID())
	PlayUpgradeParticle(caster,{
		sound="HeroBadgeLevelUpReward.ShowReward",
		particle="particles/units/heroes/hero_chen/chen_divine_favor.vpcf"
	})
	self:updateUltimateAbility()
	Timers:CreateTimer(FrameTime(), function()
		FireGameEvent("dota_ability_changed", {
			entityIndex = caster:entindex()
		})
	end)

end
function learn_fighter_ultimate_ability:OnSpellStart()
	if not IsServer() then return end

	if not self:OnAbilityPhaseStart() then
		self:EndCooldown()
		return
	end

	local caster=self:GetCaster()

	if not caster.gold then
		caster.gold=0
	end

	local gold=GetUnitKV(caster:GetUnitName(),"ultimateAbilityGoldCost",1) or 0
    local pid = caster:GetPlayerOwnerID()

	if gold then
		caster.gold=caster.gold+gold
		Player:ModifyGold(pid,-gold)
	end
	self:learnAbility()
end

