LinkLuaModifier("modifier_ghost_gravekeepers_cloak", "ability/ghost_gravekeepers_cloak", LUA_MODIFIER_MOTION_NONE)

ghost_gravekeepers_cloak = class({})

--------------------------------------------------------------------------------

function ghost_gravekeepers_cloak:GetIntrinsicModifierName()
	return "modifier_ghost_gravekeepers_cloak"
end

--------------------------------------------------------------------------------

modifier_ghost_gravekeepers_cloak = class({
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

function modifier_ghost_gravekeepers_cloak:OnCreated(k)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.reflect_pct = ability:GetSpecialValueFor("reflect_pct")
	self.radius = ability:GetSpecialValueFor("radius")
	self.unit_count = ability:GetSpecialValueFor("unit_count")

end

function modifier_ghost_gravekeepers_cloak:OnRefresh(k)
	self:OnCreated(k)
end

--------------------------------------------------------------------------------

function modifier_ghost_gravekeepers_cloak:OnTakeDamage(k)
	local target = k.unit
	local caster = self:GetParent()
	local original_damage = k.original_damage
	local damage_type = k.damage_type
	if target == caster and not caster:PassivesDisabled() then

		local all = FindUnitsInRadius(target:GetTeam(),
			caster:GetOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			false)

		ArrayRemove(all, function (v)
			return v==caster
		end)

		ArrayOrderByMapFunc(all,function (v)
			return v:GetHealthPercent()
		end)

		all=subrange(all,1,self.unit_count)

		for _, hero in ipairs(all) do
			-- local part = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_dispersion.vpcf",
			-- 	PATTACH_ABSORIGIN, hero)
			-- -- ParticleManager:SetParticleControl(part, 0, hero:GetAbsOrigin() + Vector(0,0,50))
			-- -- ParticleManager:SetParticleControl(part, 1, caster:GetAbsOrigin() + Vector(0,0,50))
			-- -- ParticleManager:SetParticleControl(part, 2, caster:GetAbsOrigin() + Vector(0,0,50))

			-- ParticleManager:SetParticleControlEnt(part, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc",
			-- 	hero:GetAbsOrigin(), true)
			-- ParticleManager:SetParticleControlEnt(part, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc",
			-- 	caster:GetAbsOrigin(), true)
			-- ParticleManager:SetParticleControlEnt(part, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc",
			-- 	caster:GetAbsOrigin(), true)


			-- ParticleManager:ReleaseParticleIndex(part)

			local distance = (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()

			local reflect = self.reflect_pct

			local heal = original_damage / 100 * reflect
			if heal > 0 then
				-- ApplyDamage({
				-- 	victim = hero,
				-- 	attacker = caster,
				-- 	damage = damage,
				-- 	damage_type = damage_type,
				-- 	damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
				-- 	ability = self:GetAbility()
				-- })
				hero:HealWithParams(heal, self:GetAbility(), false, true, hero, false)
				

				local effect=ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(effect, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc",
				caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(effect, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc",
				caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(effect)
				self:AddParticle(effect, false, false, -1, false, false)

			end
		end
	end
end

function modifier_ghost_gravekeepers_cloak:GetModifierIncomingDamage_Percentage()
	return self:GetAbility()
		:GetSpecialValueFor("reflect_pct") * -1
end
