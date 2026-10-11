LinkLuaModifier( "modifier_undead_life_steal_2", "ability/undead_life_steal_2.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if undead_life_steal_2 == nil then
	undead_life_steal_2 = class({})
end
function undead_life_steal_2:GetIntrinsicModifierName()
	return "modifier_undead_life_steal_2"
end
---------------------------------------------------------------------
--Modifiers
modifier_undead_life_steal_2 = {}

function modifier_undead_life_steal_2:IsHidden()
	return true
end
function modifier_undead_life_steal_2:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.life_steal=ability:GetSpecialValueFor("life_steal")
end
function modifier_undead_life_steal_2:IsPurgable(params)
	return false
end
function modifier_undead_life_steal_2:IsDebuff()
	return false
end

function modifier_undead_life_steal_2:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_undead_life_steal_2:OnTakeDamage( params )
	if IsServer() then
		if params.attacker == self:GetParent() and params.damage_category==DOTA_DAMAGE_CATEGORY_ATTACK  then
			local heal = params.damage * self.life_steal/100
			-- self:GetParent():Heal( heal, self:GetAbility() )

			print("heal",heal)
			self:GetParent():HealWithParams(heal, self, true, true,self:GetParent() , false)


			local effect_lifesteal = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(effect_lifesteal, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(effect_lifesteal)
		end
	end
end