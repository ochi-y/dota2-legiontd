if modifier_card_drag_move == nil then
	modifier_card_drag_move = class({})
end

local public = modifier_card_drag_move

function public:IsHidden()
	return true
end

function public:IsDebuff()
	return false
end

function public:IsPurgable()
	return false
end

function public:IsPurgeException()
	return false
end

function public:AllowIllusionDuplicate()
	return false
end

function public:RemoveOnDeath()
	return true
end

function public:DestroyOnExpire()
	return true
end

function public:IsPermanent()
	return false
end

function public:OnCreated(params)
	if IsServer() then
		if not self:ApplyHorizontalMotionController() or not self:ApplyVerticalMotionController() then
			self:Destroy()
			return
		end
		self:OnRefresh(params)
	end
end

function public:OnRefresh(params)
	if IsServer() then
		self.vPos = Vector(params.pos_x, params.pos_y, params.pos_z)
		self.radius = params.radius
	end
end

function public:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController(self)
		self:GetParent():RemoveVerticalMotionController(self)
	end
end

function public:UpdateHorizontalMotion(hParent, dt)
	if IsServer() then
		hParent:SetAbsOrigin(self.vPos + Vector(0, 0, self:GetVisualZDelta()))
	end
end

function public:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function public:UpdateVerticalMotion(hParent, dt)
	if IsServer() then
		hParent:SetAbsOrigin(self.vPos + Vector(0, 0, self:GetVisualZDelta()))
		--local angle = VectorToAngles(self:GetCaster():GetFightingVector())
        -- local angle = VectorToAngles(self:GetCaster():GetFightingVector())
		-- hParent:SetAbsAngles(angle[1], angle[2], angle[3])
	end
end

function public:OnVerticalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function public:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function public:StatusEffectPriority()
	return 100
end

function public:CheckState()
	return {
		
	}
end

function public:DeclareFunctions()
	return {
		
	}
end

function public:GetModifierInvisibilityLevel()
	return 1
end

function public:GetOverrideAnimation(params)
	return ACT_DOTA_IDLE
end

function public:GetOverrideAnimationRate(params)
	return 1
end

function public:GetVisualZDelta(params)
	return 0
end
