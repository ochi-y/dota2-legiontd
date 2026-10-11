
LinkLuaModifier( "modifier_nature_mark_target", "ability/nature_mark_target.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nature_mark_target_debuff", "ability/nature_mark_target.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_mark_target == nil then
	nature_mark_target = class({})
end
function nature_mark_target:GetIntrinsicModifierName()
	return "modifier_nature_mark_target"
end
---------------------------------------------------------------------
--Modifiers
if modifier_nature_mark_target == nil then
	modifier_nature_mark_target = class({

	})
end
function modifier_nature_mark_target:IsHidden()
	return true
end
function modifier_nature_mark_target:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.duration=ability:GetSpecialValueFor("duration")
	
	if IsServer() then
	end
end
function modifier_nature_mark_target:IsPurgable(params)
	return false
end
function modifier_nature_mark_target:OnRefresh(params)
	if IsServer() then
	end
	self:OnCreated()
end

function modifier_nature_mark_target:OnDestroy()
	if IsServer() then
	end
end

function modifier_nature_mark_target:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK
	}
end

function modifier_nature_mark_target:OnAttack(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	local attacker =params.attacker
	local caster=attacker
	local ability=self:GetAbility()
	if params.attacker:PassivesDisabled() == false then
		target:AddNewModifier(caster, self:GetAbility(), "modifier_nature_mark_target_debuff", {duration = self.duration})
	end
	
end

modifier_nature_mark_target_debuff = class({
	IsPurgable = function() return true end,
	IsDebuff = function() return true end,
	IsStunDebuff = function() return false end,
	DeclareFunctions = function() return {
	} end,
})

function modifier_nature_mark_target_debuff:OnCreated()
	
end

function modifier_nature_mark_target_debuff:GetEffectName()
	return "particles/units/heroes/hero_enchantress/enchantress_natures_attendants_count14.vpcf"
end

function modifier_nature_mark_target_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


