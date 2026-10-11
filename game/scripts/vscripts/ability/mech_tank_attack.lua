LinkLuaModifier( "modifier_mech_tank_attack", "ability/mech_tank_attack.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mech_tank_attack == nil then
	mech_tank_attack = class({})
end
function mech_tank_attack:GetIntrinsicModifierName()
	return "modifier_mech_tank_attack"
end
---------------------------------------------------------------------
--Modifiers
if modifier_mech_tank_attack == nil then
	modifier_mech_tank_attack = class({})
end
function modifier_mech_tank_attack:OnCreated(params)
	if IsServer() then
	end
end
function modifier_mech_tank_attack:IsPurgable(params)
	return false
end
function modifier_mech_tank_attack:IsHidden(params)
	return true
end

function modifier_mech_tank_attack:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_mech_tank_attack:OnDestroy()
	if IsServer() then
	end
end
function modifier_mech_tank_attack:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START
	}
end

function modifier_mech_tank_attack:OnAttackStart(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	local attacker =params.attacker
	attacker:StartGesture(ACT_DOTA_CAST_ABILITY_1)

	--EmitSoundOn("Item_Desolator.Target", attacker)
	-- StartAnimation(attacker, {
	-- 	duration = 10,
	-- 	activity = ACT_DOTA_CAST_ABILITY_1,
	-- 	rate = 2
	-- })
end