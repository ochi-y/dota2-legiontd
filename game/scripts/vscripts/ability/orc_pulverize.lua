LinkLuaModifier( "modifier_orc_pulverize", "ability/orc_pulverize.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if orc_pulverize == nil then
	orc_pulverize = class({})
end
function orc_pulverize:GetIntrinsicModifierName()
	return "modifier_orc_pulverize"
end
---------------------------------------------------------------------
--Modifiers
modifier_orc_pulverize = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})
function modifier_orc_pulverize:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.chance=ability:GetSpecialValueFor("chance")
	self.damage=ability:GetSpecialValueFor("damage")
	self.radius=ability:GetSpecialValueFor("radius")


	if IsServer() then
	end
end
function modifier_orc_pulverize:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_orc_pulverize:OnDestroy()
	if IsServer() then
	end
end
function modifier_orc_pulverize:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end
function modifier_orc_pulverize:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end


	local chance=self.chance


	if RandomInt(1, 100) <= chance then
		local radius=self.radius

		local ability=self:GetAbility()
		local target = params.target
		local caster=self:GetParent()
		EmitSoundOn("Hero_PrimalBeast.Pulverize.Impact", caster)
		
		local damage=self.damage

		-- circleCleaveAttack( caster,target,target:GetAbsOrigin(),radius,self.damage,ability,{groundOnly=true})
		
		SimplePlayEffAtlocation("particles/units/heroes/hero_primal_beast/primal_beast_trample.vpcf",
            caster:GetAbsOrigin(), {0}, {
                [1] = Vector(radius, radius, radius)
            })

		local units=FindAbilityTarget(ability,caster:GetAbsOrigin(),ability:GetSpecialValueFor("radius"),{})
		for key, unit in pairs(units) do
			if not unit:HasFlyMovementCapability() then
				SimpleApplyDamage(self:GetAbility(), caster, unit, damage)
			end
		end

	end
end


