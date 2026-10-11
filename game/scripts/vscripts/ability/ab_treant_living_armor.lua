LinkLuaModifier( "modifier_ab_treant_living_armor", "ability/ab_treant_living_armor.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_ab_treant_living_armor_tag", "ability/ab_treant_living_armor.lua", LUA_MODIFIER_MOTION_NONE )

--Abilities
if ab_treant_living_armor == nil then
	ab_treant_living_armor = class({})
end

function ab_treant_living_armor:OnSpellStart()
	if not IsServer() then return end
	
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability=self
	local duration=ability:GetSpecialValueFor("duration")
	
	if IsCustomBuilding(caster) then
		GamePlay:FighterSetAbilityTarget(caster.fighterId,self:GetAbilityName(),target.fighterId)
	end
	
	target:AddNewModifier(caster, self, "modifier_ab_treant_living_armor", {duration=duration})

	EmitSoundOn("Hero_Treant.LivingArmor.Cast", caster)
	EmitSoundOn("Hero_Treant.LivingArmor.Target", target)
end

---------------------------------------------------------------------
--Modifiers
if modifier_ab_treant_living_armor == nil then
	modifier_ab_treant_living_armor = class({})
end

function modifier_ab_treant_living_armor:IsPurgable(params)
	return true
end

function modifier_ab_treant_living_armor:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.total_heal=ability:GetSpecialValueFor("total_heal")
	self.bonus_armor=ability:GetSpecialValueFor("bonus_armor")
	local duration=ability:GetSpecialValueFor("duration")
	self.tick_heal=self.total_heal/duration

	if IsServer() then
		self:StartIntervalThink( 1 )
		SimpleAddEff(self,self:GetParent(),"particles/units/heroes/hero_treant/treant_livingarmor.vpcf",nil)
	end
end
function modifier_ab_treant_living_armor:OnRefresh(params)
	--self:OnCreated(params)
end
function modifier_ab_treant_living_armor:OnDestroy()
	if IsServer() then
	end
end
function modifier_ab_treant_living_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
-- function modifier_ab_treant_living_armor:GetEffectName()
-- 	return "particles/units/heroes/hero_treant/treant_livingarmor.vpcf"
-- end
-- function modifier_ab_treant_living_armor:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end
function modifier_ab_treant_living_armor:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_ab_treant_living_armor:OnIntervalThink()
	if not IsServer() then return end
	local parent=self:GetParent()
	local caster=self:GetCaster()
	local heal = self.tick_heal

	parent:HealWithParams(heal, self:GetAbility(), true, true,caster , false)

	-- local effect_lifesteal = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	-- ParticleManager:SetParticleControl(effect_lifesteal, 0, parent:GetAbsOrigin())
	-- ParticleManager:ReleaseParticleIndex(effect_lifesteal)
	
	PopupHealing(parent, math.floor(heal))
end

modifier_ab_treant_living_armor_tag = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
AllowIllusionDuplicate           = function(self) return false end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
