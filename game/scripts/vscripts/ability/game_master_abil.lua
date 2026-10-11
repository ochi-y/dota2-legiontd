LinkLuaModifier( "modifier_game_master_abil", "ability/game_master_abil.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if game_master_abil == nil then
	game_master_abil = class({})
end
function game_master_abil:GetIntrinsicModifierName()
	return "modifier_game_master_abil"
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_game_master_abil = class({
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
function modifier_game_master_abil:AllowIllusionDuplicate()
	return false
end
function modifier_game_master_abil:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 

	if not self:GetAbility() then return end
	if not IsServer() then return end
	print("game_master_abil init")
end
function modifier_game_master_abil:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_game_master_abil:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end
function modifier_game_master_abil:OnTakeDamage(params)

	-- local victim=params.unit
	
	-- if victim then
	-- 	print("health123",victim:GetHealth())
	-- end
end
