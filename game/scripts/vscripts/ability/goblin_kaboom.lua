LinkLuaModifier("modifier_goblin_kaboom", "ability/goblin_kaboom.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities

goblin_kaboom = class({})

goblin_kaboom_1=goblin_kaboom  
goblin_triple_attack=goblin_kaboom   

function goblin_kaboom:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self:explode()
	if not IsCustomBuilding(caster) then
		-- caster:ForceKill(false)
		caster:Kill(nil,caster)
	end
end

function goblin_kaboom:explode()
	local caster = self:GetCaster()
    --
	local radius=self:GetSpecialValueFor("radius")
	local max_affect_count=self:GetSpecialValueFor("max_affect_count")
	

    EmitSoundOn("Hero_Techies.StickyBomb.Detonate", caster)
    local nFXIndex2 = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(nFXIndex2, 0, caster:GetOrigin())
    ParticleManager:SetParticleControl(nFXIndex2, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(nFXIndex2)

    local nTeam = DOTA_UNIT_TARGET_TEAM_ENEMY

    local entities = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, radius, nTeam,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	local damage=self:GetSpecialValueFor("damage")
	entities=UTIL:filterByFlying(entities,false)

	for i = 1, max_affect_count, 1 do
		if entities[i] then
			SimpleApplyDamage(self, caster, entities[i], damage)
		end
	end
end

function goblin_kaboom:GetIntrinsicModifierName()
	return "modifier_goblin_kaboom"
end

modifier_goblin_kaboom = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_goblin_kaboom:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end
function modifier_goblin_kaboom:OnDeath( params )
	if IsServer() then
		if params.unit == self:GetCaster() and params.attacker~=self:GetCaster() then


			local caster=self:GetCaster()
			local pos = caster:GetAbsOrigin()
			local ability=self:GetAbility()
			ability:explode()
		end
	end
	return 0
end
