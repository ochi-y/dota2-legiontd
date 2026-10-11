ability_ursa_enrage = class({})
LinkLuaModifier( "modifier_ability_ursa_enrage", "ability/ability_ursa_enrage", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_ability_ursa_enrage_ai", "ability/ability_ursa_enrage", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------
function ability_ursa_enrage:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
 	-- if self:GetCaster():HasScepter() then
 	-- 	behavior = behavior + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
 	-- end
 	return behavior
end

function ability_ursa_enrage:GetIntrinsicModifierName()
	return "modifier_ability_ursa_enrage_ai"
end

-- function ability_ursa_enrage:GetCooldown( level )
-- 	if self:GetCaster():HasScepter() then
-- 		return self:GetSpecialValueFor( "cooldown_scepter" )
-- 	end

-- 	return self.BaseClass.GetCooldown( self, level )
-- end

function ability_ursa_enrage:OnSpellStart()
	-- get references
	local bonus_duration = self:GetSpecialValueFor("duration")

	-- Purge
	self:GetCaster():Purge(false, true, false, true, false)

	-- Add buff modifier
	self:GetCaster():AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_ability_ursa_enrage",
		{ duration = bonus_duration }
	)
	-- play effects
	self:PlayEffects()
end

function ability_ursa_enrage:PlayEffects()
	-- get resources
	local sound_cast = "Hero_Ursa.Enrage"

	-- play sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

modifier_ability_ursa_enrage = class({})

--------------------------------------------------------------------------------

function modifier_ability_ursa_enrage:IsHidden()
	return false
end

function modifier_ability_ursa_enrage:IsDebuff()
	return false
end

function modifier_ability_ursa_enrage:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_ability_ursa_enrage:OnCreated( kv )
	if not self:GetAbility() then return end
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")

end

function modifier_ability_ursa_enrage:OnRefresh( kv )
	if not self:GetAbility() then return end
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
end

function modifier_ability_ursa_enrage:OnDestroy( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self.stack_multiplier = self:GetAbility():GetSpecialValueFor("enrage_multiplier")
end
--------------------------------------------------------------------------------

function modifier_ability_ursa_enrage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_ability_ursa_enrage:GetModifierIncomingDamage_Percentage( params )
	return -self.damage_reduction
end

function modifier_ability_ursa_enrage:GetModifierModelScale( params )
	return 20
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ability_ursa_enrage:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_ability_ursa_enrage:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


-------------------------------------------------------------------------------------------------------
modifier_ability_ursa_enrage_ai = class({
	IsHidden = function(self)
		return true
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
function modifier_ability_ursa_enrage_ai:AllowIllusionDuplicate()
	return false
end
function modifier_ability_ursa_enrage_ai:OnCreated(params)
	if not self:GetAbility() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
end
function modifier_ability_ursa_enrage_ai:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_ability_ursa_enrage_ai:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_ability_ursa_enrage_ai:OnTakeDamage( params )
	if not IsServer() then return end

	-- filter
	if params.unit~=self:GetParent() then return end

	if params.attacker:GetTeamNumber()==self:GetParent():GetTeamNumber() then return end

	local parent=self:GetParent()
	if params.damage>30  then
		

		local ab=parent:FindAbilityByName("ability_ursa_enrage")
		if ab and ab:IsFullyCastable() then
			parent:CastAbilityNoTarget(ab,-1)
		end
	end
end
