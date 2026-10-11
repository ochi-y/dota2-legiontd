LinkLuaModifier( "modifier_arctic_enrage_old", "ability/arctic_enrage_old.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if arctic_enrage_old == nil then
	arctic_enrage_old = class({})
end
function arctic_enrage_old:OnSpellStart()
	-- get references
	local duration = self:GetSpecialValueFor("duration")
	-- Purge
	self:GetCaster():Purge(false, true, false, true, false)

	-- Add buff modifier
	self:GetCaster():AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_arctic_enrage_old",
		{ duration = duration }
	)
	local sound_cast = "Hero_Ursa.Enrage"
	-- play sound
	EmitSoundOn( sound_cast, self:GetCaster() )

	self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
end
---------------------------------------------------------------------
--Modifiers
if modifier_arctic_enrage_old == nil then
	modifier_arctic_enrage_old = class({})
end

function modifier_arctic_enrage_old:IsHidden(params)
	return false
end

function modifier_arctic_enrage_old:IsPurgable(params)
	return false
end

function modifier_arctic_enrage_old:OnCreated(params)
	local ability=self:GetAbility()
	self.hp_percent=ability:GetSpecialValueFor("hp_percent")
end
function modifier_arctic_enrage_old:OnRefresh(params)
	local ability=self:GetAbility()
	self.hp_percent=ability:GetSpecialValueFor("hp_percent")
end
function modifier_arctic_enrage_old:OnDestroy()
	if IsServer() then
	end
end
function modifier_arctic_enrage_old:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MODEL_SCALE
	}
end
function modifier_arctic_enrage_old:GetModifierModelScale( params )
	return 15
end

function modifier_arctic_enrage_old:GetModifierPreAttack_BonusDamage()
	return math.ceil(self:GetParent():GetHealth()*self.hp_percent/100)
end
function modifier_arctic_enrage_old:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_arctic_enrage_old:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
