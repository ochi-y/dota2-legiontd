LinkLuaModifier( "modifier_shadow_blood_thirst", "ability/shadow_blood_thirst.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_blood_thirst_buff", "ability/shadow_blood_thirst.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_blood_thirst == nil then
	shadow_blood_thirst = class({})
end
function shadow_blood_thirst:GetIntrinsicModifierName()
	return "modifier_shadow_blood_thirst"
end
---------------------------------------------------------------------
--Modifiers

modifier_shadow_blood_thirst = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_shadow_blood_thirst:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.life_steal=ability:GetSpecialValueFor("life_steal")
	self.radius=ability:GetSpecialValueFor("radius")

	
	if IsServer() then
	end
end
function modifier_shadow_blood_thirst:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_blood_thirst:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_blood_thirst:DeclareFunctions()
	return {
	}
end
function modifier_shadow_blood_thirst:IsAura()
	return true
end
function modifier_shadow_blood_thirst:GetModifierAura()
	return "modifier_shadow_blood_thirst_buff"
end
function modifier_shadow_blood_thirst:GetAuraRadius()
	local radius=self.radius
	return radius
end

function modifier_shadow_blood_thirst:GetAuraDuration()
	return 0
end

function modifier_shadow_blood_thirst:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_shadow_blood_thirst:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_shadow_blood_thirst:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_shadow_blood_thirst:GetAuraEntityReject( hEntity )
	if not hEntity then return true end
	return hEntity:GetAttackCapability()==DOTA_UNIT_CAP_RANGED_ATTACK
end
--
modifier_shadow_blood_thirst_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_shadow_blood_thirst_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.life_steal=ability:GetSpecialValueFor("life_steal")
	self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_shadow_blood_thirst_buff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end
function modifier_shadow_blood_thirst_buff:OnTakeDamage( params )
	if IsServer() then

		local parent = self:GetParent()

		if params.attacker == parent and params.damage_category==DOTA_DAMAGE_CATEGORY_ATTACK then
			local heal = math.floor(params.damage * self.life_steal/100)

			parent:HealWithParams(heal, self, true, true, parent, false)

			-- show the heal number
			PopupHealing(parent, heal)

			local effect_lifesteal = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControl(effect_lifesteal, 0, parent:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(effect_lifesteal)
		end
	end
end




