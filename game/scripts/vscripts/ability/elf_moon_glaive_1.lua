LinkLuaModifier("modifier_elf_moon_glaive_1", "ability/elf_moon_glaive_1.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
elf_moon_glaive_1 = class({})
paladin_storm_hammer = elf_moon_glaive_1
elf_moon_glaive_2=elf_moon_glaive_1

---------------------------------------------------------------------
--Modifiers
function elf_moon_glaive_1:GetIntrinsicModifierName()
	return "modifier_elf_moon_glaive_1"
end



function elf_moon_glaive_1:OnProjectileHit_ExtraData(target, location, params)
	if not target then
		return
	end

	local caster = self:GetCaster()


	local mod = caster:FindModifierByName("modifier_elf_moon_glaive_1")
	local recordData = mod.bounceMap[params.record]
	local bounces = self:GetSpecialValueFor("bounces")
	--
	local reduction = self:GetSpecialValueFor("damage_reduction_percent")

	local sound= GetAbilityKV(self:GetAbilityName(), "AttackImpactSound") or "Hero_Luna.MoonGlaive.Impact"

	local f = (100 - reduction) / 100

	if recordData then
		local factor = SimpleGetAttackFactor(self:GetCaster(), target)
		local realDamage = recordData.damage * math.pow(f, #(recordData.units))

		EmitSoundOn(sound, target)

		SimpleApplyDamage(self, self:GetCaster(), target, realDamage * factor, DAMAGE_TYPE_PHYSICAL)
		if #(recordData.units) < bounces then
			mod:doBounce(target, params.record)
		else
			mod.bounceMap[params.record] = nil
		end
	end
end

modifier_elf_moon_glaive_1 = {}

function modifier_elf_moon_glaive_1:IsHidden()
	return true
end

function modifier_elf_moon_glaive_1:IsPurgable()
	return false
end

function modifier_elf_moon_glaive_1:OnCreated(kv)
	if not self:GetAbility() then return end
	self.bounces = self:GetAbility():GetSpecialValueFor("bounces")
	self.range = self:GetAbility():GetSpecialValueFor("range")
	self.reduction = self:GetAbility():GetSpecialValueFor("damage_reduction_percent")


	self.bounceMap = {

	}
end

modifier_elf_moon_glaive_1.OnRefresh = modifier_elf_moon_glaive_1.OnCreated

function modifier_elf_moon_glaive_1:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
end

function modifier_elf_moon_glaive_1:GetModifierProcAttack_Feedback(params)
	if not IsServer() then return end

	if self:GetParent():PassivesDisabled() then return end
	local caster = self:GetCaster()


	local record = params.record

	self.bounceMap[record] = {
		units = {},
		damage = params.damage
	}
	self:doBounce(params.target, record)
	
end

function modifier_elf_moon_glaive_1:doBounce(source, record)
	if not IsServer() then return end
	local caster = self:GetCaster()

	local units = FindUnitsInRadius(
		caster:GetTeamNumber(),
		source:GetAbsOrigin(),
		nil,
		self.range,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_CLOSEST,
		false
	)
	if #units == 1 then
		return
	end

	local recordData = self.bounceMap[record]

	table.insert(recordData.units, source)

	local unitList1 = {}
	local unitList2 = {}

	for index, unit in ipairs(units) do
		if unit ~= source then
			if TableContainsValue(recordData.units, unit) then
				table.insert(unitList2, unit)
			else
				table.insert(unitList1, unit)
			end
		end
	end

	local target = nil

	if unitList1[1] then
		target = unitList1[1]
	elseif #unitList2 > 0 then
		target = unitList2[RandomInt(1, #unitList2)]
	end


	if target then
		SimpleTrackingProjectile(self:GetAbility(), source, target, caster:GetRangedProjectileName(),
			caster:GetProjectileSpeed(), {
				ExtraData = {
					record = record
				},
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
			})
	end
end
