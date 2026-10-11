

function createSandbag(keys)
    --PrintTable(keys)
    local caster = keys.caster
    if not caster:IsHero() then
        return
    end
    local point=keys.target_points[1]
    local ability=keys.ability
    if ability.sandbagIndex then
        -- local sandbag = EntIndexToHScript(ability.sandbagIndex)
        -- if sandbag then
        --     sandbag:ForceKill(false)
        -- end
        -- ability.sandbagIndex=nil
    end
    local hero=PlayerResource:GetSelectedHeroEntity(0)
    local creep = CreateUnitByName("npc_dota_sandbag", point, true, hero, hero, DOTA_TEAM_BADGUYS)
	creep:SetControllableByPlayer(caster:GetPlayerID(), true)
    creep:AddNewModifier(caster, nil, "modifier_phased", {duration=0.1})
	creep:AddNewModifier(caster, nil, "modifier_kill", {duration=6000})
    creep:AddNewModifier(caster, nil, "modifier_deniable", {})
    
    local angle_now = caster:GetAnglesAsVector()
	creep:SetAngles(angle_now.x,angle_now.y, angle_now.z)

    ability.sandbagIndex=creep:entindex()
    EmitSoundOn("DOTA_Item.SentryWard.Activate", creep)
end

function item_test_spawn(keys)
    PrintTable(keys)
    local caster = keys.caster
    local point=keys.target_points[1]
    local ability=keys.ability
    local particle_cast = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, caster:GetAbsOrigin() )
	local names={
        
    }

	for i, name in ipairs(names) do
        local hero=PlayerResource:GetSelectedHeroEntity(0)
        local creep = CreateUnitByName(name, point+ Vector(100*i,0,0), true, hero, hero, DOTA_TEAM_BADGUYS)
		if creep then
			creep:SetControllableByPlayer(caster:GetPlayerID(), true)
        	creep:AddNewModifier(caster, nil, "modifier_phased", {duration=0.1})	
		end
	end
end

function item_test_spawn_good(keys)
    PrintTable(keys)
    local caster = keys.caster
    local point=keys.target_points[1]
    local ability=keys.ability
    local particle_cast = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, caster:GetAbsOrigin() )
	local names={
        
    }

	for i, name in ipairs(names) do
        local hero=PlayerResource:GetSelectedHeroEntity(0)
        local creep = CreateUnitByName(name, point+ Vector(100*i,0,0), true, hero, hero, DOTA_TEAM_GOODGUYS)
		if creep then
			creep:SetControllableByPlayer(caster:GetPlayerID(), true)
        	creep:AddNewModifier(caster, nil, "modifier_phased", {duration=0.1})	
		end
	end
end

