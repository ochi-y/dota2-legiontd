mech_tidebringer = mech_tidebringer or class({})

LinkLuaModifier("modifier_mech_tidebringer_attack", "ability/mech_tidebringer", LUA_MODIFIER_MOTION_NONE)

function mech_tidebringer:GetIntrinsicModifierName()   return "modifier_mech_tidebringer_attack" end

function mech_tidebringer:Precache( context )
	-- PrecacheResource( "particle", "particles/econ/items/clinkz/clinkz_maraxiform/clinkz_maraxiform_searing_arrow.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf", context )
end

modifier_mech_tidebringer_attack = modifier_mech_tidebringer_attack or class({})

function modifier_mech_tidebringer_attack:IsPassive()          return true end
function modifier_mech_tidebringer_attack:IsBuff()				return true end
function modifier_mech_tidebringer_attack:IsPurgable()     	return false end
function modifier_mech_tidebringer_attack:IsPurgeException() 	return false end
function modifier_mech_tidebringer_attack:IsHidden()			return true end


function modifier_mech_tidebringer_attack:DeclareFunctions()
	return {
	MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_mech_tidebringer_attack:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	local caster =  self:GetCaster()
	local ability = self:GetAbility()
	
	if keys.attacker ~= caster or keys.target:IsBuilding() or keys.target:IsOther() or caster:PassivesDisabled() or not keys.target:IsAlive() then
		return
	end

    if not ability:IsFullyCastable() then
        return
    end

	local dmg = keys.damage * (ability:GetSpecialValueFor("cleave_damage") * 0.01) 

	local fDistance = ability:GetSpecialValueFor("cleave_distance")
	local fStartRadius = ability:GetSpecialValueFor("cleave_starting_width")
	local fEndRadius = ability:GetSpecialValueFor("cleave_ending_width")
	local unit_count = ability:GetSpecialValueFor("unit_count")

	

	local damageTable = {
		attacker =  keys.attacker,
		damage = dmg,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags =  DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_BYPASSES_ALL_BLOCK, --Optional.
		ability = ability, --Optional.
	}
	-- splash damage is computed here, not through the API
	local target = keys.attacker
	local pos = keys.target:GetAbsOrigin()
	local direction = GetDirection2D(pos, keys.attacker:GetAbsOrigin())
	local units = FindUnitsInTrapezoid(keys.attacker:GetTeamNumber(), direction, GetGroundPosition(target:GetAbsOrigin(), nil), fStartRadius, fEndRadius, fDistance, nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf", PATTACH_CUSTOMORIGIN, keys.attacker)
	ParticleManager:SetParticleControl(pfx, 0, keys.attacker:GetAbsOrigin())
	ParticleManager:SetParticleControlForward(pfx, 0, (pos - keys.attacker:GetAbsOrigin()):Normalized())


	local max_count = unit_count
	local count = math.min(#units,max_count)
	ParticleManager:SetParticleControl(pfx, 1, Vector(0,0,count))
	keys.attacker:EmitSound("Hero_Kunkka.Tidebringer.Attack")



	for i, unit in ipairs(units) do
		if unit~=keys.target then
			if i<=max_count then
				ParticleManager:SetParticleControlEnt(pfx, i + 1, unit, PATTACH_POINT, "attach_hitloc", unit:GetAbsOrigin(), true)
			else
				break
			end
			unit:EmitSound("Hero_Kunkaa.Tidebringer")
			damageTable.victim = unit
			ApplyDamage(damageTable)
		end
	end
	-- local pfx = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf"
	-- DoIMBACleaveAttack(caster, keys.target, ability, dmg, 
	-- 	ability:GetSpecialValueFor("cleave_starting_width"),
	-- 	ability:GetSpecialValueFor("cleave_ending_width"), 
	-- 	ability:GetSpecialValueFor("cleave_distance"), pfx)

    ability:UseResources(true,true,true,true)        
			
end