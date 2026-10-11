LinkLuaModifier( "modifier_king_hit_points", "ability/king_hit_points.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if king_hit_points == nil then
	king_hit_points = class({})
end

king_hit_points_x2=king_hit_points

function king_hit_points:OnAbilityPhaseStart()
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
	local mod=king:FindModifierByName("modifier_king_hit_points") 

	if mod and mod:GetStackCount()>=maxStack then
		SendErrorMessage(pid,"level_max")
		return false
	end
	local res = teckTree:UseResource(self:GetCaster(), self, nil, {
	})
	return res
end

function king_hit_points:OnSpellStart()
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
	local max_bonus_hp=self:GetSpecialValueFor("max_bonus_hp")

	local pid=caster:GetPlayerOwnerID()
	
	local upStackCount=1

	if not king:HasModifier("modifier_king_hit_points") then
		king:AddNewModifier(caster, self, "modifier_king_hit_points", {})
		local modifier=king:FindModifierByName("modifier_king_hit_points") 
		modifier:SetStackCount(upStackCount)
	else
		local oldModifier=king:FindModifierByName("modifier_king_hit_points") 
		local count=oldModifier:GetStackCount()
		king:RemoveModifierByName("modifier_king_hit_points")
		--
		king:AddNewModifier(caster, self, "modifier_king_hit_points", {})
		local modifier=king:FindModifierByName("modifier_king_hit_points") 
		modifier:SetStackCount(count+upStackCount)
	end
	--
	local mod=king:FindModifierByName("modifier_king_hit_points") 
	local level=mod:GetStackCount()
	local h=450+(level-1)*25
	h=math.min(max_bonus_hp,h)
	Player:ModifyIncome(pid, 3)

	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, king, h, nil)

	SimpleAddHealth(king,h)
	fireLeftNotify(pid, true, "notify_upgrade_king_hit_points", {})


	EmitSoundOnLocationForAllies(caster:GetAbsOrigin(),"ui.trophy_levelup", caster)

	if ENABLE_BUILDING_PARTICLE then
		SimplePlayEffOnUnit(caster,"particles/econ/events/ti10/hero_levelup_ti10.vpcf")
		SimplePlayEffOnUnit(king,"particles/econ/events/ti10/hero_levelup_ti10.vpcf")
		EmitSoundOnLocationForAllies(king:GetAbsOrigin(),"ui.trophy_levelup", king)
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_king_hit_points == nil then
	modifier_king_hit_points = class({})
end
function modifier_king_hit_points:OnCreated(params)
	if IsServer() then
	end
end
function modifier_king_hit_points:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_king_hit_points:OnDestroy()
	if IsServer() then
	end
end
function modifier_king_hit_points:IsPurgable(params)
	return false
end