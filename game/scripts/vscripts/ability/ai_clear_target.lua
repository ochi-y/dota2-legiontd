LinkLuaModifier( "modifier_ai_clear_target", "ability/ai_clear_target.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ai_clear_target == nil then
	ai_clear_target = class({})
end
function ai_clear_target:OnSpellStart()
	local caster=self:GetCaster()

	local meta=GamePlay:FighterGetMeta(caster.fighterId)

	if meta then
		meta.abilityTargetMap={}
		EmitSoundOn("DOTA_Item.DiffusalBlade.Target", caster)
		PlayEffOnUnit("particles/generic_gameplay/generic_purge.vpcf",caster)
	end
end
