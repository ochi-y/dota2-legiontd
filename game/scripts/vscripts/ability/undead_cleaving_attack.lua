LinkLuaModifier( "modifier_undead_cleaving_attack", "ability/undead_cleaving_attack.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if undead_cleaving_attack == nil then
	undead_cleaving_attack = class({})
end
function undead_cleaving_attack:GetIntrinsicModifierName()
	return "modifier_undead_cleaving_attack"
end
---------------------------------------------------------------------
--Modifiers
modifier_undead_cleaving_attack = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})
function modifier_undead_cleaving_attack:OnCreated(params)
	if IsServer() then
	end
end
function modifier_undead_cleaving_attack:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_undead_cleaving_attack:OnDestroy()
	if IsServer() then
	end
end
function modifier_undead_cleaving_attack:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end
function modifier_undead_cleaving_attack:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local ability=self:GetAbility()
	local target = params.target
	local caster=self:GetParent()

	local damage=params.damage
	
	local splashData = {{
		radius = 40,
		damage = ability:GetSpecialValueFor("small_damage_pct") * damage/100
	}, {
		radius = ability:GetSpecialValueFor("large_radius"),
		damage = ability:GetSpecialValueFor("large_radius_pct") * damage/100
	}}

	splashAttack(caster,target,splashData, ability,{groundOnly=true})

	-- local fv = ((target:GetAbsOrigin() - params.attacker:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized()
	-- local particleName = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf"
	-- local pfx = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
	-- ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin() + fv * 100, true)
	-- Timers:CreateTimer(2, function()
	-- 	ParticleManager:DestroyParticle(pfx, false)
	-- 	ParticleManager:ReleaseParticleIndex(pfx)
	-- end)

end
