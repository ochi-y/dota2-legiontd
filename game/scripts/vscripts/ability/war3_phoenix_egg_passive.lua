LinkLuaModifier("modifier_war3_phoenix_egg_passive", "ability/war3_phoenix_egg_passive", LUA_MODIFIER_MOTION_NONE)
--Abilities
if war3_phoenix_egg_passive == nil then
	war3_phoenix_egg_passive = class({})
end
function war3_phoenix_egg_passive:GetIntrinsicModifierName()
	return "modifier_war3_phoenix_egg_passive"
end

function war3_phoenix_egg_passive:Spawn()
	if not IsServer() then
		return
	end
	self:SetLevel(1)
end

---------------------------------------------------------------------
--Modifiers

modifier_war3_phoenix_egg_passive = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_war3_phoenix_egg_passive:OnCreated(params)
	if not IsServer() then return end
	local parent = self:GetParent()
	Timers:CreateTimer(FrameTime(), function()
		parent:StartGesture(ACT_DOTA_LOADOUT)
	end)
	self.tick = 0
	self:StartIntervalThink(1)
	--	SimpleAddEff(self,self:GetParent(),"particles/units/heroes/hero_phoenix/phoenix_supernova_egg_steam.vpcf",nil)

	local particle_cast = "particles/units/heroes/hero_phoenix/phoenix_supernova_egg_steam.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ROOTBONE_FOLLOW, parent)
	local cps = { 0, 1, 2, 3, 4 }
	for i = 1, #cps do
		ParticleManager:SetParticleControlEnt(effect_cast, cps[i], parent, PATTACH_ROOTBONE_FOLLOW, "",
			parent:GetAbsOrigin(), -- unknown
			true         -- unknown, true
		)
	end
	self:AddParticle(effect_cast, false, false, -1, false, false)
end

function modifier_war3_phoenix_egg_passive:OnIntervalThink(params)
	if not IsServer() then return end
	self.tick = self.tick + 1
	local parent = self:GetParent()
	if self.tick == 10 then
		parent.phoenixReborn = true
		parent:ForceKill(false)
		local pos = parent:GetAbsOrigin()
		local pid = parent:GetPlayerOwnerID()
		local hero = PlayerResource:GetSelectedHeroEntity(pid)
		--local tUnit = CreateUnitByName("element_fenix", pos, false, hero, hero, parent:GetTeamNumber())
		
		local tUnit=OnZhaoHuan( "element_fenix",parent,pos,parent:GetTeamNumber(),nil,1,"null")  

		-- tUnit:SetControllableByPlayer(pid, true)
		SimpleMoveUnit(tUnit, pos)

		local eff = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
		EmitSoundOn("Hero_Phoenix.SuperNova.Explode", tUnit)
		SimplePlayEffAtlocation(eff, self:GetParent():GetAbsOrigin())

		UTIL_RemoveImmediate(parent)
	end
end

function modifier_war3_phoenix_egg_passive:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_war3_phoenix_egg_passive:OnDestroy()
	if IsServer() then
	end
end

function modifier_war3_phoenix_egg_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_war3_phoenix_egg_passive:GetEffectName()
	return "particles/units/heroes/hero_phoenix/phoenix_supernova_portrait.vpcf"
end

function modifier_war3_phoenix_egg_passive:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_war3_phoenix_egg_passive:OnDeath(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			local attacker=params.attacker
			if attacker and attacker==self:GetCaster() then
				return
			end
			
			local parent = self:GetParent()
			if not parent.phoenixReborn then
				local eff = "particles/units/heroes/hero_phoenix/phoenix_supernova_death.vpcf"
				EmitSoundOn("Hero_Phoenix.SuperNova.Death", self:GetParent())
				SimplePlayEffAtlocation(eff, self:GetParent():GetAbsOrigin())
			end
		end
	end
	return 0
end

function modifier_war3_phoenix_egg_passive:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true
	}
	return state
end
