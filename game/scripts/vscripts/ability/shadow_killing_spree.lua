LinkLuaModifier( "modifier_shadow_killing_spree", "ability/shadow_killing_spree.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_killing_spree_buff", "ability/shadow_killing_spree.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_killing_spree == nil then
	shadow_killing_spree = class({})
end
function shadow_killing_spree:GetIntrinsicModifierName()
	return "modifier_shadow_killing_spree"
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_killing_spree == nil then
	modifier_shadow_killing_spree = class({})
end
function modifier_shadow_killing_spree:IsHidden(params)
	return true
end
function modifier_shadow_killing_spree:IsPurgable(params)
	return false
end
function modifier_shadow_killing_spree:OnCreated(params)
	if IsServer() then
	end
end
function modifier_shadow_killing_spree:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_killing_spree:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_killing_spree:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH
	}
end
function modifier_shadow_killing_spree:OnDeath(params)
	if not IsServer() then return end
	if params.attacker == self:GetParent() then
		local caster=self:GetParent()
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_shadow_killing_spree_buff", {duration=4})
		local mod=caster:FindModifierByName("modifier_shadow_killing_spree_buff")
		if mod then
			mod:IncrementStackCount()
		end
	end
end
-- function modifier_shadow_killing_spree:OnAttackLanded(params)
-- 	if not IsServer() then return end
-- 	if params.attacker ~= self:GetParent() then return end
-- 	local caster=self:GetParent()
-- 	local target=params.target
-- 	if RandomInt(1, 100)<=30 and not caster:HasModifier("modifier_shadow_killing_spree_buff") then
-- 		caster:AddNewModifier(caster, self:GetAbility(), "modifier_shadow_killing_spree_buff", {duration=4})
-- 	end
-- end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_killing_spree_buff == nil then
	modifier_shadow_killing_spree_buff = class({
		GetEffectName           = function(self) return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf" end,
		GetEffectAttachType     = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
		GetStatusEffectName     = function(self) return "particles/status_fx/status_effect_bloodrage.vpcf" end,
		StatusEffectPriority    = function(self) return 8 end,
	})
end
function modifier_shadow_killing_spree_buff:OnCreated(params)
	if IsServer() then
		EmitSoundOn("hero_bloodseeker.bloodRage", self:GetParent())
	end
end
function modifier_shadow_killing_spree_buff:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_killing_spree_buff:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_killing_spree_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
end
function modifier_shadow_killing_spree_buff:GetModifierDamageOutgoing_Percentage()
	return 50*self:GetStackCount()
end

