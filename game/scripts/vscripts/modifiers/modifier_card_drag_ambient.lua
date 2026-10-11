if modifier_card_drag_ambient == nil then
	modifier_card_drag_ambient = class({})
end

-- local modifier_card_drag_ambient = modifier_card_drag_ambient

function modifier_card_drag_ambient:IsHidden()
	return true
end

function modifier_card_drag_ambient:IsDebuff()
	return false
end

function modifier_card_drag_ambient:IsPurgable()
	return false
end

function modifier_card_drag_ambient:IsPurgeException()
	return false
end

function modifier_card_drag_ambient:AllowIllusionDuplicate()
	return false
end

function modifier_card_drag_ambient:RemoveOnDeath()
	return true
end

function modifier_card_drag_ambient:DestroyOnExpire()
	return true
end

function modifier_card_drag_ambient:IsPermanent()
	return false
end

function modifier_card_drag_ambient:OnCreated(params)
	if IsServer() then
		self:OnRefresh(params)
	end
end

function modifier_card_drag_ambient:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_card_drag_ambient:OnDestroy()
	if IsServer() then
	end
end



function modifier_card_drag_ambient:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function modifier_card_drag_ambient:StatusEffectPriority()
	return 3
end

function modifier_card_drag_ambient:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = false,
		[MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_BLIND]=true
	}
end

function modifier_card_drag_ambient:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}
end

function modifier_card_drag_ambient:GetModifierInvisibilityLevel()
	return 1
end

function modifier_card_drag_ambient:GetOverrideAnimation(params)
	return ACT_DOTA_IDLE
end

function modifier_card_drag_ambient:GetOverrideAnimationRate(params)
	return 1
end

function modifier_card_drag_ambient:GetVisualZDelta(params)
	return 0
end
