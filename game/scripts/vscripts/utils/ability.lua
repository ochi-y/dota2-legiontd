function CreateDummy(pid, point, duration)
    duration = duration or 10
    local hero = PlayerResource:GetSelectedHeroEntity(pid)
    local creep = CreateUnitByName("npc_dota_custom_dummy_unit", point, true, hero, hero, DOTA_TEAM_GOODGUYS)
    creep:AddNewModifier(nil, nil, "modifier_kill", {
        duration = duration
    })
    return creep
end

function AoeDamage(ability, pos, radius, damage, params)
    local maxCount = params.maxCount

    local caster = ability:GetCaster()
    local team = caster:GetTeamNumber()
    local units = FindAbilityTarget(ability, pos, radius, {})

    local c = 0

    for _, unit in ipairs(units) do
        SimpleApplyDamage(ability, caster, unit, damage, ability:GetAbilityDamageType())
        -- SimpleApplyDamage(ability, caster, unit, damage,DAMAGE_TYPE_MAGICAL)
        c = c + 1
        if maxCount and c >= maxCount then
            break
        end
    end
end

function FindAbilityTarget(ability, point, radius, params)
    local findFlag = ability:GetAbilityTargetFlags()
    if params.findFlag then
        findFlag = params.findFlag
    end
    local findTeam = ability:GetAbilityTargetTeam()
    if params.findTeam then
        findTeam = params.findTeam
    end
    local findType = ability:GetAbilityTargetType()
    if params.findType then
        findType = params.findType
    end
    local findOrder = FIND_CLOSEST
    if params.findOrder then
        findOrder = params.findOrder
    end
    local caster = ability:GetCaster()
    local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, findTeam, findType, findFlag, findOrder,
        false)
    return units
end

function CalUnitStatusResistance(unit)
    if not IsActiveUnit(unit) then
        return 0
    end
    local baseStatus = 0
    local stackStatusList = {}
    for _, modifier in ipairs(unit:FindAllModifiers()) do
        local modifier_name = modifier:GetName()
        if modifier.GetModifierStatusResistance and modifier:GetModifierStatusResistance() then
            baseStatus = math.max(baseStatus, modifier:GetModifierStatusResistance())
        end
        if modifier.GetModifierStatusResistanceStacking and modifier:GetModifierStatusResistanceStacking() then
            table.insert(stackStatusList, math.max(0, math.min(100, modifier:GetModifierStatusResistanceStacking())))
        end
    end
    table.insert(stackStatusList, baseStatus)
    local res = 1
    for _, value in ipairs(stackStatusList) do
        res = res * (1 - value / 100)
    end
    res = 1 - res
    return res
end

function SimpleUnitFilter(ability, target)
    local nResult = UnitFilter(target, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
        ability:GetAbilityTargetFlags(), ability:GetCaster():GetTeamNumber())
    return nResult == UF_SUCCESS
end

function SimpleApplyDamage(ability, attacker, target, damage, damageType, damage_flags)
    if damageType == nil then
        if ability then
            damageType = ability:GetAbilityDamageType()
            if damageType == 0 then
                damageType = DAMAGE_TYPE_MAGICAL
            end
        else
            damageType = DAMAGE_TYPE_MAGICAL
        end
    end

    if damage_flags == nil then
        damage_flags = DOTA_DAMAGE_FLAG_NONE
    end

    local damageTable = {
        victim = target,
        attacker = attacker,
        damage = damage,
        damage_type = damageType,
        ability = ability,
        damage_flags = damage_flags
    }
    ApplyDamage(damageTable)
end

function SimpleStun(ability, target, duration)
    local caster = ability:GetCaster()
    -- unit:AddNewModifier(nil, nil, "modifier_stunned", {
    --     duration = duration
    -- })
    local d = duration * (1 - CalUnitStatusResistance(target))
    target:AddNewModifier(caster, ability, "modifier_stunned", { duration = d })
end

function SimpleFindAttackTarget(team, point, radius)
    local units = FindUnitsInRadius(team, point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
    return units
end

function SimpleFindEnemy(team, point, radius, findFlag)
    findFlag = findFlag or 0
    local units = FindUnitsInRadius(team, point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, findFlag, false)
    return units
end

function SimpleFindUnits(point, radius, findFlag)
    findFlag = findFlag or 0
    local units = FindUnitsInRadius(0, point, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, findFlag, false)
    return units
end

function SimpleFindEnemyInLine(team, startPoint, endPoint, length)
    local units = FindUnitsInLine(team, startPoint, endPoint, nil, length, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE)
    return units
end

function SimpleFindFriend(team, point, radius, findType)
    if not findType then
        findType = 0
    end
    local units = FindUnitsInRadius(team, point, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES +
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE, findType, false)
    return units
end

function SimpleFindOneClosestEnemy(team, point, radius)
    local units = FindUnitsInRadius(team, point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
    if #units > 0 then
        return units[1]
    else
        return nil
    end
end

function SimpleFindOneRandomEnemy(team, point, radius, flag)
    if flag == nil then
        flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local units = FindUnitsInRadius(team, point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    if #units > 0 then
        return units[RandomInt(1, #units)]
    else
        return nil
    end
end

-- splash attack
function splashAttack(attacker, victim, radiusTable, ability, params)
    if not params then
        params = {}
    end

    local damagePos=nil
    if params.pos then
        damagePos=params.pos
    else
        damagePos=victim:GetAbsOrigin()
    end
    

    local affectedTable = {}
    for key, v in pairs(radiusTable) do
        local radius = v.radius
        local damage = v.damage
        --
        local targets = FindUnitsInRadius(attacker:GetTeamNumber(), damagePos, nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
        --
        for _, target in pairs(targets) do
            local bAffect = true
            if target == victim then
                bAffect = false
            end
            if params.groundOnly and target:HasFlyMovementCapability() then
                bAffect = false
            end
            if TableContainsValue(affectedTable, target) then
                bAffect = false
            end
            if bAffect then
                table.insert(affectedTable, target)
                local damageTable = {
                    victim = target,
                    attacker = attacker,
                    damage = damage * SimpleGetAttackFactor(attacker, target),
                    damage_type = DAMAGE_TYPE_PHYSICAL
                }
                ApplyDamage(damageTable)
            end
        end
    end
end

function circleCleaveAttack(attacker, victim, pos, radius, damage, ability, params)
    if not params then
        params = {}
    end
    local targets = FindUnitsInRadius(attacker:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    --
    local effect = nil
    local hitParticle = params.hitParticle
    if params.particle then
        effect = ParticleManager:CreateParticle(params.particle, PATTACH_ABSORIGIN_FOLLOW, attacker)
        ParticleManager:SetParticleControlEnt(effect, 0, attacker, PATTACH_ABSORIGIN_FOLLOW, nil,
            attacker:GetAbsOrigin(), true)
        -- ParticleManager:SetParticleControl(effect, 1, Vector(500,500,500))
        -- ParticleManager:ReleaseParticleIndex(effect)
    end
    local c = 0
    for index, target in ipairs(targets) do
        local bAffect = true
        if target == victim then
            bAffect = false
        end
        if params.groundOnly and target:HasFlyMovementCapability() then
            bAffect = false
        end
        if bAffect then
            local damageTable = {
                victim = target,
                attacker = attacker,
                damage = damage * SimpleGetAttackFactor(attacker, target),
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = ability
            }
            ApplyDamage(damageTable)
            c = c + 1
            if effect then
                ParticleManager:SetParticleControlEnt(effect, c, target, PATTACH_ABSORIGIN_FOLLOW, nil,
                    attacker:GetAbsOrigin(), true)
            end
            if hitParticle then
                PlayEffOnUnit(hitParticle, target, { bind = PATTACH_POINT_FOLLOW, attach = "attach_hitloc", cps = { 0, 1 } })
            end
        end
    end
    if effect then
        ParticleManager:ReleaseParticleIndex(effect)
    end
end

function addNewModiferWithStack(target, hCaster, hAbility, modifierName, hModifierTable, params)
    if not target:HasModifier(modifierName) then
        target:AddNewModifier(hCaster, hAbility, modifierName, hModifierTable)
        local modifier = target:FindModifierByName(modifierName)
        modifier:SetStackCount(1)
    else
        local oldModifier = target:FindModifierByName(modifierName)
        local count = oldModifier:GetStackCount()
        target:RemoveModifierByName(modifierName)
        --
        target:AddNewModifier(hCaster, hAbility, modifierName, hModifierTable)
        local modifier = target:FindModifierByName(modifierName)
        modifier:SetStackCount(count + 1)
    end
end

function SimpleTrackingToPoint(startPos, targetPos, eff, speed, zOffsetAmount, callBack)
    if speed < 0 then
        return
    end
    -- create projectile
    eff = eff or "particles/humanstd/mojianshi_longpaojishe2.vpcf"
    local particle = ParticleManager:CreateParticle(eff, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, startPos)
    ParticleManager:SetParticleControl(particle, 1, targetPos)
    ParticleManager:SetParticleControl(particle, 2, Vector(speed, 0, 0))
    if callBack then
        local timeFactor = 0.00043393 * math.pow(zOffsetAmount, 4) - 0.00908846 * math.pow(zOffsetAmount, 3) +
            0.05335304 * math.pow(zOffsetAmount, 2) + 0.02642311 * math.pow(zOffsetAmount, 1) +
            0.99965564
        local time = (targetPos - startPos):Length() / speed
        time = timeFactor * time
        Timers:CreateTimer(time, function()
            callBack()
            ParticleManager:DestroyParticle(particle, false)
        end)
    end
end

function SimpleTrackingProjectile(ability, source, target, eff, speed, params)
    if not IsActiveUnit(source) then
        return
    end
    -- create projectile
    eff = eff or "particles/units/heroes/hero_techies/techies_base_attack.vpcf"
    local info = {
        Target = target,
        Source = source,
        Ability = ability,
        EffectName = eff,
        iMoveSpeed = speed,
        bDodgeable = false,                                      -- Optional
        bVisibleToEnemies = true,                                -- Optional
        bProvidesVision = true,                                  -- Optional
        iVisionRadius = 100,                                     -- Optional
        iVisionTeamNumber = ability:GetCaster():GetTeamNumber(), -- Optional
        ExtraData = {}
    }

    if params then
        for k, v in pairs(params) do
            info[k] = v
        end
    end

    ProjectileManager:CreateTrackingProjectile(info)
end

function SimpleLinearProjectile(ability, eff, fromPoint, toPoint, speed, startEadius, endRadius, kv)
    local distance = (toPoint - fromPoint):Length2D()
    local forward_v = (toPoint - fromPoint):Normalized()
    eff = eff or "particles/base_attacks/ranged_tower_bad_linear.vpcf"
    forward_v.z = 0
    local info = {
        Ability = ability,
        EffectName = eff,
        vSpawnOrigin = fromPoint + Vector(0, 0, 100),
        fDistance = distance,
        fStartRadius = startEadius or 100,
        fEndRadius = endRadius or startEadius or 100,
        Source = ability:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        --  fExpireTime         = ,
        bDeleteOnHit = false,
        vVelocity = speed * forward_v,
        bProvidesVision = true,
        iVisionRadius = 10
        --  iVisionTeamNumber   = caster:GetTeamNumber(),
    }
    if kv then
        for k, v in pairs(kv) do
            info[k] = v
        end
    end
    ProjectileManager:CreateLinearProjectile(info)
end

function OnZhaoHuan(unitname, owner, pos, team, duration, level, eff)
    local tUnit = CreateUnitByName(unitname, pos, true, owner, owner, team)

    if not tUnit then
        return print("error create unit " .. (unitname or ""))
    end

    if owner:GetLevel() > tUnit:GetLevel() then
        print("CreatureLevelUp")
        tUnit:CreatureLevelUp(1)
    end

    tUnit.isInDefense = owner.isInDefense
    SimpleMoveUnit(tUnit, pos)
    --tUnit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
    -- tUnit:SetOwner(owner)
    --tUnit:SetControllableByPlayer(owner:GetPlayerOwnerID(), true)
    tUnit:SetForwardVector((owner:GetForwardVector()):Normalized())
    -- keep it from being blocked
    -- tUnit:AddNewModifier(owner, nil, "modifier_phased", {
    --     duration = 0.1
    -- })
    if duration and duration ~= -1 then
        tUnit:AddNewModifier(owner, nil, "modifier_kill", {
            duration = duration
        })
    end
    local angle_now = owner:GetAnglesAsVector()
    tUnit:SetAngles(angle_now.x, angle_now.y, angle_now.z)
    if level then
        for i = tUnit:GetLevel() + 1, level do
            tUnit:CreatureLevelUp(1)
        end
    end

    if not owner:IsRealHero() then
        local pid = owner:GetPlayerOwnerID()
        if pid >= 0 then
            local hero = PlayerResource:GetSelectedHeroEntity(pid)
            tUnit:SetOwner(hero)
        end
    end

    if eff ~= "null" then
        eff = eff or "particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf"
        local particle = SimpleCreateParticle(eff, tUnit)
        SimpleSetControlEnt(particle, 0, tUnit, PATTACH_POINT_FOLLOW)
        SimpleReleaseParticle(particle)
    end

    copyCreepStack(owner, tUnit)

    return tUnit
end

function alignAngle(unit1, unit2)
    if unit1 and unit2 then
        local angle_now = unit2:GetAnglesAsVector()
        unit1:SetAngles(angle_now.x, angle_now.y, angle_now.z)
    end
end
