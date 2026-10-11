LinkLuaModifier( "modifier_building_farm_ambient", "ability/building_farm_ambient.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if building_farm_ambient == nil then
	building_farm_ambient = class({})
end
function building_farm_ambient:GetIntrinsicModifierName()
	return "modifier_building_farm_ambient"
end
---------------------------------------------------------------------
--Modifiers
if modifier_building_farm_ambient == nil then
	modifier_building_farm_ambient = class({})
end
function modifier_building_farm_ambient:OnCreated(params)
	if IsServer() then
		Timers:CreateTimer(0.1,function ()
			local caster=self:GetCaster()
			caster:StartGesture(ACT_DOTA_IDLE)
		end)
	end
end

function modifier_building_farm_ambient:IsHidden()
	return true
end
function modifier_building_farm_ambient:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_building_farm_ambient:OnDestroy()
	if IsServer() then
	end
end
function modifier_building_farm_ambient:DeclareFunctions()
	return {
	}
end
-- function modifier_building_farm_ambient:GetEffectName()
-- 	return "particles/neutral_fx/miniboss_shield.vpcf"
-- end
-- function modifier_building_farm_ambient:GetEffectAttachType()
-- 	return PATTACH_POINT_FOLLOW
-- end


