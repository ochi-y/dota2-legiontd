LinkLuaModifier( "modifier_orc_frenzy", "ability/orc_frenzy.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if orc_frenzy == nil then
	orc_frenzy = class({})
end
function orc_frenzy:OnSpellStart()
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()

	local duration=self:GetSpecialValueFor("duration")

	target:AddNewModifier(caster, self, "modifier_orc_frenzy", {duration=duration})
end
---------------------------------------------------------------------
--Modifiers
if modifier_orc_frenzy == nil then
	modifier_orc_frenzy = class({
		GetEffectName           = function(self) return "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf" end,
		GetEffectAttachType     = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
		GetStatusEffectName     = function(self) return "particles/status_fx/status_effect_bloodrage.vpcf" end,
		StatusEffectPriority    = function(self) return 8 end,
	})
end
function modifier_orc_frenzy:OnCreated(params)
	if not self:GetAbility() then return end

	local ability=self:GetAbility()
	self.bonus_attack_speed=ability:GetSpecialValueFor("bonus_attack_speed")
	self.hp_lose=ability:GetSpecialValueFor("hp_lose")

	if IsServer() then
		self:StartIntervalThink(1)
		EmitSoundOn("hero_bloodseeker.bloodRage", self:GetParent())
	end
end
function modifier_orc_frenzy:IsPurgable(params)
	return true
end
function modifier_orc_frenzy:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_orc_frenzy:OnDestroy()
	if IsServer() then
	end
end

function modifier_orc_frenzy:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
	}
end

function modifier_orc_frenzy:GetModifierAttackSpeedPercentage()
	return self.bonus_attack_speed
end

function modifier_orc_frenzy:OnIntervalThink( params )
	SimpleApplyDamage(self:GetAbility(), self:GetParent(), self:GetParent(), self.hp_lose)
end


