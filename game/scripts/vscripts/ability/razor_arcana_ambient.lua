LinkLuaModifier( "modifier_razor_arcana_ambient", "ability/razor_arcana_ambient.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if razor_arcana_ambient == nil then
	razor_arcana_ambient = class({})
end
function razor_arcana_ambient:GetIntrinsicModifierName()
	return "modifier_razor_arcana_ambient"
end
---------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_razor_arcana_ambient = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_razor_arcana_ambient:IsHidden()
	return true
end

function modifier_razor_arcana_ambient:IsPurgable()
	return false
end

function modifier_razor_arcana_ambient:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_razor_arcana_ambient:OnCreated( kv )
	if IsServer() then
		-- Create Ambient
		--self:PlayEffects1( kv.style )
		self:GetParent():StartGestureWithPlaybackRate( ACT_DOTA_SPAWN, 1.1 )

		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_razor_arcana", {})

		local parent=self:GetParent()
		
		for _,child in pairs(parent:GetChildren()) do
			print(child:GetClassname())
			if child:GetClassname() == "dota_item_wearable" then
				child:SetSkin(2)
			end
		end
	end
end

function modifier_razor_arcana_ambient:OnRefresh( kv )
	if IsServer() then
		-- self:GetParent():RemoveNoDraw()
		self:GetParent():StartGestureWithPlaybackRate( ACT_DOTA_SPAWN, 1.1 )
	end
end

function modifier_razor_arcana_ambient:OnRemoved()
end

function modifier_razor_arcana_ambient:OnDestroy()
	if IsServer() then
	end
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_razor_arcana_ambient:DeclareFunctions()
	local funcs = {
	   -- MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	   MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end



function modifier_razor_arcana_ambient:GetAttackSound()
    return "Hero_Razor.Attack.Arcana"
end
function modifier_razor_arcana_ambient:GetActivityTranslationModifiers()
    return "teal"
end

function modifier_razor_arcana_ambient:OnDeath( params )
	if params.unit~=self:GetParent() then return end
	--self:GetParent():SetOrigin( self:GetParent():GetOrigin() - Vector( 0,0,1000 ) )
end

