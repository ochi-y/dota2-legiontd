LinkLuaModifier( "modifier_ability_frenzy", "ability/ability_frenzy.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
ability_frenzy = class({})  

wave_24_champion_frenzy=ability_frenzy   

function ability_frenzy:OnSpellStart()  
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()

	local duration=self:GetSpecialValueFor("duration")
	EmitSoundOn("n_creep_Thunderlizard_Big.Roar", self:GetCaster())
	caster:AddNewModifier(caster, self, "modifier_ability_frenzy", {duration=duration})
end
---------------------------------------------------------------------
--Modifiers
modifier_ability_frenzy = class({
	-- GetEffectName           = function(self) return "particles/neutral_fx/thunder_lizard_frenzy.vpcf" end,
	-- GetEffectAttachType     = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
	-- GetStatusEffectName     = function(self) return "particles/status_fx/status_effect_bloodrage.vpcf" end,
	-- StatusEffectPriority    = function(self) return 8 end,
})
function modifier_ability_frenzy:OnCreated(params)

	local ability=self:GetAbility()
	self.bonus_attack_speed=ability:GetSpecialValueFor("bonus_attack_speed")
	self.damage_amp=ability:GetSpecialValueFor("damage_amp")
	
	if IsServer() then
		

		local parent=self:GetParent()

		PlayEffOnUnit("particles/neutral_fx/thunder_lizard_frenzy.vpcf",parent,{

		})

	end
end
function modifier_ability_frenzy:IsPurgable(params)
	return true
end
function modifier_ability_frenzy:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_frenzy:OnDestroy()
	if IsServer() then
	end
end

function modifier_ability_frenzy:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_ability_frenzy:GetModifierAttackSpeedPercentage()
	return self.bonus_attack_speed
end
function modifier_ability_frenzy:GetModifierIncomingDamage_Percentage()
	return self.damage_amp
end



