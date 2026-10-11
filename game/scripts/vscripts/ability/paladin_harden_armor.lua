LinkLuaModifier( "modifier_paladin_harden_armor", "ability/paladin_harden_armor.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if paladin_harden_armor == nil then
	paladin_harden_armor = class({})
end
function paladin_harden_armor:GetIntrinsicModifierName()
	return "modifier_paladin_harden_armor"
end
---------------------------------------------------------------------
--Modifiers
if modifier_paladin_harden_armor == nil then
	modifier_paladin_harden_armor = class({})
end
function modifier_paladin_harden_armor:IsHidden()
	return true
end
function modifier_paladin_harden_armor:IsPurgable(params)
	return false
end
function modifier_paladin_harden_armor:OnCreated(params)
	if IsServer() then
	end
end
function modifier_paladin_harden_armor:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_paladin_harden_armor:OnDestroy()
	if IsServer() then
	end
end
function modifier_paladin_harden_armor:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}
end

----------------------------------------
function modifier_paladin_harden_armor:OnAttacked (params)

	if not IsServer() then return end
	if params.target ~= self:GetParent() then return end
	
	if RandomInt(1, 100) <= 30 then   
		self.block_damage=50
	else
		self.block_damage=0
	end
   
end
----------------------------------------

function modifier_paladin_harden_armor:GetModifierPhysical_ConstantBlock( params )
   return self.block_damage
end
