LinkLuaModifier("modifier_orc_fatal_bonds_debuff", "ability/orc_fatal_bonds", LUA_MODIFIER_MOTION_NONE)

orc_fatal_bonds = class({})

function orc_fatal_bonds:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local count = self:GetSpecialValueFor("count")
		local damage_share = self:GetSpecialValueFor("damage_share_percentage")
		local boss_damage_share_percentage = self:GetSpecialValueFor("boss_damage_share_percentage")


		EmitSoundOn("Hero_Warlock.FatalBonds", target)
		-- Include the main target
		local targets = {}
			
		table.insert(targets, target:entindex())

		--targets[count] = target:entindex()
		count = count - 1

		-- Find nearby enemies to affect
		local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil,
			self:GetSpecialValueFor("search_aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
		for _, enemy in pairs(enemies) do
			if enemy ~= target and count > 0 then
				-- targets[count] = enemy:entindex()
				table.insert(targets, enemy:entindex())
				count = count - 1
			end
		end


		local preUnit = caster

		for _, affected_enemy_index in pairs(targets) do
			local target = EntIndexToHScript(affected_enemy_index)

			local bonds_pfx = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_warlock/warlock_fatal_bonds_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, preUnit)

			if preUnit == caster then
				ParticleManager:SetParticleControlEnt(bonds_pfx, 0, preUnit, PATTACH_POINT_FOLLOW, "attach_attack1",
					caster:GetAbsOrigin(), true)
			else
				ParticleManager:SetParticleControlEnt(bonds_pfx, 0, preUnit, PATTACH_POINT_FOLLOW, "attach_hitloc",
					caster:GetAbsOrigin(), true)
			end
			ParticleManager:SetParticleControlEnt(bonds_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc",
				target:GetAbsOrigin(), true)

			ParticleManager:ReleaseParticleIndex(bonds_pfx)


			local duration=self:GetSpecialValueFor("duration")

			duration = duration * (1 - CalUnitStatusResistance(target))

			target:AddNewModifier(caster, self, "modifier_orc_fatal_bonds_debuff", {
				duration = duration,
				damage_share = damage_share,
				boss_damage_share_percentage=boss_damage_share_percentage,
				target_1 = targets[1],
				target_2 = targets[2],
				target_3 = targets[3],
				target_4 = targets[4],
				target_5 = targets[5],
				target_6 = targets[6]
			})
			preUnit = target
		end
	end
end

modifier_orc_fatal_bonds_debuff = class({})

function modifier_orc_fatal_bonds_debuff:IsDebuff() return true end

function modifier_orc_fatal_bonds_debuff:IsHidden() return false end

function modifier_orc_fatal_bonds_debuff:IsPurgable() return true end

function modifier_orc_fatal_bonds_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_NONE end

function modifier_orc_fatal_bonds_debuff:ShouldUseOverheadOffset()
	return true
end

function modifier_orc_fatal_bonds_debuff:GetEffectName()
	return "particles/units/heroes/hero_warlock/warlock_fatal_bonds_icon.vpcf"
end

function modifier_orc_fatal_bonds_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_orc_fatal_bonds_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_orc_fatal_bonds_debuff:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_share_percentage")
end

function modifier_orc_fatal_bonds_debuff:OnCreated(keys)
	if IsServer() then
		self.current_damage = 0
		-- if not keys.damage_share then keys.damage_share = 12 end

		local parent=self:GetParent()

		if parent:IsAncient() then
			self.damage_share = keys.boss_damage_share_percentage * 0.01
		else
			self.damage_share = keys.damage_share * 0.01
		end

		self.share_targets = {}

		if keys.target_1 then table.insert(self.share_targets, EntIndexToHScript(keys.target_1)) end
		if keys.target_2 then table.insert(self.share_targets, EntIndexToHScript(keys.target_2)) end
		if keys.target_3 then table.insert(self.share_targets, EntIndexToHScript(keys.target_3)) end
		if keys.target_4 then table.insert(self.share_targets, EntIndexToHScript(keys.target_4)) end
		if keys.target_5 then table.insert(self.share_targets, EntIndexToHScript(keys.target_5)) end
		if keys.target_6 then table.insert(self.share_targets, EntIndexToHScript(keys.target_6)) end
		-- self:StartIntervalThink(1.0)
		-- self:OnIntervalThink()
	end
end

function modifier_orc_fatal_bonds_debuff:OnTakeDamage(keys)
	if IsServer() then
		if keys.unit == self:GetParent() then
			if keys.inflictor and keys.inflictor:GetAbilityName() == "orc_fatal_bonds" then
				return
			end
			if bit:_and(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return end
			self.current_damage = self.current_damage + keys.damage * self.damage_share
			--PrintTable(keys)
			--if not keys.unit:IsAlive() then
			self:SendDamage()
			--end
		end
	end
end

function modifier_orc_fatal_bonds_debuff:SendDamage()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local parent_loc = parent:GetAbsOrigin()

		for _, target in pairs(self.share_targets) do
			if (not target:IsNull()) and target:IsAlive() and target:HasModifier("modifier_orc_fatal_bonds_debuff") and parent ~= target then
				-- local bonds_pfx = ParticleManager:CreateParticle(
				-- 	"particles/units/heroes/hero_warlock/warlock_fatal_bonds_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
				-- ParticleManager:SetParticleControl(bonds_pfx, 0, parent_loc + Vector(0, 0, 100))
				-- ParticleManager:SetParticleControl(bonds_pfx, 1, target:GetAbsOrigin() + Vector(0, 0, 100))
				-- ParticleManager:ReleaseParticleIndex(bonds_pfx)
				local bonds_pfx = ParticleManager:CreateParticle(
					"particles/units/heroes/hero_warlock/warlock_fatal_bonds_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
				ParticleManager:SetParticleControlEnt(bonds_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc",
				parent:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(bonds_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc",
					target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(bonds_pfx)
				if self.current_damage > 0 then
					ApplyDamage({
						attacker = caster,
						victim = target,
						damage = self.current_damage,
						damage_type = DAMAGE_TYPE_PURE,
						damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION +
							DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_BYPASSES_ALL_BLOCK
					})
				end
			end
		end
		self.current_damage = 0
		if not parent:IsAlive() then
			self:Destroy()
		end
	end
end




