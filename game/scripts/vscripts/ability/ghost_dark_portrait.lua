LinkLuaModifier("modifier_ghost_dark_portrait", "ability/ghost_dark_portrait.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ghost_dark_portrait_buff", "ability/ghost_dark_portrait.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if ghost_dark_portrait == nil then
	ghost_dark_portrait = class({})
end

function ghost_dark_portrait:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	local illusion_duration = self:GetSpecialValueFor("illusion_duration")
	-- local images_do_damage_percent = self:GetSpecialValueFor("images_do_damage_percent")
	-- local images_take_damage_percent = self:GetSpecialValueFor("images_take_damage_percent")
	-- local boss_damage_pct = self:GetSpecialValueFor("boss_damage_pct")

	-- if target:IsAncient() then
	-- 	images_do_damage_percent = boss_damage_pct-100
	-- end
	local illusion_creep_value = self:GetSpecialValueFor("illusion_creep_value")


	local unitCreepValue = GamePlay:GetUnitCreepValue(target)

	if unitCreepValue == nil or unitCreepValue == 0 then
		return
	end

	local creepValuePct = math.ceil(100 * illusion_creep_value / unitCreepValue)
	local images_do_damage_percent = creepValuePct - 100
	local images_take_damage_percent = math.ceil(100 * unitCreepValue / illusion_creep_value) - 100

	-- print(123,illusion_creep_value,unitCreepValue,images_do_damage_percent,images_take_damage_percent)

	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)
	--
	EmitSoundOn("General.Illusion.Create", target)
	--
	local spawnPos = target:GetAbsOrigin() + target:GetForwardVector() * 200

	local illusion = target:CreateIllusion(caster, self, illusion_duration, spawnPos, images_do_damage_percent,
		images_take_damage_percent, false, 1, {
			useLuaIllusionMod = true
		})
	-- 
	illusion:ModifyHealth(target:GetMaxHealth(), self, false,
		DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT + DOTA_DAMAGE_FLAG_HPLOSS)
	--
	if illusion then
		-- illusion:RemoveAbility(self:GetAbility():GetAbilityName())
		-- GamePlay:removeBuildingAbility(illusion)

		PlayEffOnUnit("particles/generic_gameplay/illusion_created_b.vpcf", illusion)
		-- illusion:AddNewModifier(hero, nil, "modifier_phased", {
		--     duration = 0.1
		-- })
		SimpleMoveUnit(illusion, spawnPos)
		illusion:AddNewModifier(hero, nil, "modifier_ghost_dark_portrait_buff", {

		})

		illusion:SetForwardVector(-target:GetForwardVector())
		if caster:GetLevel() - illusion:GetLevel() > 0 then
			illusion:CreatureLevelUp(caster:GetLevel() - illusion:GetLevel())
		end
	end
	-- add to creep list
	local pdata = Player:GetPData(pid)
	if illusion and pdata then
		table.insert(pdata.creeps, illusion)
	end

	local newUnit = illusion
	if newUnit then
		newUnit.wayStep = caster.wayStep
		newUnit.waypoints = TableCopy(caster.waypoints)
	end
end

-------------------------------------------------------------------------------------------------------
modifier_ghost_dark_portrait_buff = class({
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
function modifier_ghost_dark_portrait_buff:AllowIllusionDuplicate()
	return false
end

function modifier_ghost_dark_portrait_buff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_ghost_dark_portrait_buff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ghost_dark_portrait_buff:DeclareFunctions()
	return {

	}
end

function modifier_ghost_dark_portrait_buff:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
	return state
end

function modifier_ghost_dark_portrait_buff:GetEffectName()
	return "particles/units/heroes/hero_marci/marci_rebound_bounce_impact_debuff.vpcf"
end

function modifier_ghost_dark_portrait_buff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_ghost_dark_portrait_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_grimstroke_ink_swell.vpcf"
end

function modifier_ghost_dark_portrait_buff:StatusEffectPriority()
	return 10
end
