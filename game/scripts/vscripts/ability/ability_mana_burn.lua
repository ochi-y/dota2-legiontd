ability_mana_burn = class({})

wave_7_champion_mana_burn=ability_mana_burn
--------------------------------------------------------------------------------
function ability_mana_burn:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb(self) then return end

    EmitSoundOn("Hero_NyxAssassin.ManaBurn.Cast", caster)

    EmitSoundOn("Hero_NyxAssassin.ManaBurn.Target", target)

	PlayEffOnUnit("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_start.vpcf",caster,{
		attach="attach_hand"
	})

    local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(fx)   
    local mana = target:GetMana()
	local mana_drained=self:GetSpecialValueFor("mana_drained")
	if mana>mana_drained then
		mana=mana_drained
	end
    local damage = mana 
    local damageTable = {
        victim = target,
        attacker = caster, 
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self
    }
    ApplyDamage(damageTable) 
    target:Script_ReduceMana(mana,self)
    SendOverheadEventMessage( target, OVERHEAD_ALERT_MANA_LOSS, target, damage, nil )
end