modifier_hero_glow = class({})
-----------------------------------------------------------------------
function modifier_hero_glow:IsHidden()
	return true
end

-----------------------------------------------------------------------

function modifier_hero_glow:IsPurgable()
	return false
end

-----------------------------------------------------------------------

function modifier_hero_glow:OnCreated(params)
	if IsServer() then
		local parent=self:GetParent()

		print("modifier_hero_glow:OnCreated")
		local kv = GetUnitKeyValuesByName(self:GetParent():GetUnitName())
		local color = Vector(244, 242, 147)
		-- if kv.HeroGlowColor then
        --     print("HeroGlowColor",kv.HeroGlowColor)
		-- 	local strs = mysplit(kv.HeroGlowColor, " ")
		-- 	color = Vector(tonumber(strs[1]), tonumber(strs[2]), tonumber(strs[3]))
		-- 	-- color = Vector(255,0,0)
		-- end
		local effect = ParticleManager:CreateParticle("particles/gameplay/hero_ground_light.vpcf",
			PATTACH_ABSORIGIN_FOLLOW,
			parent)
		ParticleManager:SetParticleControlEnt(effect, 0, parent, PATTACH_ABSORIGIN_FOLLOW, nil,
			parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(effect, 1, color)
		-- ParticleManager:ReleaseParticleIndex(effect)
		self:AddParticle(effect, false, false, -1, false, false)
	end
end
