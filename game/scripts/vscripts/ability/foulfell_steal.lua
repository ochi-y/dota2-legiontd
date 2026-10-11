LinkLuaModifier("modifier_foulfell_steal", "ability/foulfell_steal.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if foulfell_steal == nil then
	foulfell_steal = class({})
end

foulfell_steal_2 = foulfell_steal


function foulfell_steal:GetIntrinsicModifierName()
	return "modifier_foulfell_steal"
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_steal = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return false
	end,
	IsBuff = function(self)
		return true
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_foulfell_steal:AllowIllusionDuplicate()
	return false
end

function modifier_foulfell_steal:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.chance = ability:GetSpecialValueFor("chance")
	self.gold_steal = ability:GetSpecialValueFor("gold_steal")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_foulfell_steal:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_steal:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_foulfell_steal:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end

	local caster = self:GetCaster()
	local target = params.target    
	local playerId = caster:GetPlayerOwnerID()

	if RandomInt(1, 100) <= self.chance then   
		print("steal",self.gold_steal)  
		EmitSoundOnLocationForPlayer("General.CoinsBig", target:GetAbsOrigin(), caster:GetPlayerOwnerID())
		PopupGoldGain(caster, math.floor(self.gold_steal), {
			-- team = PlayerResource:GetTeam(playerID)
		})
		Player:ModifyGold(playerId, self.gold_steal)
		-- 
		local effect=ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(effect, 1, caster, PATTACH_POINT, nil,
		caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(effect)

	end
	-- local target = params.target
	-- if self.bashed  then
	-- 	if params.attacker:PassivesDisabled() == false and (target:IsHero() or target:IsCreep()) then
	-- 		local duration=1
	-- 		-- EmitSoundOn("DOTA_Item.SkullBasher", target)

	-- 		duration = duration * (1 - CalUnitStatusResistance(target))

	-- 		target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = duration})
	-- 	end
	-- end
end

function modifier_foulfell_steal:CheckState()
	local state = {
	}
	return state
end
