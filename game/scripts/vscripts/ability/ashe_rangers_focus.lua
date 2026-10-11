
ashe_rangers_focus = class({})

LinkLuaModifier("modifier_ashe_rangers_focus_active", "ability/ashe_rangers_focus", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_generic_outgoing_damage", "lua_abilities/generic/modifier_generic_outgoing_damage", LUA_MODIFIER_MOTION_NONE)

function ashe_rangers_focus:GetIntrinsicModifierName()
	if self:GetLevel()>0 then
		return "modifier_ashe_rangers_focus_active"
	end
end

function ashe_rangers_focus:Spawn()
	self.multiShot=true
end

function ashe_rangers_focus:OnProjectileHit( target, location)
	-- cancel if gone
	if (not target) or target:IsInvulnerable() or target:IsOutOfGame() then
		return
	end
	local caster = self:GetCaster()
	self.multiShot=false
	--self:GetCaster():AddNewModifier(caster, self, "modifier_generic_outgoing_damage", {duration=FrameTime(),outgoing_damage=-75})
	SimplePerformAttack(self:GetCaster(),target,false,true,false)
	-- caster:RemoveModifierByNameAndCaster("modifier_generic_outgoing_damage",caster)
	self.multiShot=true
end

modifier_ashe_rangers_focus_active = class({})
function modifier_ashe_rangers_focus_active:IsDebuff() return false end
function modifier_ashe_rangers_focus_active:IsHidden() return false end
function modifier_ashe_rangers_focus_active:IsPurgable() return true end
function modifier_ashe_rangers_focus_active:OnCreated()
	self.splitattack = true
	

end
function modifier_ashe_rangers_focus_active:DeclareFunctions()		
	local funcs = {
		-- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		-- MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_EVENT_ON_ATTACK,
		--MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		--MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}					 
	return funcs
end

-- function modifier_ashe_rangers_focus_active:GetAttackSound()
--     return "Hero_DrowRanger.Attack.Arcana"
-- end


-- function modifier_ashe_rangers_focus_active:GetModifierProjectileSpeedBonus()
-- 	return 500
-- end

function modifier_ashe_rangers_focus_active:GetEffectName()
	return "particles/units/heroes/hero_drow/drow_aura_buff.vpcf"
end
function modifier_ashe_rangers_focus_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_ashe_rangers_focus_active:OnAttack( params )
	if IsServer()  then
		local caster = self:GetCaster()
		local target = params.target
		local attacks = self:GetAbility():GetSpecialValueFor("flurry") 
		local ability = self:GetAbility()

		if not ability.multiShot then
			return
		end
		-- if params.attacker == caster and self.splitattack == true then
		-- 	local enemies = FindUnitsInRadius(
		-- 		caster:GetTeamNumber(),	-- int, your team number
		-- 		caster:GetOrigin(),	-- point, center point
		-- 		nil,	-- handle, cacheUnit. (not known)
		-- 		caster:Script_GetAttackRange( ),	-- float, radius. or use FIND_UNITS_EVERYWHERE
		-- 		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		-- 		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		-- 		0,	-- int, flag filter
		-- 		FIND_CLOSEST,	-- int, order filter
		-- 		false	-- bool, can grow cache
		-- 	)
		-- 	local targets = self:GetAbility():GetSpecialValueFor("scepter_targets")
		-- 	for _,enemy in pairs(enemies) do
		-- 		if enemy ~= target and targets > 0 then
		-- 			self.splitattack = false
		-- 			caster:PerformAttack(enemy, false, true, true, false, true, false, false)
		-- 			PerformAttack(hTarget, bUseCastAttackOrb, bProcessProcs, bSkipCooldown, bIgnoreInvis, bUseProjectile, bFakeAttack, bNeverMiss)
		-- 			targets = targets - 1
		-- 			self.splitattack = true
		-- 		end
		-- 	end
		-- end
	
		if params.attacker == caster then
			for i = 1, attacks, 1 do
				Timers:CreateTimer(i * 0.12, function()
					local info = {
						Target = target,
						Source = caster,
						Ability = ability,	
						EffectName = "particles/units/heroes/hero_mirana/mirana_base_attack.vpcf",
						iMoveSpeed = caster:GetProjectileSpeed(),
						bDodgeable = true,                           -- Optional
						bVisibleToEnemies = true,                         -- Optional
					}
					ProjectileManager:CreateTrackingProjectile(info)
				end)
			end
		end
	end
end
