LinkLuaModifier("modifier_element_deluge", "ability/element_deluge.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
element_deluge = class({})
element_water_splash = element_deluge
---------------------------------------------------------------------
--Modifiers
function element_deluge:GetIntrinsicModifierName()
	return "modifier_element_deluge"
end

function element_deluge:OnProjectileHit_ExtraData(target, location, params)
	if not target then
		return
	end

	local caster = self:GetCaster()


	local mod = caster:FindModifierByName("modifier_element_deluge")
	local recordData = mod.bounceMap[params.record]
	local bounces = self:GetSpecialValueFor("bounces")
	--
	local reduction = self:GetSpecialValueFor("damage_reduction_percent")

	local f = (100 - reduction) / 100

	if recordData then
		local factor = SimpleGetAttackFactor(self:GetCaster(), target)
		local realDamage = recordData.damage * math.pow(f, #(recordData.units))

		EmitSoundOn("Hero_Morphling.projectileImpact", target)

		SimpleApplyDamage(self, self:GetCaster(), target, realDamage * factor, DAMAGE_TYPE_PHYSICAL)
		if #(recordData.units) < bounces then
			mod:doBounce(target, params.record)
		else
			mod.bounceMap[params.record] = nil
		end
	end
end

modifier_element_deluge = {}

function modifier_element_deluge:IsHidden()
	return true
end

function modifier_element_deluge:IsPurgable()
	return false
end

function modifier_element_deluge:OnCreated(kv)

	if self:GetAbility() then
		self.bounces = self:GetAbility():GetSpecialValueFor("bounces")
		self.range = self:GetAbility():GetSpecialValueFor("range")
		self.reduction = self:GetAbility():GetSpecialValueFor("damage_reduction_percent")
		self.bounceMap = {
		}
	end
end

modifier_element_deluge.OnRefresh = modifier_element_deluge.OnCreated

function modifier_element_deluge:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
end

function modifier_element_deluge:GetModifierProcAttack_Feedback(params)
	if not IsServer() then return end

	if self:GetParent():PassivesDisabled() then return end
	local caster = self:GetCaster()


	local record = params.record

	self.bounceMap[record] = {
		units = {},
		damage = params.damage
	}
	self:doBounce(params.target, record)

	-- SimpleTrackingProjectile(self:GetAbility(), caster, target, eff, speed,params)

	-- CreateModifierThinker(
	-- 	self:GetParent(),
	-- 	self:GetAbility(),
	-- 	"modifier_element_deluge_thinker",
	-- 	{},
	-- 	params.target:GetAbsOrigin(),
	-- 	self:GetParent():GetTeamNumber(),
	-- 	false
	-- )
end

function modifier_element_deluge:doBounce(source, record)
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
