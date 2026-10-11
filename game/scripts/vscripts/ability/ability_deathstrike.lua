LinkLuaModifier( "modifier_ability_deathstrike", "ability/ability_deathstrike", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_deathstrike_debuff", "ability/ability_deathstrike", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_ability_deathstrike_buff", "ability/ability_deathstrike", LUA_MODIFIER_MOTION_NONE )

--Abilities
ability_deathstrike = class({})

wave_9_champion_deathstrike=ability_deathstrike
function ability_deathstrike:GetIntrinsicModifierName()
	return "modifier_ability_deathstrike"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability_deathstrike == nil then
	modifier_ability_deathstrike = class({})
end

function modifier_ability_deathstrike:IsHidden(params)
	return true
end

function modifier_ability_deathstrike:OnCreated(params)

	local ability=self:GetAbility()
	self.health_threshold_pct=ability:GetSpecialValueFor("health_threshold_pct")
	self.duration=ability:GetSpecialValueFor("duration")
end
function modifier_ability_deathstrike:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_deathstrike:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_deathstrike:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end
function modifier_ability_deathstrike:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:PassivesDisabled() then return end
	
	local ability=self:GetAbility()
	local target = params.target
	local caster=self:GetParent()
	addNewModiferWithStack(target, caster, ability, "modifier_ability_deathstrike_debuff", {duration=self.duration})

	if target:GetHealthPercent()<=self.health_threshold_pct then
		local caster=self:GetCaster()
		if IsActiveUnit(caster) then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_ability_deathstrike_buff", {duration=self.duration})
		end
	end
end

---------------------------------------------------------------------
--Modifiers
modifier_ability_deathstrike_debuff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_ability_deathstrike_debuff:OnCreated(params)
	local ability=self:GetAbility()
	self.slow=ability:GetSpecialValueFor("slow")
end
function modifier_ability_deathstrike_debuff:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_deathstrike_debuff:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_deathstrike_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_ability_deathstrike_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -1*self.slow*self:GetStackCount()
end

---------------------------------------------------------------------
--Modifiers
modifier_ability_deathstrike_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_ability_deathstrike_buff:OnCreated(params)
	
	self.bonus_move_speed=self:GetAbility():GetSpecialValueFor("bonus_move_speed")
	self.bonus_attack_speed=self:GetAbility():GetSpecialValueFor("bonus_attack_speed")

	if not IsServer() then return end
	EmitSoundOn("Hero_Undying.Decay.Target", self:GetCaster())

	local caster=self:GetCaster()
	PlayEffOnUnit("particles/econ/items/razor/razor_arcana/razor_arcana_static_link_debuff_dark_ring.vpcf",caster,{
		cpKv={
			[1]=Vector(500,0,0)
		},
		mod=self
	})
end
function modifier_ability_deathstrike_buff:OnRefresh(params)
	
	self.bonus_move_speed=self:GetAbility():GetSpecialValueFor("bonus_move_speed")
	self.bonus_attack_speed=self:GetAbility():GetSpecialValueFor("bonus_attack_speed")

end
function modifier_ability_deathstrike_buff:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_deathstrike_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_ability_deathstrike_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_move_speed
end
function modifier_ability_deathstrike_buff:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

