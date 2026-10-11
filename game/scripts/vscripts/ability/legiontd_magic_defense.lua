LinkLuaModifier( "modifier_legiontd_magic_defense", "ability/legiontd_magic_defense.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if legiontd_magic_defense == nil then
	legiontd_magic_defense = class({})
end
function legiontd_magic_defense:OnToggle()
	local caster = self:GetCaster()
    local modifier = caster:FindModifierByName( "modifier_legiontd_magic_defense" )
	if self:GetToggleState() then

		caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
		caster:AddNewModifier(caster,self,"modifier_legiontd_magic_defense",{})
	else
		if modifier then
			modifier:Destroy()
		end
	end
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_legiontd_magic_defense = class({
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
function modifier_legiontd_magic_defense:AllowIllusionDuplicate()
	return false
end
function modifier_legiontd_magic_defense:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 

	local ability=self:GetAbility()
	self.magic_damage_reduction=ability:GetSpecialValueFor("magic_damage_reduction")
	self.move_speed_bonus=ability:GetSpecialValueFor("move_speed_bonus")
	self.damage_taken=100-self.magic_damage_reduction

	if not IsServer() then return end
	local caster=self:GetCaster()
	EmitSoundOn("Hero_Antimage.Counterspell.Cast", caster)
	-- PlayEffOnUnit("particles/units/heroes/hero_antimage/antimage_counter.vpcf",caster,{
	-- 	bind = PATTACH_POINT_FOLLOW,
	-- 	attach="attach_hitloc",
	-- 	cps={0},
	-- 	cpKv={
	-- 		[1]=Vector(100,100,100)
	-- 	},
	-- 	mod=self
	-- })


	

end
function modifier_legiontd_magic_defense:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK

	}
end
function modifier_legiontd_magic_defense:CheckState()
	local state = {
	}

	return state
end

function modifier_legiontd_magic_defense:GetModifierMoveSpeedBonus_Percentage()
	return self.move_speed_bonus
end

function modifier_legiontd_magic_defense:GetModifierIncomingSpellDamageConstant(params)
	return -params.damage*self.magic_damage_reduction/100
end

function modifier_legiontd_magic_defense:GetModifierPhysical_ConstantBlock(params)
    if not IsServer() then
        return
    end
    local target = self:GetParent()
    local attacker = params.attacker
    if attacker and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and attacker.attackType == "magic" and params.ranged_attack then
        return math.ceil(params.damage * (100 - self.damage_taken) / 100)
    end
end