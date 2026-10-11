LinkLuaModifier( "modifier_goblin_overclocking", "ability/goblin_overclocking.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if goblin_overclocking == nil then
	goblin_overclocking = class({})
end
function goblin_overclocking:OnSpellStart()
	local caster=self:GetCaster()
	EmitSoundOn("Hero_Rattletrap.Overclock.Cast", caster)
	local buff_duration=self:GetSpecialValueFor("buff_duration")
	caster:AddNewModifier(caster, self, "modifier_goblin_overclocking", {duration=buff_duration})
end
---------------------------------------------------------------------
--Modifiers
if modifier_goblin_overclocking == nil then
	modifier_goblin_overclocking = class({})
end
function modifier_goblin_overclocking:IsPurgable(params)
	return false
end
function modifier_goblin_overclocking:OnCreated(params)
	if not self:GetAbility() then return end
	if IsServer() then
	end
	local ability=self:GetAbility()
	self.bonus_movement_speed=ability:GetSpecialValueFor("bonus_movement_speed")
	self.bonus_attack_speed=ability:GetSpecialValueFor("bonus_attack_speed")
	self.debuff_duration=ability:GetSpecialValueFor("debuff_duration")
end
function modifier_goblin_overclocking:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_goblin_overclocking:OnDestroy()
	
	if IsServer() then
		local parent=self:GetParent()
		parent:AddNewModifier(parent, self:GetAbility(), "modifier_stunned", {duration = self.debuff_duration})
		EmitSoundOn("Hero_Rattletrap.Overclock.Stun", parent)
	end
	
end
function modifier_goblin_overclocking:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_goblin_overclocking:GetEffectName()
	return "particles/units/heroes/hero_rattletrap/clock_overclock_buff.vpcf"
end
function modifier_goblin_overclocking:GetEffectAttachType()
	return PATTACH_ROOTBONE_FOLLOW
end

function modifier_goblin_overclocking:GetModifierAttackSpeedPercentage( params )
	return self.bonus_attack_speed
end 
function modifier_goblin_overclocking:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movement_speed
end


