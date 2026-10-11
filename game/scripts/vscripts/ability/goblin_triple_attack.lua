LinkLuaModifier("modifier_goblin_triple_attack", "ability/goblin_triple_attack.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if goblin_triple_attack == nil then
    goblin_triple_attack = class({})
end
function goblin_triple_attack:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self:explode()

	if not IsCustomBuilding(caster) then
		caster:Kill(nil,caster)
	end
end

function goblin_triple_attack:explode()
	local caster = self:GetCaster()
    --
	local radius=self:GetSpecialValueFor("radius")

    EmitSoundOn("Hero_Techies.StickyBomb.Detonate", caster)
    local nFXIndex2 = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(nFXIndex2, 0, caster:GetOrigin())
    ParticleManager:SetParticleControl(nFXIndex2, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(nFXIndex2)

    local nTeam = DOTA_UNIT_TARGET_TEAM_ENEMY

    local entities = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, radius, nTeam,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)


		local damage=self:GetSpecialValueFor("damage")

    if #entities > 0 then
        for _, entity in pairs(entities) do
			if not entity:HasFlyMovementCapability() then
				SimpleApplyDamage(self, caster, entity, damage)
			end
        end
    end
end

function goblin_triple_attack:GetIntrinsicModifierName()
	return "modifier_goblin_triple_attack"
end

modifier_goblin_triple_attack = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_goblin_triple_attack:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end
function modifier_goblin_triple_attack:OnDeath( params )
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
