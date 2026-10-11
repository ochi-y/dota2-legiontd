LinkLuaModifier("modifier_radiant_spectre_dispersion", "ability/radiant_spectre_dispersion", LUA_MODIFIER_MOTION_NONE)

radiant_spectre_dispersion = class({})

--------------------------------------------------------------------------------

function radiant_spectre_dispersion:GetIntrinsicModifierName()
	return "modifier_radiant_spectre_dispersion"
end

--------------------------------------------------------------------------------


modifier_radiant_spectre_dispersion = class({
	IsHidden               = function(self) return true end,
	IsPurgable             = function(self) return false end,
	IsDebuff               = function(self) return false end,
	IsBuff                 = function(self) return true end,
	RemoveOnDeath          = function(self) return true end,
	AllowIllusionDuplicate = function(self) return false end,
	DeclareFunctions       = function(self)
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
		}
	end,
})


--------------------------------------------------------------------------------

function modifier_radiant_spectre_dispersion:OnTakeDamage(k)
	local target = k.unit
	local caster = self:GetParent()
	local original_damage = k.original_damage
	local damage_type = k.damage_type

	local damage_flags=k.damage_flags
	
	if target == caster and not caster:PassivesDisabled() and bit.band(damage_flags, DOTA_DAMAGE_FLAG_REFLECTION)==0 then
		local damage_reflection_pct = self:GetAbility():GetSpecialValueFor("damage_reflection_pct")
		local min_radius = self:GetAbility():GetSpecialValueFor("min_radius")
		local max_radius = self:GetAbility():GetSpecialValueFor("max_radius")
		local max_units = self:GetAbility():GetSpecialValueFor("max_units")
		-- max_units=5
		local all = FindUnitsInRadius(target:GetTeam(),
			caster:GetOrigin(),
			nil,
			max_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			false)

		all=subrange(all,1,max_units)

		local reflect = damage_reflection_pct
		local totalDamage= original_damage* reflect*0.01 
		local damage=math.ceil(totalDamage/(#all))


		for i = 1, max_units, 1 do
			local hero=all[i]
			if hero then
				local part = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_dispersion.vpcf",
				PATTACH_ABSORIGIN, hero)
			-- ParticleManager:SetParticleControl(part, 0, hero:GetAbsOrigin() + Vector(0,0,50))
			-- ParticleManager:SetParticleControl(part, 1, caster:GetAbsOrigin() + Vector(0,0,50))
			-- ParticleManager:SetParticleControl(part, 2, caster:GetAbsOrigin() + Vector(0,0,50))
				ParticleManager:SetParticleControlEnt(part, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc",
					hero:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(part, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc",
					caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(part, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc",
					caster:GetAbsOrigin(), true)

				ParticleManager:ReleaseParticleIndex(part)

				local distance = (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
				-- local reflect = 0
				-- if distance < min_radius then
				-- 	reflect = damage_reflection_pct
				-- elseif distance > max_radius then
				-- 	reflect = 0
				-- else
				-- 	reflect = damage_reflection_pct * (max_radius - distance) / (max_radius - min_radius)
				-- end
				
				if damage > 0 and totalDamage>0 then
					ApplyDamage({
						victim = hero,
						attacker = caster,
						damage = damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						-- DOTA_DAMAGE_FLAG_HPLOSS
						damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_ALL_BLOCK + DOTA_DAMAGE_FLAG_REFLECTION ,
						ability = self:GetAbility()
					})
					totalDamage=totalDamage-damage
				end
				if totalDamage<= 0 then
					break
				end
			end
		end
		-- for _, hero in ipairs(all) do
			
		-- end
	end
end

function modifier_radiant_spectre_dispersion:GetModifierIncomingDamage_Percentage()
	return self:GetAbility()
		:GetSpecialValueFor("damage_reflection_pct") * -1
end
