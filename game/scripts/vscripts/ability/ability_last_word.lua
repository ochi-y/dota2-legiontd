LinkLuaModifier( "modifier_ability_last_word", "ability/ability_last_word" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_last_word_debuff", "ability/ability_last_word" ,LUA_MODIFIER_MOTION_NONE )

ability_last_word = class({})
elf_sword_mage_last_word=ability_last_word

--------------------------------------------------------------------------------
function ability_last_word:GetIntrinsicModifierName()
    return "modifier_ability_last_word"
end
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
modifier_ability_last_word = class({
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
function modifier_ability_last_word:AllowIllusionDuplicate()
	return false
end
function modifier_ability_last_word:OnCreated(params)
	local ability=self:GetAbility()
	self.aura_radius=ability:GetSpecialValueFor("aura_radius")
	self.duration=ability:GetSpecialValueFor("duration")
end
function modifier_ability_last_word:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_ability_last_word:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
end
function modifier_ability_last_word:CheckState()
	local state = {
		
	}
	return state
end

function modifier_ability_last_word:OnAbilityFullyCast(keys)
	if IsServer() then
		local castAbility = keys.ability

		local ability=self:GetAbility()
		if castAbility then
			local unit=keys.unit
			local parent = self:GetParent()


			if unit:GetTeam()~=parent:GetTeam() and UTIL:unitDistance(unit,parent)<self.aura_radius then
				local units=FindAbilityTarget(ability,parent:GetAbsOrigin(),self.aura_radius,{})


				EmitSoundOn("Hero_Silencer.LastWord.Cast", parent)
				parent:StartGesture(ACT_DOTA_CAST_ABILITY_3)

				local effect_cast = ParticleManager:CreateParticle(
					"particles/units/heroes/hero_silencer/silencer_last_word_status_cast.vpcf",
					PATTACH_ABSORIGIN_FOLLOW,
					self:GetCaster()
				)
				ParticleManager:SetParticleControlEnt(
					effect_cast,
					0,
					self:GetCaster(),
					PATTACH_POINT_FOLLOW,
					"attach_attack1",
					Vector(),
					true
				)
				ParticleManager:SetParticleControlForward( effect_cast, 1, parent:GetForwardVector() )
				ParticleManager:ReleaseParticleIndex( effect_cast )
				print(#units)
				for index, unit in ipairs(units) do
					print(unit:GetUnitName())
					unit:AddNewModifier(parent, ability, "modifier_ability_last_word_debuff", {
						duration=self.duration
					})
				end
			end
		end
	end
end


--------------------------------------------------------------------------------
modifier_ability_last_word_debuff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            
        }
    end,
})

function modifier_ability_last_word_debuff:CheckState()
	return { [MODIFIER_STATE_SILENCED] = true }
end
function modifier_ability_last_word_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_ability_last_word_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_ability_last_word_debuff:OnCreated()
	local ability=self:GetAbility()
	self.bonus_base_damage=ability:GetSpecialValueFor("bonus_base_damage")
end
function modifier_ability_last_word_debuff:GetModifierDamageOutgoing_Percentage()
	return self.bonus_base_damage
end