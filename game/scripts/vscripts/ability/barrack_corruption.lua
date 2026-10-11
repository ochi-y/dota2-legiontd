
LinkLuaModifier( "modifier_barrack_corruption", "ability/barrack_corruption.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_barrack_corruption_debuff", "ability/barrack_corruption.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if barrack_corruption == nil then
	barrack_corruption = class({})
end
function barrack_corruption:GetIntrinsicModifierName()
	return "modifier_barrack_corruption"
end
---------------------------------------------------------------------
--Modifiers
if modifier_barrack_corruption == nil then
	modifier_barrack_corruption = class({

	})
end
function modifier_barrack_corruption:IsPurgable(params)
	return false
end
function modifier_barrack_corruption:IsHidden()
	return true
end
function modifier_barrack_corruption:OnCreated(params)
	if not self:GetAbility() then return end
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	self.attack = self:GetAbility():GetSpecialValueFor("attack")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
end
function modifier_barrack_corruption:OnRefresh(params)
	if IsServer() then
	end
	self:OnCreated()
end

function modifier_barrack_corruption:OnDestroy()
	if IsServer() then
	end
end

function modifier_barrack_corruption:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_barrack_corruption:GetModifierPreAttack_BonusDamage()
	return self.attack
end

function modifier_barrack_corruption:OnAttack(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	local attacker =params.attacker
	EmitSoundOn("Item_Desolator.Target", attacker)
end

function modifier_barrack_corruption:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	local attacker =params.attacker
	local caster=attacker
	local ability=self:GetAbility()
	if params.attacker:PassivesDisabled() == false then
		target:AddNewModifier(caster, self:GetAbility(), "modifier_barrack_corruption_debuff", {duration = self.duration})
	end
	
end

modifier_barrack_corruption_debuff = class({
	IsPurgable = function() return true end,
	IsDebuff = function() return true end,
	IsStunDebuff = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	} end,
})

function modifier_barrack_corruption_debuff:OnCreated()
	if not self:GetAbility() then return end
	local parent = self:GetParent()
	self.armor = self:GetAbility():GetSpecialValueFor("armor")

	if IsServer() then
		-- local particle = "particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf"
		-- local fx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, parent)

		-- ParticleManager:SetParticleControlEnt(fx, 0, parent, PATTACH_OVERHEAD_FOLLOW, nil, parent:GetOrigin(), true)
		-- ParticleManager:SetParticleControlEnt( fx, 1, parent, PATTACH_OVERHEAD_FOLLOW, nil, parent:GetOrigin(), true)
		-- ParticleManager:SetParticleControlEnt( fx, 2, parent, PATTACH_OVERHEAD_FOLLOW, nil, parent:GetOrigin(), true)
		-- self:AddParticle(fx, false, false, -1, false, true)
	end
end

function modifier_barrack_corruption_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end