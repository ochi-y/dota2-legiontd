if beast_berserkers_rage == nil then
	beast_berserkers_rage = class({
	})
end

LinkLuaModifier("modifier_beast_berserkers_rage", "ability/beast_berserkers_rage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_beast_berserkers_rage_debuff", "ability/beast_berserkers_rage", LUA_MODIFIER_MOTION_NONE)

beast_berserkers_rage = class({
	GetIntrinsicModifierName = function() return "modifier_beast_berserkers_rage" end
})

function beast_berserkers_rage:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		EmitSoundOn( "Hero_NagaSiren.Ensnare.Target", hTarget )
		local caster=self:GetCaster()
		--
		local duration=self:GetSpecialValueFor("ensnare_duration")
		local damage=self:GetSpecialValueFor("damage")

		duration = duration * (1 - CalUnitStatusResistance(hTarget))

		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_beast_berserkers_rage_debuff", {duration=duration})

		SimpleApplyDamage(self, caster, hTarget, damage)
	end
	return true
end

modifier_beast_berserkers_rage = class({
	IsHidden         = function(self) return true end,
	IsPurgable       = function(self) return false end,
	IsDebuff         = function(self) return false end,
	IsBuff           = function(self) return true end,
	DeclareFunctions = function()
		return {
			-- MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
			MODIFIER_EVENT_ON_ATTACK_LANDED
		}
	end
})

function modifier_beast_berserkers_rage:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.chance = ability:GetSpecialValueFor("ensnare_chance")
	self.damage = ability:GetSpecialValueFor("damage")
end

function modifier_beast_berserkers_rage:OnRefresh()
	self:OnCreated()
end

function modifier_beast_berserkers_rage:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	if RandomInt(1, 100)<=self.chance  then
		if params.attacker:PassivesDisabled() == false and (target:IsHero() or target:IsCreep()) then

			local caster=self:GetParent()
			EmitSoundOn("n_creep_TrollWarlord.Ensnare", target)
			-- target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", { duration = duration })
			local projectile = 
			{
				Target                 = target,
				Source                 = caster,
				Ability             = self:GetAbility(),
				EffectName             = "particles/units/heroes/hero_troll_warlord/troll_warlord_bersekers_net_projectile.vpcf",
				iMoveSpeed            = 1450,
				vSpawnOrigin         = caster:GetAbsOrigin(),
				bDrawsOnMinimap     = false,
				bDodgeable             = true,
				bIsAttack             = false,
				bVisibleToEnemies     = true,
				bReplaceExisting     = false,
				bProvidesVision     = false,
				iSourceAttachment     = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1 ,
			}
			ProjectileManager:CreateTrackingProjectile(projectile)

		end
	end
end

-- function modifier_beast_berserkers_rage:GetModifierProcAttack_BonusDamage_Physical()
-- 	local chance = self.chance

-- 	self.bashed = RandomInt(1, 100) <= chance
-- 	if self.bashed then
-- 		return self.chance
-- 	end
-- 	return 0
-- end

---------------------------------------------------------------------
--Modifiers
if modifier_beast_berserkers_rage_debuff == nil then
	modifier_beast_berserkers_rage_debuff = class({})
end
function modifier_beast_berserkers_rage_debuff:OnCreated(params)
	if IsServer() then
	end
end
function modifier_beast_berserkers_rage_debuff:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_beast_berserkers_rage_debuff:OnDestroy()
	if IsServer() then
	end
end
function modifier_beast_berserkers_rage_debuff:DeclareFunctions()
	return {
	}
end
function modifier_beast_berserkers_rage_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_FLYING] = false,
	}
end

function modifier_beast_berserkers_rage_debuff:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_bersekers_net_main.vpcf"
end

function modifier_beast_berserkers_rage_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
