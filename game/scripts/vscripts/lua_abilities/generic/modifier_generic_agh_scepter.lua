modifier_generic_agh_scepter = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_agh_scepter:GetTexture()
	return "spell/ultimate_scepter_tease"
end

function modifier_generic_agh_scepter:IsHidden()
	return false
end
function modifier_generic_agh_scepter:IsPurgable()
	return false
end
function modifier_generic_agh_scepter:IsDebuff()
	return false
end
function modifier_generic_agh_scepter:IsStunDebuff()
	return false
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_agh_scepter:OnCreated( kv )
	if not IsServer() then return end
end

function modifier_generic_agh_scepter:OnRefresh( kv )
end

function modifier_generic_agh_scepter:OnRemoved()
end

function modifier_generic_agh_scepter:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_generic_agh_scepter:DeclareFunctions()
	local funcs = {
	}
	return funcs
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_generic_agh_scepter:GetEffectName()
	return "particles/items4_fx/scepter_aura.vpcf"
end

function modifier_generic_agh_scepter:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end