LinkLuaModifier("modifier_marine_torrent", "ability/marine_torrent", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marine_torrent_damage", "ability/marine_torrent", LUA_MODIFIER_MOTION_NONE)

marine_torrent = class({})

function marine_torrent:GetAOERadius()
	return self:GetSpecialValueFor("torrent_max_distance")
end

function marine_torrent:OnSpellStart()
	if not IsServer() then return end
	local delay = self:GetSpecialValueFor("delay")
	local point = self:GetCursorPosition()
	CreateModifierThinker(self:GetCaster(), self, "modifier_marine_torrent", {duration = delay}, point, self:GetCaster():GetTeamNumber(), false)
end

modifier_marine_torrent = class({})

function modifier_marine_torrent:IsHidden() return false end
function modifier_marine_torrent:IsPurgable() return false end

function modifier_marine_torrent:OnCreated()
	if not self:GetAbility() then return end
	if not IsServer() then return end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
	self.delay_spawn = self.ability:GetSpecialValueFor("torrent_interval")
	self.radius = self.ability:GetSpecialValueFor("torrent_max_distance")
	self.duration = self.ability:GetSpecialValueFor("torrent_duration")
	self.timers = {}
--	self:StartTorrentStorm()

	self.caster=self:GetCaster()


	local radius = self.ability:GetSpecialValueFor("radius")
	local movespeed_bonus = self.ability:GetSpecialValueFor("movespeed_bonus")
	local slow_duration = self.ability:GetSpecialValueFor("slow_duration")
	local stun_duration = self.ability:GetSpecialValueFor("stun_duration")
	local delay = self.ability:GetSpecialValueFor("delay")
	local torrent_damage = self.ability:GetSpecialValueFor("torrent_damage")
	local damage_tick_interval = self.ability:GetSpecialValueFor("damage_tick_interval")
	local point = self.parent:GetAbsOrigin()

	EmitSoundOnLocationForAllies(point, "Ability.pre.Torrent", self:GetCaster())


	local bubbles_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", PATTACH_WORLDORIGIN, nil, self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControl(bubbles_pfx, 0, point)
	ParticleManager:SetParticleControl(bubbles_pfx, 1, Vector(radius,0,0))

	AddFOWViewer(self:GetCaster():GetTeamNumber(), point, radius, delay+0.5, false)

	self.bubbles_pfx=bubbles_pfx
end

function modifier_marine_torrent:OnRefresh()
	-- self:StartTorrentStorm()
end
function modifier_marine_torrent:OnDestroy()
	if not self:GetAbility() then return end
	if not IsServer() then return end
	-- self:StartTorrent(self.parent:GetAbsOrigin())
	local bubbles_pfx=self.bubbles_pfx
	if bubbles_pfx then
		ParticleManager:DestroyParticle(bubbles_pfx, true )
		ParticleManager:ReleaseParticleIndex( bubbles_pfx )
	end
	self:CreateTorrent(self.parent:GetAbsOrigin())
end
-- function modifier_marine_torrent:StartTorrentStorm()
-- 	if not IsServer() then return end
-- 	local caster = self.parent
-- 	local count = self.duration / self.delay_spawn
-- 	if #self.timers > 0 then 
-- 		for _,timer in pairs(self.timers) do
-- 			if timer then 
-- 				Timers:RemoveTimer(timer)
-- 			end
-- 		end
-- 	end
-- 	for i = 0, count do
-- 		self.timers[i] = Timers:CreateTimer(self.delay_spawn * i, function()
-- 			local random_point = caster:GetAbsOrigin() + RandomVector(RandomInt(0, self.radius))
-- 			self.ability:StartTorrent(random_point)
-- 		end)
-- 	end
-- end

function modifier_marine_torrent:StartTorrent(new_point)
	if not IsServer() then return end
	

	-- Timers:CreateTimer(delay, function()
	-- 	if bubbles_pfx then
	-- 		ParticleManager:DestroyParticle(bubbles_pfx, true )
	-- 		ParticleManager:ReleaseParticleIndex( bubbles_pfx )
	-- 	end
	-- 	self:CreateTorrent(point)
	-- end)
end

function modifier_marine_torrent:CreateTorrent(origin)
	if not IsServer() then return end

	local ability=self:GetAbility()

	local radius = ability:GetSpecialValueFor("radius")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")


	local effs={
		"particles/econ/items/kunkka/kunkka_weapon_whaleblade_retro/kunkka_spell_torrent_retro_splash_whaleblade.vpcf",
		"particles/econ/items/kunkka/kunkka_weapon_whaleblade/kunkka_spell_torrent_splash_whaleblade.vpcf",
		-- "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf",
		-- "particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_skills/kunkka_spell_torrent_splash_fxset.vpcf"
	}

	local particle = effs[RandomInt(1, #effs)]

	local torrent_fx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(torrent_fx, 0, origin)
	ParticleManager:SetParticleControl(torrent_fx, 1, Vector(radius,0,0))
	ParticleManager:ReleaseParticleIndex(torrent_fx)

	EmitSoundOnLocationWithCaster(origin, "Ability.Torrent", self:GetCaster())

	local knockback =
	{
		should_stun = 1,
		knockback_duration = stun_duration,
		duration = stun_duration,
		knockback_distance = 0,
		knockback_height = 400,
	}

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	for _,enemy in pairs(enemies) do
		self:GetCaster():EmitSound("Hero_Kunkka.TidalWave.Target")
		enemy:RemoveModifierByName("modifier_knockback")
		enemy:AddNewModifier(self:GetCaster(), ability, "modifier_marine_torrent_damage", {duration = stun_duration})
		enemy:AddNewModifier(self:GetCaster(), ability, "modifier_knockback", knockback)
	end
end

modifier_marine_torrent_damage = class({})

function modifier_marine_torrent_damage:IsHidden() return true end

function modifier_marine_torrent_damage:OnCreated()
	if not self:GetAbility() then return end
	if not IsServer() then return end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
	self.slow_duration =self.ability:GetSpecialValueFor("slow_duration")
	self.torrent_damage = self.ability:GetSpecialValueFor("torrent_damage")
	self.damage_tick_interval = self.ability:GetSpecialValueFor("damage_tick_interval")
	self.damage = self.torrent_damage * self.damage_tick_interval
	self:StartIntervalThink(self.damage_tick_interval)
end

function modifier_marine_torrent_damage:OnIntervalThink()
	if not IsServer() then return end
	ApplyDamage({victim = self.parent, attacker = self.caster, ability = self.ability, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
end