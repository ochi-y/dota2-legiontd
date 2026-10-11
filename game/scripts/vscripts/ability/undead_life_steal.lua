LinkLuaModifier( "modifier_undead_life_steal", "ability/undead_life_steal.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if undead_life_steal == nil then
	undead_life_steal = class({})
end
function undead_life_steal:GetIntrinsicModifierName()
	return "modifier_undead_life_steal"
end
---------------------------------------------------------------------
--Modifiers
modifier_undead_life_steal = {}

function modifier_undead_life_steal:IsHidden()
	return true
end
function modifier_undead_life_steal:IsPurgable(params)
	return false
end
function modifier_undead_life_steal:IsDebuff()
	return false
end

function modifier_undead_life_steal:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_undead_life_steal:OnTakeDamage( params )
	if IsServer() then
		if params.attacker == self:GetParent() and params.damage_category==DOTA_DAMAGE_CATEGORY_ATTACK then
			local heal = params.damage *0.3
			-- self:GetParent():Heal( heal, self:GetAbility() )

			self:GetParent():HealWithParams(heal, self, true, true,self:GetParent() , false)

			local effect_lifesteal = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(effect_lifesteal, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(effect_lifesteal)
		end
	end
end