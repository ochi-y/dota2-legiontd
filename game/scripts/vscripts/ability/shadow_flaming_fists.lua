LinkLuaModifier( "modifier_shadow_flaming_fists", "ability/shadow_flaming_fists.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_flaming_fists == nil then
	shadow_flaming_fists = class({})
end
function shadow_flaming_fists:GetIntrinsicModifierName()
	return "modifier_shadow_flaming_fists"
end
---------------------------------------------------------------------
--Modifiers
modifier_shadow_flaming_fists = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})
function modifier_shadow_flaming_fists:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.chance=ability:GetSpecialValueFor("chance")
	self.damage=ability:GetSpecialValueFor("damage")
	self.radius=ability:GetSpecialValueFor("radius")
	if IsServer() then
	end
end
function modifier_shadow_flaming_fists:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_shadow_flaming_fists:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_flaming_fists:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end
function modifier_shadow_flaming_fists:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end

	local chance=self.chance
	if RandomInt(1, 100) <= chance then
		local radius=self.radius

		local ability=self:GetAbility()
		local target = params.target
		local caster=self:GetParent()
		local damage=self.damage
		AoeDamage(ability,target:GetAbsOrigin(),radius,damage,{
			maxCount=15
		})
	end
end


