ability_melting_strike = class({})
LinkLuaModifier( "modifier_forged_spirit_melting_strike","ability/ability_melting_strike", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_forged_spirit_melting_strike_effect","ability/ability_melting_strike", LUA_MODIFIER_MOTION_NONE )

wave_8_champion_melting_strike=ability_melting_strike
elf_melting_strike=ability_melting_strike
--------------------------------------------------------------------------------

function ability_melting_strike:GetIntrinsicModifierName()
	return "modifier_forged_spirit_melting_strike"
end

--------------------------------------------------------------------------------
modifier_forged_spirit_melting_strike = class({})
--------------------------------------------------------------------------------

function modifier_forged_spirit_melting_strike:IsHidden()
	return true
end

-- turn auto cast on when the ability is created
function modifier_forged_spirit_melting_strike:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.max_armor_removed=ability:GetSpecialValueFor("max_armor_removed")
end
function modifier_forged_spirit_melting_strike:OnRefresh()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.max_armor_removed=ability:GetSpecialValueFor("max_armor_removed")
end


function modifier_forged_spirit_melting_strike:DeclareFunctions()
	local funcs =
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end


function modifier_forged_spirit_melting_strike:OnAttackLanded(params)
	if IsServer() then
		-- when the ability is toggled on
		if self:GetParent() == params.attacker then
			-- spend mana
			local hTarget = params.target
			if hTarget ~= nil then
				local nDuration = self:GetAbility():GetSpecialValueFor( "duration" )
				local hDebuff = hTarget:FindModifierByName( "modifier_forged_spirit_melting_strike_effect" )
				if hDebuff == nil then
					hDebuff = hTarget:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_forged_spirit_melting_strike_effect", { duration = nDuration } )
					if hDebuff ~= nil then
						hDebuff:SetStackCount( 0 )
					end	
				end
				if hDebuff ~= nil then
					if hDebuff:GetStackCount()<self.max_armor_removed then
						hDebuff:SetStackCount( hDebuff:GetStackCount() + 1 )  
					end
					hDebuff:SetDuration( nDuration, true )
				end		
			end
		end
	end
	return 0 
end


modifier_forged_spirit_melting_strike_effect = class({})
--------------------------------------------------------------------------------
function modifier_forged_spirit_melting_strike_effect:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.max_armor_removed=ability:GetSpecialValueFor("max_armor_removed")
	self.armor_removed=ability:GetSpecialValueFor("armor_removed")
end
function modifier_forged_spirit_melting_strike_effect:OnRefresh()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.max_armor_removed=ability:GetSpecialValueFor("max_armor_removed")
	self.armor_removed=ability:GetSpecialValueFor("armor_removed")
end
function modifier_forged_spirit_melting_strike_effect:IsHidden()
	return false
end
-------------------------------------------------------------------------------
function modifier_forged_spirit_melting_strike_effect:GetTexture()
	return "forged_spirit_melting_strike"
end
--------------------------------------------------------------------------------

function modifier_forged_spirit_melting_strike_effect:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_forged_spirit_melting_strike_effect:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
	    return self:GetStackCount() * -1 * self.armor_removed
	else
		self:Destroy()
	end
end
