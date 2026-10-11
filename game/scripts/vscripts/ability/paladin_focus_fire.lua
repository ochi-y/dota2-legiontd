--------------------------------------------------------------------------------
paladin_focus_fire = class({})
LinkLuaModifier("modifier_paladin_focus_fire", "ability/paladin_focus_fire",
	LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Ability Start
function paladin_focus_fire:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	-- cancel if linken
	if target:TriggerSpellAbsorb(self) then return end
	-- load data
	local duration = self:GetSpecialValueFor("duration")

	if target:IsAncient() then
		duration = self:GetSpecialValueFor("boss_duration")	
	end
	


	-- this version of Focus Fire allows multiple target
	-- check existing modifiers
	local found = false
	local modifiers = caster:FindAllModifiersByName("modifier_paladin_focus_fire")
	for _, modifier in pairs(modifiers) do
		if modifier.target == target then
			-- if already exist for current target, refresh
			modifier:ForceRefresh()
			found = true
			break
		end
	end

	if not found then
		-- get entindex
		local ent = target:entindex()

		-- add modifier to new targets
		caster:AddNewModifier(
			caster,               -- player source
			self,                 -- ability source
			"modifier_paladin_focus_fire", -- modifier name
			{
				duration = duration,
				target = ent,
			} -- kv
		)
	end


	ExecuteOrderFromTable({
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()
	})
	-- Play effects
	local sound_cast = "Ability.Focusfire"
	EmitSoundOn(sound_cast, caster)
end

--------------------------------------------------------------------------------
modifier_paladin_focus_fire = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_paladin_focus_fire:IsHidden()
	return false
end

function modifier_paladin_focus_fire:IsDebuff()
	return false
end

function modifier_paladin_focus_fire:IsPurgable()
	return false
end

function modifier_paladin_focus_fire:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_paladin_focus_fire:OnCreated(kv)
	if not self:GetAbility() then return end
	-- references
	self.bonus = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.reduction = self:GetAbility():GetSpecialValueFor("focusfire_damage_reduction")

	if not IsServer() then return end


	self.target = EntIndexToHScript(kv.target)

	-- self:StartIntervalThink(0.05)
	-- self:OnIntervalThink()
end

function modifier_paladin_focus_fire:OnRefresh(kv)
	if not self:GetAbility() then return end
	-- references
	self.bonus = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.reduction = self:GetAbility():GetSpecialValueFor("focusfire_damage_reduction")
	if not IsServer() then return end
end

function modifier_paladin_focus_fire:OnRemoved()
end

function modifier_paladin_focus_fire:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_paladin_focus_fire:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE ,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,

		MODIFIER_EVENT_ON_ORDER,

		MODIFIER_PROPERTY_PROJECTILE_NAME
	}

	return funcs
end

function modifier_paladin_focus_fire:GetModifierAttackSpeedPercentage()
	if not IsServer() then
		return self.bonus
	end
	local aggro = self:GetParent():GetAggroTarget()
	if aggro and aggro ~= self.target then return end

	return self.bonus
end

function modifier_paladin_focus_fire:GetModifierDamageOutgoing_Percentage()
	if not IsServer() then
		return self.reduction
	end
	local aggro = self:GetParent():GetAggroTarget()
	if aggro and aggro ~= self.target then return end

	return self.reduction
end

function modifier_paladin_focus_fire:OnOrder(params)
	if not IsServer() then return end
	if params.unit ~= self:GetParent() then return end

	-- if ordered to attack target, move to target instead
	if params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET and params.target == self.target then
		-- chase instead
		self.follow = true
	else
		self.follow = false
	end

	-- specific order to stop autoattack
	if params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET and params.target ~= self.target then
		self.attacking = false
	elseif params.order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
		self.attacking = false
	elseif params.order_type == DOTA_UNIT_ORDER_CONTINUE then
		self.attacking = false
	elseif params.order_type == DOTA_UNIT_ORDER_STOP then
		self.attacking = false
	elseif params.order_type == DOTA_UNIT_ORDER_MOVE_TO_DIRECTION then
		self.attacking = false
		-- other order resumes attack
	else
		self.attacking = true
	end

	if not self.attacking then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_paladin_focus_fire:OnIntervalThink()
	if self.target:IsNull() then
		-- if dead and not respawn, just stop
		self:StartIntervalThink(-1)
		return
	end

	-- check target within range
	local distance = (self.target:GetOrigin() - self:GetParent():GetOrigin()):Length2D()
	local range = self:GetParent():Script_GetAttackRange()

	self.inRange = distance <= range

	if self.inRange and self.attacking and self.target:IsAlive() then
		if self.follow then
			-- TODO: not immediately follow target
			self:GetParent():MoveToNPC(self.target)
		end

		-- bombard target, but respect attack speed cooldown
		self:GetParent():PerformAttack(
			self.target,
			true,
			true,
			false,
			false,
			true,
			false,
			false
		)
	end
end

function modifier_paladin_focus_fire:GetModifierProjectileName()
	return "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_focusfire_attack.vpcf"
end

-- function modifier_paladin_focus_fire:GetEffectName()
-- 	return "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_focusfire.vpcf"
-- end
-- function modifier_paladin_focus_fire:GetEffectAttachType()
-- 	return PATTACH_POINT_FOLLOW
-- end
