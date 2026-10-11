LinkLuaModifier( "modifier_building_town_ambient", "ability/building_town_ambient.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if building_town_ambient == nil then
	building_town_ambient = class({})
end
function building_town_ambient:GetIntrinsicModifierName()
	return "modifier_building_town_ambient"
end

function building_town_ambient:Spawn()

	if not IsServer() then return end
	
end
---------------------------------------------------------------------
--Modifiers
if modifier_building_town_ambient == nil then
	modifier_building_town_ambient = class({})
end
function modifier_building_town_ambient:OnCreated(params)
	if IsServer() then

		-- Timers:CreateTimer(0.1,function ()
		-- 	local caster=self:GetCaster()
		-- 	--caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)
			
		-- end)

		-- Timers:CreateTimer(1,function ()
		-- 	local caster=self:GetCaster()
		-- 	PlayEffOnUnit("particles/world_outpost/world_outpost_radiant_ambient.vpcf",caster,{
		-- 		cpUnit = {
		-- 			[0] = {caster, PATTACH_POINT_FOLLOW, "attach_fx"}
		-- 		},
		-- 		mod=self
		-- 	})
		-- end)
	end
end
function modifier_building_town_ambient:IsHidden()
	return true
end
function modifier_building_town_ambient:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_building_town_ambient:OnDestroy()
	if IsServer() then
	end
end
function modifier_building_town_ambient:DeclareFunctions()
	return {
		
	}
end
-- function modifier_building_town_ambient:GetEffectName()
-- 	return "particles/world_outpost/world_outpost_radiant_ambient.vpcf"
-- end
-- function modifier_building_town_ambient:GetEffectAttachType()
-- 	return PATTACH_POINT_FOLLOW
-- end


