
goblin_blast_off = class({})
LinkLuaModifier("modifier_goblin_blast_off_assistcheck", "ability/goblin_blast_off", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_goblin_blast_off_timer", "ability/goblin_blast_off", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_goblin_blast_off_slow", "ability/goblin_blast_off", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "lua_abilities/generic/modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH)



goblin_blast_off_1=goblin_blast_off
goblin_blast_off_2=goblin_blast_off

function goblin_blast_off:GetAOERadius()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	return radius
end
function goblin_blast_off:GetIntrinsicModifierName()
    return "modifier_goblin_blast_off_assistcheck"
end
function goblin_blast_off:OnSpellStart()
	if not IsServer() then return end




	local caster = self:GetCaster()

	self.oldPos=caster:GetAbsOrigin()


	local duration = self:GetSpecialValueFor("jump_duration")
	--local slow_duration = self:GetSpecialValueFor("slow_duration")
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius")
	local unit_count = self:GetSpecialValueFor("unit_count")
	if unit_count==0 or unit_count==nil then
		unit_count=100
	end
	local height = 450
	local target = self:GetCursorPosition()
	local distance = (target-caster:GetOrigin()):Length2D()
	EmitSoundOn("Hero_Techies.BlastOff.Cast", caster)
	-- local knockback = caster:AddNewModifier(
	-- 	caster, -- player source
	-- 	self, -- ability source
	-- 	"modifier_generic_knockback_lua", -- modifier name
	-- 	{
	-- 		distance = distance,
	-- 		height = height,
	-- 		duration = duration,
	-- 		direction_x = direction.x,
	-- 		direction_y = direction.y,
	-- 		IsStun = false,
	-- 	} -- kv
	-- )
			
	local costTime=duration

	local point=target 

	local speed=distance/costTime
	local height=math.max(100, distance/2)

	self.arc = self:GetCaster():AddNewModifier(self.caster, -- player source
	self, -- ability source
	"modifier_generic_arc_lua", -- modifier name
	{
		target_x = point.x,
		target_y = point.y,
		speed = speed,
		distance = distance,
		height = height,
		fix_end = true,
		-- fix_duration = false,
		 isStun = true,
		isRestricted = false,
		isForward = true,
		--activity = ACT_DOTA_OVERRIDE_ABILITY_1,
		stoppedByTerrain = false
	} -- kv
	)

	PlayEffOnUnit("particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf",
        caster, {
            mod = self.arc
        })

	self.arc:SetEndCallback(function(interrupted)
		if not interrupted then
			-- precache damage
		local damageTable = {
			-- victim = target,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
		}

		-- find enemies
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			caster:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		enemies=subrange(enemies,1,unit_count)
		for _,enemy in pairs(enemies) do
			-- apply damage
			if not enemy:IsMagicImmune() and not enemy:HasFlyMovementCapability()  then
				damageTable.victim = enemy
				ApplyDamage(damageTable)

				-- -- stun
				-- enemy:AddNewModifier(
				-- 	self:GetCaster(), -- player source
				-- 	self, -- ability source
				-- 	"modifier_goblin_blast_off_slow", -- modifier name
				-- 	{ duration = slow_duration } -- kv
				-- )
			end
		end
		GridNav:DestroyTreesAroundPoint( target, 160, true )
		if IsActiveBuilding(caster) then
			print("move")
			Timers:CreateTimer(FrameTime(),function ()
				caster:SetAbsOrigin(self.oldPos)
				SimpleMoveUnit(caster,self.oldPos)		
			end)
			
		end
		
		self:PlayEffects( caster, radius )
		end
	end)
	
end
function goblin_blast_off:PlayEffects( target, radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf"
	local sound_location = "Hero_Techies.Suicide"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_location, target )
end

modifier_goblin_blast_off_slow = class({})
function modifier_goblin_blast_off_slow:IsDebuff() return true end
function modifier_goblin_blast_off_slow:IsHidden() return false end
function modifier_goblin_blast_off_slow:IsPurgable() return true end
function modifier_goblin_blast_off_slow:DeclareFunctions()
    local decFuns =
    {
    }
    return decFuns
end

modifier_goblin_blast_off_assistcheck = class({})
function modifier_goblin_blast_off_assistcheck:IsDebuff() return false end
function modifier_goblin_blast_off_assistcheck:IsHidden() return true end
function modifier_goblin_blast_off_assistcheck:IsPurgable() return false end
function modifier_goblin_blast_off_assistcheck:IsPurgeException() return false end
function modifier_goblin_blast_off_assistcheck:RemoveOnDeath() return false end
function modifier_goblin_blast_off_assistcheck:DeclareFunctions()
    local decFuns =
    {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
		-- MODIFIER_EVENT_ON_DEATH
		
    }
    return decFuns
end
function modifier_goblin_blast_off_assistcheck:OnTakeDamage( params )
	
	if not IsServer() then return end

	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = params.target if target == nil then target = params.unit end
	local attacker = params.attacker
	
	-- if attacker == caster and target:IsRealHero() and target:GetTeamNumber() ~= caster:GetTeamNumber() then
	-- 	target:AddNewModifier(caster, ability, "modifier_goblin_blast_off_timer", {duration = ability:GetSpecialValueFor("reset_timer")})
	-- end
end
function modifier_goblin_blast_off_assistcheck:OnDeath( params )
	
	if not IsServer() then return end

	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = params.target if target == nil then target = params.unit end
	local attacker = params.attacker
	
	-- if (attacker:GetTeamNumber() == caster:GetTeamNumber() and target:HasModifier("modifier_goblin_blast_off_timer")) or (target:IsRealHero() and target:GetTeamNumber() ~= caster:GetTeamNumber() and attacker == caster) then
	-- 	ability:EndCooldown()
	-- end
end

-- modifier_goblin_blast_off_timer = class({})
-- function modifier_goblin_blast_off_timer:IsDebuff() return false end
-- function modifier_goblin_blast_off_timer:IsHidden() return true end
-- function modifier_goblin_blast_off_timer:IsPurgable() return false end
-- function modifier_goblin_blast_off_timer:IsPurgeException() return false end