LinkLuaModifier("modifier_shadow_mindwarp", "ability/shadow_mindwarp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_mindwarp_tag", "ability/shadow_mindwarp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_mindwarp_buff", "ability/shadow_mindwarp", LUA_MODIFIER_MOTION_NONE)

shadow_mindwarp = {}

function shadow_mindwarp:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function shadow_mindwarp:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self.duration = self:GetSpecialValueFor("duration")


	if IsCustomBuilding(caster) then
		GamePlay:FighterSetAbilityTarget(caster.fighterId, self:GetAbilityName(), target.fighterId)
	end
	target:AddNewModifier(
		caster,
		self,
		"modifier_shadow_mindwarp_buff",
		{ duration = self.duration }
	)
	EmitSoundOn("hero_bloodseeker.bloodRage", target)
end

if modifier_shadow_mindwarp_buff == nil then
	modifier_shadow_mindwarp_buff = class({
		GetEffectName        = function(self) return "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf" end,
		GetEffectAttachType  = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
		GetStatusEffectName  = function(self) return "particles/status_fx/status_effect_bloodrage.vpcf" end,
		StatusEffectPriority = function(self) return 8 end,
	})
end
function modifier_shadow_mindwarp_buff:IsHidden()
	return false
end

function modifier_shadow_mindwarp_buff:IsDebuff()
	return false
end

function modifier_shadow_mindwarp_buff:IsPurgable()
	return true
end

function modifier_shadow_mindwarp_buff:OnCreated(kv)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.attack_speed_pct_bonus = ability:GetSpecialValueFor("attack_speed_pct_bonus")
	self.hp_lose = ability:GetSpecialValueFor("hp_lose")

	if not IsServer() then return end
	-- EmitSoundOn( "Hero_OgreMagi.Bloodlust.Target", self:GetParent() )
	-- EmitSoundOnClient( "Hero_OgreMagi.Bloodlust.Target.FP", self:GetParent():GetPlayerOwner() )
	self:StartIntervalThink(1)
end

modifier_shadow_mindwarp_buff.OnRefresh = modifier_shadow_mindwarp_buff.OnCreated

function modifier_shadow_mindwarp_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
end

function modifier_shadow_mindwarp_buff:OnIntervalThink()
	if not IsServer() then return end
	local damage = self.hp_lose * self:GetParent():GetMaxHealth()/100
	SimpleApplyDamage(self:GetAbility(), self:GetParent(), self:GetParent(), damage, DAMAGE_TYPE_PURE,DOTA_DAMAGE_FLAG_NON_LETHAL )
end

function modifier_shadow_mindwarp_buff:GetModifierMoveSpeedBonus_Percentage()
	return 0
end

function modifier_shadow_mindwarp_buff:GetModifierAttackSpeedPercentage()
	return self.attack_speed_pct_bonus
end

function modifier_shadow_mindwarp_buff:GetModifierModelScale()
	return 10
end

modifier_shadow_mindwarp_tag = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
