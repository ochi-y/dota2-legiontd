
LinkLuaModifier( "modifier_orc_corruption", "ability/orc_corruption.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_orc_corruption_debuff", "ability/orc_corruption.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if orc_corruption == nil then
	orc_corruption = class({})
end
function orc_corruption:GetIntrinsicModifierName()
	return "modifier_orc_corruption"
end
---------------------------------------------------------------------
--Modifiers
if modifier_orc_corruption == nil then
	modifier_orc_corruption = class({

	})
end
function modifier_orc_corruption:IsHidden()
	return true
end
function modifier_orc_corruption:IsPurgable(params)
	return false
end
function modifier_orc_corruption:OnCreated(params)
end
function modifier_orc_corruption:OnRefresh(params)
	if IsServer() then
	end
	self:OnCreated()
end

function modifier_orc_corruption:OnDestroy()
	if IsServer() then
	end
end

function modifier_orc_corruption:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_orc_corruption:GetModifierPreAttack_BonusDamage()
	return 0
end

function modifier_orc_corruption:OnAttackStart(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	local attacker =params.attacker
	EmitSoundOn("Item_Desolator.Target", attacker)
end

function modifier_orc_corruption:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	
	if target:IsMagicImmune() then
		return
	end

	local attacker =params.attacker
	local caster=attacker
	local ability=self:GetAbility()
	if params.attacker:PassivesDisabled() == false then
		target:AddNewModifier(caster, self:GetAbility(), "modifier_orc_corruption_debuff", {duration = 4})
	end
	
end

modifier_orc_corruption_debuff = class({
	IsPurgable = function() return true end,
	IsDebuff = function() return true end,
	IsStunDebuff = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	} end,
})

function modifier_orc_corruption_debuff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.armor_reduce=ability:GetSpecialValueFor("armor_reduce")
end

function modifier_orc_corruption_debuff:GetModifierPhysicalArmorBonus()
	return -self.armor_reduce
end