LinkLuaModifier( "modifier_beast_fervor", "ability/beast_fervor.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if beast_fervor == nil then
	beast_fervor = class({})
end
function beast_fervor:GetIntrinsicModifierName()
	return "modifier_beast_fervor"
end
---------------------------------------------------------------------
--Modifiers
modifier_beast_fervor = class({})

--------------------------------------------------------------------------------
-- Initializations

function modifier_beast_fervor:IsHidden( kv )
	return false
end

function modifier_beast_fervor:IsDebuff( kv )
	return false
end

function modifier_beast_fervor:IsPurgable( kv )
	return false
end

function modifier_beast_fervor:RemoveOnDeath( kv )
	return false
end

--------------------------------------------------------------------------------
-- Life cycle

function modifier_beast_fervor:OnCreated( kv )
	if not self:GetAbility() then return end
	self:SetStackCount(1)
	self.stack_multiplier = self:GetAbility():GetSpecialValueFor("attack_speed")
	self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.currentTarget = {}
end

function modifier_beast_fervor:OnRefresh( kv )
	if not self:GetAbility() then return end
	self.stack_multiplier = self:GetAbility():GetSpecialValueFor("attack_speed")
	self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
end

--------------------------------------------------------------------------------
-- Declare functions

function modifier_beast_fervor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK
	}

	return funcs
end

--------------------------------------------------------------------------------
-- Declared functions

function modifier_beast_fervor:OnAttack( params )
	if IsServer() then
		-- filter
		pass = false
		if params.attacker==self:GetParent() then
			pass = true
		end

		-- logic
		if pass then
			-- check if it is the same target
			if self.currentTarget==params.target then
				self:AddStack()
			else
				self:ResetStack()
				self.currentTarget = params.target
			end
		end
	end
end

function modifier_beast_fervor:GetModifierAttackSpeedPercentage( params )
	local passive = 1
	if self:GetParent():PassivesDisabled() then
		passive = 0
	end
	return self:GetStackCount() * self.stack_multiplier * passive
end

--------------------------------------------------------------------------------
-- Helper functions

function modifier_beast_fervor:AddStack()
	-- check if it is not maximum
	if not self:GetParent():PassivesDisabled() then
		if self:GetStackCount() < self.max_stacks then
			self:IncrementStackCount()
		end
	end
end

function modifier_beast_fervor:ResetStack()
	if not self:GetParent():PassivesDisabled() then
		self:SetStackCount(1)
	end
end
