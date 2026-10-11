LinkLuaModifier( "modifier_king_hit_points_x2", "ability/king_hit_points_x2.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if king_hit_points_x2 == nil then
	king_hit_points_x2 = class({})
end

function king_hit_points_x2:OnAbilityPhaseStart()
	local caster=self:GetCaster()
	
	local king=GamePlay.kingGood
	if caster:GetTeamNumber()==DOTA_TEAM_BADGUYS then
		king=GamePlay.kingBad
	end
	if king:IsNull() or (not king:IsAlive()) then
		return false
	end
	local maxStack=self:GetSpecialValueFor("max_level")
	local pid=caster:GetPlayerOwnerID()
	local mod=king:FindModifierByName("modifier_king_hit_points_x2") 

	if mod and mod:GetStackCount()>=maxStack then
		SendErrorMessage(pid,"level_max")
		return false
	end
	local res = teckTree:UseResource(self:GetCaster(), self, nil, {

	})
	return res
end


function king_hit_points_x2:OnSpellStart()
	if not IsServer() then return end
	--
	local caster=self:GetCaster()
	local king=GamePlay.kingGood
	if caster:GetTeamNumber()==DOTA_TEAM_BADGUYS then
		king=GamePlay.kingBad
	end
	if king:IsNull() or (not king:IsAlive()) then
		return
	end
	local pid=caster:GetPlayerOwnerID()
	local mod=king:FindModifierByName("modifier_king_hit_points_x2") 
	--

	local maxStack=20
	local upStackCount=1
	-- if GamePlay.secondaryModes["x2"] then
	-- 	maxStack=2*maxStack
	-- 	-- upStackCount=2*upStackCount
	-- end
	--
	if not king:HasModifier("modifier_king_hit_points_x2") then
		king:AddNewModifier(caster, self, "modifier_king_hit_points_x2", {})
		local modifier=king:FindModifierByName("modifier_king_hit_points_x2") 
		modifier:SetStackCount(upStackCount)
	else
		local oldModifier=king:FindModifierByName("modifier_king_hit_points_x2") 
		local count=oldModifier:GetStackCount()
		king:RemoveModifierByName("modifier_king_hit_points_x2")
		--
		king:AddNewModifier(caster, self, "modifier_king_hit_points_x2", {})
		local modifier=king:FindModifierByName("modifier_king_hit_points_x2") 
		modifier:SetStackCount(count+upStackCount)
	end
	--
	local mod=king:FindModifierByName("modifier_king_hit_points_x2") 
	local level=mod:GetStackCount()
	local h=450+(level-1)*25

	-- if GamePlay.secondaryModes["x2"] then
	-- 	h=math.min(925,h)
	-- end

	Player:ModifyIncome(pid, 3)

	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, king, h, nil)

	SimpleAddHealth(king,h)
	fireLeftNotify(pid, true, "notify_upgrade_king_hit_points_x2", {})


	EmitSoundOnLocationForAllies(caster:GetAbsOrigin(),"ui.trophy_levelup", caster)

	if ENABLE_BUILDING_PARTICLE then
		SimplePlayEffOnUnit(caster,"particles/econ/events/ti10/hero_levelup_ti10.vpcf")
		SimplePlayEffOnUnit(king,"particles/econ/events/ti10/hero_levelup_ti10.vpcf")
		EmitSoundOnLocationForAllies(king:GetAbsOrigin(),"ui.trophy_levelup", king)
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_king_hit_points_x2 == nil then
	modifier_king_hit_points_x2 = class({})
end
function modifier_king_hit_points_x2:OnCreated(params)
	if IsServer() then
	end
end
function modifier_king_hit_points_x2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_king_hit_points_x2:OnDestroy()
	if IsServer() then
	end
end
function modifier_king_hit_points_x2:IsPurgable(params)
	return false
end