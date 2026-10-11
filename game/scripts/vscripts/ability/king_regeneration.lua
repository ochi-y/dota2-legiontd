LinkLuaModifier( "modifier_king_regeneration", "ability/king_regeneration.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if king_regeneration == nil then
	king_regeneration = class({})
end

king_regeneration_x2=king_regeneration

function king_regeneration:OnSpellStart()
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
	local mod=king:FindModifierByName("modifier_king_regeneration") 
	--
	local maxStack=self:GetSpecialValueFor("max_level")
	local upStackCount=1

	if mod and mod:GetStackCount()>=maxStack then
		SendErrorMessage(pid,"level_max")
		return
	end
	--
	if teckTree:UseResource(caster, self)  then
		if not king:HasModifier("modifier_king_regeneration") then
			king:AddNewModifier(caster, self, "modifier_king_regeneration", {})
			local modifier=king:FindModifierByName("modifier_king_regeneration") 
            modifier:SetStackCount(upStackCount)
		else
			local oldModifier=king:FindModifierByName("modifier_king_regeneration") 
			local count=oldModifier:GetStackCount()
			king:RemoveModifierByName("modifier_king_regeneration")
			--
			king:AddNewModifier(caster, self, "modifier_king_regeneration", {})
			local modifier=king:FindModifierByName("modifier_king_regeneration") 
            modifier:SetStackCount(count+upStackCount)
		end
		--
		local mod=king:FindModifierByName("modifier_king_regeneration") 
		local level=mod:GetStackCount()
		Player:ModifyIncome(pid, 3)
		fireLeftNotify(pid, true, "notify_upgrade_king_regeneration", {})

		
		EmitSoundOnLocationForAllies(caster:GetAbsOrigin(),"ui.trophy_levelup", caster)

		if ENABLE_BUILDING_PARTICLE then
			SimplePlayEffOnUnit(caster,"particles/econ/events/ti8/hero_levelup_ti8.vpcf")
			SimplePlayEffOnUnit(king,"particles/econ/events/ti8/hero_levelup_ti8.vpcf")
			EmitSoundOnLocationForAllies(king:GetAbsOrigin(),"ui.trophy_levelup", king)
		end

	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_king_regeneration == nil then
	modifier_king_regeneration = class({})
end
function modifier_king_regeneration:OnCreated(params)
	if IsServer() then
	end
end
function modifier_king_regeneration:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_king_regeneration:IsPurgable(params)
	return false
end
function modifier_king_regeneration:OnDestroy()
	if IsServer() then
	end
end
function modifier_king_regeneration:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
end
function modifier_king_regeneration:GetModifierConstantHealthRegen( params )
	return 5*self:GetStackCount()
end
function modifier_king_regeneration:GetModifierConstantManaRegen()
	return 1*self:GetStackCount()
end