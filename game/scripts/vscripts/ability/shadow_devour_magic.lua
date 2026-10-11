--Abilities
if shadow_devour_magic == nil then
	shadow_devour_magic = class({})
end

LinkLuaModifier("modifier_shadow_devour_magic", "ability/shadow_devour_magic.lua", LUA_MODIFIER_MOTION_NONE)

function shadow_devour_magic:OnSpellStart()
	local caster = self:GetCaster()

	local pos = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local missle_speed = self:GetSpecialValueFor("missle_speed")

	local summoned_unit_damage = self:GetSpecialValueFor("summoned_unit_damage")


	EmitSoundOnLocationWithCaster(pos, "Hero_ObsidianDestroyer.EssenceFlux.Cast", caster)


	local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)

	EmitSoundOn("Hero_KeeperOfTheLight.ManaLeak.Cast", caster)

	PlayEffOnLocation("particles/units/heroes/hero_brewmaster/brewmaster_dispel_magic.vpcf",pos,{
		cpKv={
			[1]=Vector(radius, radius, radius)
		}
	})

	local vision_radius = 0

	for _, target in ipairs(units) do
		local buffs = UTIL:findDispellableBuffs(target, true, true)
		local debuffs = UTIL:findDispellableBuffs(target, false, true)

		if #buffs > 0 or #debuffs > 0 then
			target:Purge(true, true, false, false, false)
			local proj = "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_base_attack.vpcf"
			local info = {
				Target            = caster,
				Source            = target,
				Ability           = self,
				EffectName        = proj,
				bDodgeable        = false,
				bIsAttack         = false,
				bProvidesVision   = false,
				iMoveSpeed        = missle_speed,
				vSpawnOrigin      = caster:GetAbsOrigin(),
				iVisionRadius     = vision_radius,
				iVisionTeamNumber = caster:GetTeamNumber(),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				ExtraData         = {
					sourceIndex = target:entindex(),
				}
			}
			ProjectileManager:CreateTrackingProjectile(info)
			PlayEffOnUnit("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_matter_debuff.vpcf", target)
		end
		if target:IsSummoned() then
			SimpleApplyDamage(self, caster, target, summoned_unit_damage)
			PlayEffOnUnit("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_matter_debuff.vpcf", target)
		end
	end
end

function shadow_devour_magic:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function shadow_devour_magic:OnProjectileHit_ExtraData(Target, Location, extraData)
	if Target ~= nil and extraData.sourceIndex then
		local source = EntIndexToHScript(extraData.sourceIndex)
		local caster = self:GetCaster()
		-- local life_per_buff=self:GetSpecialValueFor("life_per_buff")
		-- local mana_per_buff=self:GetSpecialValueFor("mana_per_buff")
		-- caster:GiveMana(mana_per_buff)
		-- caster:Heal(life_per_buff, self)
		PlayEffOnUnit("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf", caster)

		local mod=caster:AddNewModifier(caster, self, "modifier_shadow_devour_magic", {
			duration=self:GetSpecialValueFor("duration")
		})
		mod:IncrementStackCount()

	end
	return false
end

-------------------------------------------------------------------------------------------------------
modifier_shadow_devour_magic = class({
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
function modifier_shadow_devour_magic:AllowIllusionDuplicate()
	return false
end

function modifier_shadow_devour_magic:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
	if not IsServer() then return end
end

function modifier_shadow_devour_magic:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_shadow_devour_magic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE 
	}
end
function modifier_shadow_devour_magic:GetModifierPreAttack_BonusDamage(params)
	return self:GetStackCount()*self.bonus_damage
end

function modifier_shadow_devour_magic:GetEffectName()
	return "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_matter_buff.vpcf"
end

function modifier_shadow_devour_magic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end







