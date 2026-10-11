LinkLuaModifier( "modifier_orc_maledict", "ability/orc_maledict.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if orc_maledict == nil then
	orc_maledict = class({})
end

function orc_maledict:OnSpellStart()
	local caster=self:GetCaster()

	local pos=self:GetCursorPosition()

	local radius=self:GetSpecialValueFor("radius")

	PlayEffOnUnit("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe.vpcf",caster,{
		cpKv={[1]=Vector(radius,radius,radius)}	
	})

end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_orc_maledict = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return false
	end,
	IsBuff = function(self)
		return true
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_orc_maledict:AllowIllusionDuplicate()
	return false
end
function modifier_orc_maledict:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_damage=ability:GetSpecialValueFor("bonus_damage")
	self.damage=ability:GetSpecialValueFor("damage")
	self.bonus_damage_threshold=ability:GetSpecialValueFor("bonus_damage_threshold")
	self.ticks=ability:GetSpecialValueFor("ticks")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
end
function modifier_orc_maledict:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_orc_maledict:DeclareFunctions()
	return {
	}
end
