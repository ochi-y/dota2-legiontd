LinkLuaModifier( "modifier_nature_natural_armor", "ability/nature_natural_armor.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_natural_armor == nil then
	nature_natural_armor = class({})
end
function nature_natural_armor:GetIntrinsicModifierName()
	return "modifier_nature_natural_armor"
end
---------------------------------------------------------------------
--Modifiers
if modifier_nature_natural_armor == nil then
	modifier_nature_natural_armor = class({})
end
function modifier_nature_natural_armor:IsHidden()
	return true
end
function modifier_nature_natural_armor:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.chance=ability:GetSpecialValueFor("chance")
	self.damage_block=ability:GetSpecialValueFor("damage_block")

	self.min_damage=ability:GetSpecialValueFor("min_damage")

	if IsServer() then
	end
end
function modifier_nature_natural_armor:IsPurgable(params)
	return false
end
function modifier_nature_natural_armor:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_nature_natural_armor:OnDestroy()
	if IsServer() then
	end
end
function modifier_nature_natural_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}
end

function modifier_nature_natural_armor:GetModifierPhysical_ConstantBlock( params )
	local damage=params.damage
	if damage==nil then
		return
	end
	if RandomInt(1, 100)<=self.chance then
		if damage>=self.damage_block then
			return self.damage_block
		else
			return math.max(0,damage-self.min_damage) 	
		end
	end
end
