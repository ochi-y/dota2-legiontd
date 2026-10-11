ability_attack_mana_burn = class({})


wave_7_champion_attack_mana_burn=ability_attack_mana_burn


LinkLuaModifier( "modifier_ability_attack_mana_burn_passive", "ability/ability_attack_mana_burn", LUA_MODIFIER_MOTION_NONE )


function ability_attack_mana_burn:GetIntrinsicModifierName()
	return "modifier_ability_attack_mana_burn_passive"
end

modifier_ability_attack_mana_burn_passive = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ability_attack_mana_burn_passive:IsHidden()
	return true
end

function modifier_ability_attack_mana_burn_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ability_attack_mana_burn_passive:OnCreated( kv )
	-- references
    self.burn_amount = self:GetAbility():GetSpecialValueFor( "burn_amount" ) 
	self.burn_damage_conversion = self:GetAbility():GetSpecialValueFor( "burn_damage_conversion") * .01
end

function modifier_ability_attack_mana_burn_passive:OnRefresh( kv )
	self:OnCreated()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ability_attack_mana_burn_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}

	return funcs
end

function modifier_ability_attack_mana_burn_passive:GetModifierProcAttack_BonusDamage_Physical( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		local target = params.target
		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_MANA_ONLY,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
        
		if result == UF_SUCCESS then
			local mana_burn =  self.burn_amount
			target:Script_ReduceMana( mana_burn,self:GetAbility() )        
            local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN, target )
            ParticleManager:ReleaseParticleIndex( effect_cast )
            -- EmitSoundOn( "Hero_Antimage.ManaBreak", target )
			return mana_burn * self.burn_damage_conversion
		end
	end
end