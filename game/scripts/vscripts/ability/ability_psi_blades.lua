LinkLuaModifier("modifier_ability_psi_blades", "ability/ability_psi_blades.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if ability_psi_blades == nil then
	ability_psi_blades = class({})
end
function ability_psi_blades:GetIntrinsicModifierName()
	return "modifier_ability_psi_blades"
end

-------------------------------------------------------------------------------------------------------
modifier_ability_psi_blades = class({
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

function modifier_ability_psi_blades:AllowIllusionDuplicate()
	return false
end

function modifier_ability_psi_blades:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.bonus_attack_range = ability:GetSpecialValueFor("bonus_attack_range")
	self.attack_spill_range = ability:GetSpecialValueFor("attack_spill_range")
	self.attack_spill_width = ability:GetSpecialValueFor("attack_spill_width")
	self.attack_spill_pct = ability:GetSpecialValueFor("attack_spill_pct")
	self.attack_spill_penalty = ability:GetSpecialValueFor("attack_spill_penalty")


	-- self.attack_spill_penalty=20

	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_ability_psi_blades:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ability_psi_blades:GetModifierAttackRangeBonus(params)
	return self.bonus_attack_range
end

function modifier_ability_psi_blades:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_ability_psi_blades:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target


	local caster = self:GetCaster()

	local dir = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()

	local startPos = target:GetAbsOrigin()
	local endPos = startPos + dir * self.attack_spill_range

	local units = FindUnitsInLine(caster:GetTeamNumber(), startPos, endPos, nil
	, self.attack_spill_width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE)

	ArrayRemoveValue(units, target)
	table.sort(units, function(a, b)
		local dis1 = Distance(target, a)
		local dis2 = Distance(target, b)
		return dis1 < dis2
	end)
	for index, unit in ipairs(units) do
		PlayEffOnUnit("particles/econ/items/templar_assassin/templar_assassin_focal/ta_focal_psi_blade.vpcf", target, {
			cpUnit = {
				[1] = { unit, PATTACH_POINT_FOLLOW, "attach_hitloc" }
			},
			attach = "attach_hitloc",
			bind = PATTACH_POINT_FOLLOW
		})
		local damage=params.damage *(self.attack_spill_pct/100)  * math.pow((100-self.attack_spill_penalty)/100.0,index)
		SimpleApplyDamage(self:GetAbility(), caster, unit, damage)
	end
end
