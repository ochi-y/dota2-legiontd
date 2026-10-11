
LinkLuaModifier( "modifier_ghost_violate", "ability/ghost_violate.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ghost_violate_debuff", "ability/ghost_violate.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ghost_violate == nil then
	ghost_violate = class({})
end
function ghost_violate:GetIntrinsicModifierName()
	return "modifier_ghost_violate"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ghost_violate == nil then
	modifier_ghost_violate = class({

	})
end
function modifier_ghost_violate:IsHidden()
	return true
end
function modifier_ghost_violate:IsPurgable(params)
	return false
end
function modifier_ghost_violate:OnCreated(params)

	local ability=self:GetAbility()

	if not ability then
        return
    end   

	
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
end
function modifier_ghost_violate:OnRefresh(params)
	if IsServer() then
	end
	self:OnCreated()
end

function modifier_ghost_violate:OnDestroy()
	if IsServer() then
	end
end

function modifier_ghost_violate:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_ghost_violate:GetModifierPreAttack_BonusDamage()
	return 0
end

function modifier_ghost_violate:OnAttackStart(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	local attacker =params.attacker
	-- EmitSoundOn("Item_Desolator.Target", attacker)
end

function modifier_ghost_violate:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	local attacker =params.attacker
	local caster=attacker
	local ability=self:GetAbility()
	if params.attacker:PassivesDisabled() == false then
		target:AddNewModifier(caster, self:GetAbility(), "modifier_ghost_violate_debuff", {duration = self.duration})
		-- EmitSoundOn("Item_Desolator.Target", target)
	end
end

modifier_ghost_violate_debuff = class({
	IsPurgable = function() return true end,
	IsDebuff = function() return true end,
	IsStunDebuff = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	} end,
})

function modifier_ghost_violate_debuff:OnCreated()
	if not self:GetAbility() then return end
	local parent = self:GetParent()

	local ability=self:GetAbility()
	self.armor_reduce=ability:GetSpecialValueFor("armor_reduce")
end

function modifier_ghost_violate_debuff:GetModifierPhysicalArmorBonus()
	return -self.armor_reduce
end