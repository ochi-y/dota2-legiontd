LinkLuaModifier("modifier_elf_global_silence", "ability/elf_global_silence", LUA_MODIFIER_MOTION_NONE)

elf_global_silence = {}

function elf_global_silence:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")


	local radius=0

	if GamePlay.state~= "in-round" then
		radius=300
	end
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		radius,
		false
	)
	

	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_elf_global_silence",
			{ duration = duration * (1 - CalUnitStatusResistance(enemy)) }
		)

		local effect_cast = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_silencer/silencer_global_silence_hero.vpcf",
			PATTACH_ABSORIGIN_FOLLOW,
			enemy
		)
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			1,
			enemy,
			PATTACH_ABSORIGIN_FOLLOW,
			"attach_attack1",
			Vector(),
			true
		)
		ParticleManager:ReleaseParticleIndex(effect_cast)
	end

	local casterPid = caster:GetPlayerOwnerID()
	for _, pid in pairs(Player:Ids()) do
		if PlayerResource:GetTeam(pid) ~= PlayerResource:GetTeam(casterPid) then
			EmitSoundOnClient("Hero_Silencer.GlobalSilence.Effect", PlayerResource:GetPlayer(pid))
		end
	end

	local effect_cast = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_silencer/silencer_global_silence.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self:GetCaster()
	)
	ParticleManager:SetParticleControlForward(effect_cast, 0, self:GetCaster():GetForwardVector())
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(),
		true
	)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	EmitGlobalSound("Hero_Silencer.GlobalSilence.Cast")
end

modifier_elf_global_silence = {}

function modifier_elf_global_silence:IsDebuff()
	return true
end

function modifier_elf_global_silence:IsStunDebuff()
	return false
end

function modifier_elf_global_silence:IsPurgable()
	return true
end

function modifier_elf_global_silence:CheckState()
	return { [MODIFIER_STATE_SILENCED] = true }
end

function modifier_elf_global_silence:GetEffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_elf_global_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
