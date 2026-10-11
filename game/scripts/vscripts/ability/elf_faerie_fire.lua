
LinkLuaModifier( "modifier_elf_faerie_fire", "ability/elf_faerie_fire.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_elf_faerie_fire_debuff", "ability/elf_faerie_fire.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if elf_faerie_fire == nil then
	elf_faerie_fire = class({})
end
function elf_faerie_fire:GetIntrinsicModifierName()
	return "modifier_elf_faerie_fire"
end
---------------------------------------------------------------------
--Modifiers
if modifier_elf_faerie_fire == nil then
	modifier_elf_faerie_fire = class({

	})
end

function modifier_elf_faerie_fire:IsPurgable(params)
	return false
end

function modifier_elf_faerie_fire:IsHidden()
	return true
end
function modifier_elf_faerie_fire:OnCreated(params)
	if not self:GetAbility() then return end
	self.armor_reduce = self:GetAbility():GetSpecialValueFor("armor_reduce")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
end
function modifier_elf_faerie_fire:OnRefresh(params)
	if IsServer() then
	end
	self:OnCreated()
end

function modifier_elf_faerie_fire:OnDestroy()
	if IsServer() then
	end
end

function modifier_elf_faerie_fire:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_elf_faerie_fire:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	
	local target = params.target
	local attacker =params.attacker
	local caster=attacker
	local ability=self:GetAbility()
	if params.attacker:PassivesDisabled() == false then
		target:AddNewModifier(caster, self:GetAbility(), "modifier_elf_faerie_fire_debuff", {duration = self.duration})
	end
	
end

modifier_elf_faerie_fire_debuff = class({
	IsPurgable = function() return true end,
	IsDebuff = function() return true end,
	IsStunDebuff = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	} end,
})

function modifier_elf_faerie_fire_debuff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.armor_reduce=ability:GetSpecialValueFor("armor_reduce")

end

function modifier_elf_faerie_fire_debuff:GetModifierPhysicalArmorBonus()
	return -self.armor_reduce
end


function modifier_elf_faerie_fire_debuff:GetEffectName()
	return "particles/units/heroes/hero_enchantress/enchantress_natures_attendants_count14.vpcf"
end

function modifier_elf_faerie_fire_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

