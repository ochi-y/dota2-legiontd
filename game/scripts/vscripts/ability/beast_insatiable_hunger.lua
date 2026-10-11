LinkLuaModifier("modifier_beast_insatiable_hunger", "ability/beast_insatiable_hunger", LUA_MODIFIER_MOTION_NONE)

beast_insatiable_hunger = class({})


function beast_insatiable_hunger:OnSpellStart()
	if not IsServer() then return end
	
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_beast_insatiable_hunger", {duration = self:GetSpecialValueFor("duration")})
end

modifier_beast_insatiable_hunger = class({})
function modifier_beast_insatiable_hunger:IsHidden() return false end
function modifier_beast_insatiable_hunger:IsPurgable() return false end
function modifier_beast_insatiable_hunger:IsPurgeException() return false end
function modifier_beast_insatiable_hunger:RemoveOnDeath() return false end

function modifier_beast_insatiable_hunger:OnCreated()
	if not self:GetAbility() then return end
	self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
    self.lifesteal_pct = self.ability:GetSpecialValueFor("lifesteal_pct")

	if not IsServer() then return end

	local caster=self:GetCaster()

	local effect=ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_hunger_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc",
	caster:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControl(effect, 1, Vector(500,500,500))
	-- ParticleManager:ReleaseParticleIndex(effect)
	self:AddParticle(effect, false, false, -1, false, false)  
	self:GetCaster():EmitSound("Hero_Broodmother.InsatiableHunger")   

end

function modifier_beast_insatiable_hunger:OnRefresh()
	if not self:GetAbility() then return end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
    self.lifesteal_pct = self.ability:GetSpecialValueFor("lifesteal_pct")

	if not IsServer() then return end
end
function modifier_beast_insatiable_hunger:OnDestroy()
	
	if not IsServer() then return end
	self:GetCaster():StopSound("Hero_Broodmother.InsatiableHunger")
end
function modifier_beast_insatiable_hunger:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end
function modifier_beast_insatiable_hunger:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_beast_insatiable_hunger:OnTakeDamage( params )
	if IsServer() then
		if params.attacker == self:GetParent() and params.damage_category==DOTA_DAMAGE_CATEGORY_ATTACK  then
			local heal = params.damage * self.lifesteal_pct/100
			-- self:GetParent():Heal( heal, self:GetAbility() )
			self:GetParent():HealWithParams(heal, self:GetAbility(), true, true,self:GetParent() , false)
			local effect_lifesteal = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(effect_lifesteal, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(effect_lifesteal)
		end
	end
end
-- function modifier_beast_insatiable_hunger:GetEffectName()
-- 	return "particles/units/heroes/hero_broodmother/broodmother_hunger_buff.vpcf"
-- end
-- function modifier_beast_insatiable_hunger:GetEffectAttachType()
-- 	return PATTACH_POINT_FOLLOW
-- end
