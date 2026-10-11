ability_cold_embrace = ability_cold_embrace or class({})

LinkLuaModifier("modifier_custom_cold_embrace", "ability/ability_cold_embrace", LUA_MODIFIER_MOTION_NONE)

wave_29_champion_cold_embrace=ability_cold_embrace


arctic_cold_embrace=ability_cold_embrace

-- function ability_cold_embrace:OnAbilityPhaseStart()
--     return self:CheckPhaseStartWithMessage()
-- end

function ability_cold_embrace:OnSpellStart()
    if not IsServer() then return end

	local caster=self:GetCaster()
	local target=self:GetCursorTarget()

	caster:EmitSound("Hero_Winter_Wyvern.ColdEmbrace.Cast");

    local cold_embrace_start_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_start.vpcf", PATTACH_POINT, caster);
    ParticleManager:SetParticleControl(cold_embrace_start_particle, 0, caster:GetAbsOrigin());
    ParticleManager:SetParticleControl(cold_embrace_start_particle, 1, caster:GetAbsOrigin());
    ParticleManager:ReleaseParticleIndex(cold_embrace_start_particle);

    target:AddNewModifier(caster, self, "modifier_custom_cold_embrace", {duration = 4})
end


modifier_custom_cold_embrace = class({})

function modifier_custom_cold_embrace:IsHidden() return true end
function modifier_custom_cold_embrace:IsDebuff() return false end
function modifier_custom_cold_embrace:IsPurgable() return false end
function modifier_custom_cold_embrace:RemoveOnDeath() return true end


function modifier_custom_cold_embrace:OnCreated()

	if not self:GetAbility() then return end

	local ability=self:GetAbility()
	self.heal_additive=ability:GetSpecialValueFor("heal_additive")
	self.heal_percentage=ability:GetSpecialValueFor("heal_percentage")

	if not IsServer() then return end
    EmitSoundOn("Hero_Ancient_Apparition.ColdFeetCast", self:GetParent())
    self:StartIntervalThink(0.5)
end

function modifier_custom_cold_embrace:GetTexture()
	return "ability_cold_embrace"
end

function modifier_custom_cold_embrace:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
	}
end

function modifier_custom_cold_embrace:CheckState()
	return {
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY]=true
	}
end

function modifier_custom_cold_embrace:GetModifierIncomingPhysicalDamage_Percentage()
	return -100
end

function modifier_custom_cold_embrace:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff.vpcf"
end

function modifier_custom_cold_embrace:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_custom_cold_embrace:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if (parent) then
		local heal=0.5*(self.heal_additive + parent:GetMaxHealth() * self.heal_percentage * 0.01)


       -- parent:Heal(heal, nil)
		
		parent:HealWithParams(heal, self, false, true,self:GetCaster() , false)

		SendOverheadEventMessage( nil, OVERHEAD_ALERT_HEAL, self:GetParent(), heal, nil )
		--SendOverheadEventMessage( nil, OVERHEAD_ALERT_HEAL, parent, heal, nil )
    end
end
