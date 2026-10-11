LinkLuaModifier( "modifier_king_attack", "ability/king_attack.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if king_attack == nil then
	king_attack = class({})
end

king_attack_x2=king_attack

function king_attack:OnSpellStart()
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
	local mod=king:FindModifierByName("modifier_king_attack") 
	--

	local maxStack=self:GetSpecialValueFor("max_level")
	local upStackCount=1

	if mod and mod:GetStackCount()>=maxStack then
		SendErrorMessage(pid,"level_max")
		return
	end
	--
	if teckTree:UseResource(caster, self)  then
		if not king:HasModifier("modifier_king_attack") then
			king:AddNewModifier(caster, self, "modifier_king_attack", {})
			local modifier=king:FindModifierByName("modifier_king_attack") 
            modifier:SetStackCount(upStackCount)
		else
			local oldModifier=king:FindModifierByName("modifier_king_attack") 
			local count=oldModifier:GetStackCount()
			king:RemoveModifierByName("modifier_king_attack")
			--
			king:AddNewModifier(caster, self, "modifier_king_attack", {})
			local modifier=king:FindModifierByName("modifier_king_attack") 
            modifier:SetStackCount(count+upStackCount)
		end
		--
		local mod=king:FindModifierByName("modifier_king_attack") 
		local level=mod:GetStackCount()
		Player:ModifyIncome(pid, 3)
		fireLeftNotify(pid, true, "notify_upgrade_king_attack", {})
		-- 
		EmitSoundOnLocationForAllies(caster:GetAbsOrigin(),"ui.trophy_levelup", caster)
		-- 
		if ENABLE_BUILDING_PARTICLE then
			SimplePlayEffOnUnit(caster,"particles/econ/events/ti7/hero_levelup_ti7.vpcf")
			SimplePlayEffOnUnit(king,"particles/econ/events/ti7/hero_levelup_ti7.vpcf")
			EmitSoundOnLocationForAllies(king:GetAbsOrigin(),"ui.trophy_levelup", king)
		end
		--

	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_king_attack == nil then
	modifier_king_attack = class({})
end
function modifier_king_attack:OnCreated(params)
	if IsServer() then
	end
end
function modifier_king_attack:IsPurgable(params)
	return false
end
function modifier_king_attack:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_king_attack:OnDestroy()
	if IsServer() then
	end
end
function modifier_king_attack:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end
function modifier_king_attack:GetModifierPreAttack_BonusDamage( params )
	return 10*self:GetStackCount()
end