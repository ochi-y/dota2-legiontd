ghost_nightmare = class({
    layout_main = true,
})

LinkLuaModifier( "modifier_ghost_nightmare_debuff", "ability/ghost_nightmare", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function ghost_nightmare:OnSpellStart()

	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end


	local duration=self:GetSpecialValueFor("duration")

	duration = duration * (1 - CalUnitStatusResistance(target))
	
	self.modifier = target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_ghost_nightmare_debuff", -- modifier name
		{ duration = self:GetSpecialValueFor("duration") } -- kv
    )
    
    target:AddNewModifier(
		target,
		self, -- ability source
		"modifier_invulnerable", -- modifier name
		{ duration = self:GetSpecialValueFor( "nightmare_invuln_time" ) } -- kv
	)

	-- local end_ability = caster:FindAbilityByName( "ghost_nightmare_end" )
	-- if not end_ability then
	-- 	end_ability = caster:AddAbility( "ghost_nightmare_end" )
	-- 	self.add = end_ability
	-- end
    -- end_ability:SetLevel( 1 )
	-- end_ability.parentAbility = self

	-- set layout
    -- self:SetLayout( false )
    
    -- self:SetHidden(true)
   -- end_ability:SetHidden(false)
end

function ghost_nightmare:EndNightmare( forced )
	-- remove modifier
	if forced and self.modifier and not self.modifier:IsNull()  then
		self.modifier:Destroy()
	end
	self.modifier = nil
	--self:SetLayout( true )
	-- if self.add then
	-- 	self:GetCaster():RemoveAbility( "ghost_nightmare_end" )
    -- end
    
end

--------------------------------------------------------------------------------
-- Hero Events
function ghost_nightmare:OnOwnerDied()
	 self:EndNightmare( true )
end



modifier_ghost_nightmare_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ghost_nightmare_debuff:IsHidden()
	return false
end

function modifier_ghost_nightmare_debuff:IsDebuff()
	return true
end

function modifier_ghost_nightmare_debuff:IsStunDebuff()
	return false
end

function modifier_ghost_nightmare_debuff:IsPurgable()
	return true
end

function modifier_ghost_nightmare_debuff:CanParentBeAutoAttacked()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ghost_nightmare_debuff:OnCreated( kv )

	if not self:GetAbility() then return end

	-- references
	self.anim_rate = self:GetAbility():GetSpecialValueFor( "animation_rate" )
	self.transfer = self:GetAbility():GetSpecialValueFor( "transfer" )

	if IsServer() then
		self.invulnerable = true

		-- play sound
		local sound_cast = "Hero_Bane.Nightmare"
		local sound_loop = "Hero_Bane.Nightmare.Loop"
		EmitSoundOn( sound_cast, self:GetParent() )
		EmitSoundOn( sound_loop, self:GetParent() )
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("nightmare_invuln_time"))
	end
end

function modifier_ghost_nightmare_debuff:OnRefresh( kv )
	
end

function modifier_ghost_nightmare_debuff:OnRemoved()
end

function modifier_ghost_nightmare_debuff:OnDestroy()
	if not IsServer() then return end
	-- stop sound
	local sound_loop = "Hero_Bane.Nightmare.Loop"
	StopSoundOn( sound_loop, self:GetParent() )

	if not self.transfer then
		-- play end sound
		local sound_stop = "Hero_Bane.Nightmare.End"
		EmitSoundOn( sound_stop, self:GetParent() )
		self:GetAbility():EndNightmare( false )
	end
	if IsActiveUnit(self:GetParent()) then
		UTIL:addUnitTag(self:GetParent(), "ghost_nightmare", 3)
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ghost_nightmare_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,

		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_ghost_nightmare_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function modifier_ghost_nightmare_debuff:GetOverrideAnimationRate()
	return self.anim_rate
end

function modifier_ghost_nightmare_debuff:OnAttackLanded( params )
	if not IsServer() then return end
	if params.target~=self:GetParent() then return end

	if params.attacker==self:GetCaster() then
		return
	end
	
	-- if self.transfer==1 then
	-- 	if not params.attacker:IsMagicImmune() then
	-- 		-- transfer
	-- 		local modifier = params.attacker:AddNewModifier(
	-- 			self:GetCaster(), -- player source
	-- 			self:GetAbility(), -- ability source
	-- 			"modifier_ghost_nightmare_debuff", -- modifier name
	-- 			{ duration = self:GetDuration() } -- kv
	-- 		)
	
	-- 		self:GetAbility().modifier = modifier
	-- 		self.transfer = true
	-- 	end
	-- end
	self:Destroy()
end
function modifier_ghost_nightmare_debuff:OnTakeDamage( params )
	if not IsServer() then return end
	if params.unit~=self:GetParent() then return end
	if params.damage_category==DOTA_DAMAGE_CATEGORY_SPELL then
		self:Destroy()
	end
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_ghost_nightmare_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = self.invulnerable,
		[MODIFIER_STATE_NIGHTMARED] = true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_SPECIALLY_DENIABLE] = true
	}
	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_ghost_nightmare_debuff:OnIntervalThink()
	self.invulnerable = false
	self:StartIntervalThink(-1)
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ghost_nightmare_debuff:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_nightmare.vpcf"
end

function modifier_ghost_nightmare_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end