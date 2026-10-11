LinkLuaModifier("modifier_beast_envenomed_weapon", "ability/beast_envenomed_weapon.lua",
	LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_beast_envenomed_weapon_debuff", "ability/beast_envenomed_weapon.lua",
	LUA_MODIFIER_MOTION_NONE)
-- Abilities
if beast_envenomed_weapon == nil then
	beast_envenomed_weapon = class({})
end
function beast_envenomed_weapon:GetIntrinsicModifierName()
	return "modifier_beast_envenomed_weapon"
end

---------------------------------------------------------------------
-- Modifiers
modifier_beast_envenomed_weapon = class({
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
function modifier_beast_envenomed_weapon:OnCreated(params)
	local ability = self:GetAbility()
	if not ability then
		return
	end
	self.duration = ability:GetSpecialValueFor("duration")
	if IsServer() then
	end
end

function modifier_beast_envenomed_weapon:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_beast_envenomed_weapon:OnDestroy()
	if IsServer() then
	end
end

function modifier_beast_envenomed_weapon:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_beast_envenomed_weapon:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	--EmitSoundOn("Hero_Dazzle.Poison_Touch", target)

	if target:IsMagicImmune() then
		return
	end

	-- SimplePlayEffOnUnit(target,"particles/units/heroes/hero_beastmaster/beastmaster_boar_attack_explosion.vpcf")
	local duration = self.duration
	duration = duration * (1 - CalUnitStatusResistance(target))

	target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_beast_envenomed_weapon_debuff",
		{ duration = duration })
end

--
--
modifier_beast_envenomed_weapon_debuff = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return true
	end,
	IsDebuff = function(self)
		return true
	end,
	IsBuff = function(self)
		return false
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_beast_envenomed_weapon_debuff:OnCreated(params)
	if not self:GetAbility() then return end

	self.parent = self:GetParent()
	self.caster = self:GetCaster()
	-- references
	-- precache damage

	local ability = self:GetAbility()
	self.damage = ability:GetSpecialValueFor("damage")
	self.regen_reduction = ability:GetSpecialValueFor("regen_reduction")

	if not IsServer() then return end

	if self.damage > 0 then
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
		}
		self:StartIntervalThink(1)
		-- would be lethal in the same frame
		Timers:CreateTimer(FrameTime(), function()
			if IsActiveUnit(self.parent) then
				self:OnIntervalThink()
			end
		end)
	end
end

function modifier_beast_envenomed_weapon_debuff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_beast_envenomed_weapon_debuff:OnDestroy()
	if IsServer() then
	end
end

function modifier_beast_envenomed_weapon_debuff:DeclareFunctions()
	return {
		-- MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		-- MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE

		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE
	}
end

function modifier_beast_envenomed_weapon_debuff:GetModifierHealAmplify_PercentageTarget(params)
	return -1 * self.regen_reduction
end

function modifier_beast_envenomed_weapon_debuff:GetModifierSpellLifestealRegenAmplify_Percentage(params)
	return -1 * self.regen_reduction
end

function modifier_beast_envenomed_weapon_debuff:GetModifierHPRegenAmplify_Percentage(params)
	return -1 * self.regen_reduction
end

function modifier_beast_envenomed_weapon_debuff:GetModifierLifestealRegenAmplify_Percentage(params)
	return -1 * self.regen_reduction
end

function modifier_beast_envenomed_weapon_debuff:OnIntervalThink()
	if not IsServer() then return end

	ApplyDamage(self.damageTable)
	-- overhead damage info
	SendOverheadEventMessage(
		nil,
		OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,
		self.parent,
		self.damageTable.damage,
		nil
	)
end
