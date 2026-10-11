LinkLuaModifier("modifier_paladin_moment_of_courage", "ability/paladin_moment_of_courage", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_paladin_moment_of_courage_buff", "ability/paladin_moment_of_courage", LUA_MODIFIER_MOTION_NONE)

--Abilities
if paladin_moment_of_courage == nil then
	paladin_moment_of_courage = class({})
end
function paladin_moment_of_courage:GetIntrinsicModifierName()
	return "modifier_paladin_moment_of_courage"
end

modifier_paladin_moment_of_courage = class({
	IsHidden               = function(self) return true end,
	IsPurgable             = function(self) return false end,
	IsDebuff               = function(self) return false end,
	IsBuff                 = function(self) return true end,
	RemoveOnDeath          = function(self) return false end,
	AllowIllusionDuplicate = function(self) return true end,
	IsPermanent            = function(self) return true end,
	DeclareFunctions       = function(self) return { MODIFIER_EVENT_ON_ATTACK_LANDED } end,
})

function modifier_paladin_moment_of_courage:OnCreated()
	if not self:GetAbility() then return end
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.chance = self.ability:GetSpecialValueFor('trigger_chance')
	self.buff_duration = self.ability:GetSpecialValueFor('buff_duration')
	self.cooldown = self.ability:GetSpecialValueFor('cooldown')

	if not IsServer() then return end
end

function modifier_paladin_moment_of_courage:OnRefresh()
	self:OnCreated()
end

function modifier_paladin_moment_of_courage:OnAttackLanded(data)
	if IsClient() then return end
	if data.target ~= self.parent then return end
	if not self.ability:IsCooldownReady() then return end
	if data.attacker == self.parent or self.parent:PassivesDisabled() or data.attacker:IsBuilding() or data.attacker:GetTeam() == self.parent:GetTeam() then return end


	local caster = self:GetCaster()
	if RandomInt(1, 100) <= self.chance then
		caster:AddNewModifier(caster, self.ability, "modifier_paladin_moment_of_courage_buff", {
			duration = self.buff_duration
		})
		self.ability:StartCooldown(self.cooldown)
	end
end

-------------------------------------------------------------------------------------------------------
modifier_paladin_moment_of_courage_buff = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return false
	end,
	IsBuff = function(self)
		return true
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_paladin_moment_of_courage_buff:AllowIllusionDuplicate()
	return false
end

function modifier_paladin_moment_of_courage_buff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()

	self.hp_leech_percent = ability:GetSpecialValueFor('hp_leech_percent')

	if not IsServer() then return end
	self.parent = self:GetParent()
end

function modifier_paladin_moment_of_courage_buff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_paladin_moment_of_courage_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_paladin_moment_of_courage_buff:GetModifierAttackSpeedBonus_Constant()
	return 1000 
end

function modifier_paladin_moment_of_courage_buff:OnAttackLanded(data)
	if not IsServer() then return end
	local caster=self:GetCaster()
	if data.attacker == self.parent then
		EmitSoundOn("Hero_LegionCommander.Courage", caster)
		PlayEffOnUnit("particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf",caster)
		PlayEffOnUnit("particles/units/heroes/hero_legion_commander/legion_commander_courage_tgt.vpcf",data.target)
		Timers:CreateTimer(FrameTime(),function ()
			self:Destroy()
		end)
	end
end

function modifier_paladin_moment_of_courage_buff:OnTakeDamage( params )
	if IsServer() then
		if params.attacker == self:GetParent() and params.damage_category==DOTA_DAMAGE_CATEGORY_ATTACK then
			local heal = math.floor(params.damage *self.hp_leech_percent/100)
			-- self:GetParent():Heal( heal, self:GetAbility() )

			self:GetParent():HealWithParams(heal, self, true, true,self:GetCaster() , false)

			local effect_lifesteal = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(effect_lifesteal, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(effect_lifesteal)
			SendOverheadEventMessage( nil, OVERHEAD_ALERT_HEAL, self.parent, heal, nil )
		end
	end
end
