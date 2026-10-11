
alistar_headbutt = class({})
LinkLuaModifier( "modifier_alistar_headbutt_dash", "ability/alistar_headbutt", LUA_MODIFIER_MOTION_HORIZONTAL )

function alistar_headbutt:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local target = caster:GetCursorCastTarget()
	local point = target:GetOrigin()
    local modifier_movement = "modifier_alistar_headbutt_dash"
	local dash_range = ability:GetSpecialValueFor("range")
	
	if target:TriggerSpellAbsorb( self ) ~= nil then
        if target:TriggerSpellAbsorb( self ) then return end
    end
	
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
	
	--face toward target
	local direction = (point - caster:GetAbsOrigin()):Normalized()
	caster:SetForwardVector(direction)
	
	--Begin moving to target point
    caster:AddNewModifier(caster, ability, modifier_movement, {})

    --Pass the targeted point to the modifier
    local modifier_movement_handler = caster:FindModifierByName(modifier_movement)
    modifier_movement_handler.target_point = point
end

modifier_alistar_headbutt_dash = class({})
function modifier_alistar_headbutt_dash:OnCreated()
	if not IsServer() then return end
	--Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	
	local target = self.caster:GetCursorCastTarget()
	local point = target:GetOrigin()
	local startpoint = self.caster:GetOrigin()
	
	self.target = target --save target
	self.startpoint = startpoint --save starting point

	--Ability specials
	self.dash_speed = self.ability:GetSpecialValueFor("headbutt_speed")
	self.range = self.ability:GetSpecialValueFor("range")

	if IsServer() then

		--variables
		self.time_elapsed = 0

		--calculate distance
		self.distance = (self.caster:GetAbsOrigin() - point):Length2D()
		self.dash_time = self.distance / self.dash_speed
		self.direction = (point - self.caster:GetAbsOrigin()):Normalized()
		
		self:ApplyHorizontalMotionController()
	end
end

function modifier_alistar_headbutt_dash:IsHidden() return true end
function modifier_alistar_headbutt_dash:IsPurgable() return false end
function modifier_alistar_headbutt_dash:IsDebuff() return false end
function modifier_alistar_headbutt_dash:IgnoreTenacity() return true end
function modifier_alistar_headbutt_dash:IsMotionController() return true end
function modifier_alistar_headbutt_dash:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_alistar_headbutt_dash:UpdateHorizontalMotion( me, dt)
	if IsServer() then
		self.dash_time = self.distance / self.dash_speed
		-- Check if we're still dashing
		self.time_elapsed = self.time_elapsed + dt
		if self.time_elapsed < self.dash_time then

			-- Go forward
			local new_location = self.caster:GetAbsOrigin() + self.direction * self.dash_speed * dt
			self.caster:SetAbsOrigin(new_location)            
		else            
			self:Destroy()
		end
	end 
end
function modifier_alistar_headbutt_dash:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end
function modifier_alistar_headbutt_dash:OnRemoved()
	if IsServer() then
		local duration = self:GetAbility():GetSpecialValueFor("stun_duration")
		local distance = self:GetAbility():GetSpecialValueFor("knockback_distance")
		local damage = self:GetAbility():GetSpecialValueFor("damage")
		
		local knockbackProperties =
		{
			center_x = self.startpoint.x,
			center_y = self.startpoint.y,
			center_z = self.startpoint.z,
			duration = duration * (1-self.target:GetStatusResistance()),
			knockback_duration = 0.5,
			knockback_distance = distance,
			knockback_height = 0
		}
		
		local caster = self:GetParent()
		local ability = self:GetAbility()
		
		local damageTable = {
			victim = self.target,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability, --Optional.
		}
		
		if not self.target:IsMagicImmune() then
			self.target:RemoveModifierByName( "modifier_knockback" )
			self.target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_knockback", knockbackProperties )
			
			local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target )
			ParticleManager:SetParticleControl( effect_cast, 0, self.target:GetOrigin() )
			ParticleManager:ReleaseParticleIndex( effect_cast )
			EmitSoundOn( "Hero_Spirit_Breaker.GreaterBash", self.target )
			
			-- proc triumphant roar if a hero is hit
			local passiveproc = false
			passivestack = "modifier_triumph_stack"
			stacks = caster:GetModifierStackCount("modifier_triumph_stack", caster)
			if self.target:IsRealHero() and passiveproc == false then
				if caster:HasAbility( "alistar_triumphant_roar" ) then
					caster:FindAbilityByName( "alistar_triumphant_roar" ):Trigger()
				end
				passiveproc = true
			end
			
			ApplyDamage(damageTable)
		end
		
		if self.EndCallback then
		self.EndCallback()
		end
		
		self:GetParent():InterruptMotionControllers( true )
	end
end

function modifier_alistar_headbutt_dash:SetEndCallback( func ) 
	self.EndCallback = func
end
