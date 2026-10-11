var kv3tojs = require('./lib/kv3parser');
const fs = require('fs');
var obj2kv1 = require('./lib/obj2kv1');
let path = require('path');

// Race to generate building abilities for (leave null to process every normal race)
// Example: const TARGET_RACE = "arctic" or const TARGET_RACE = null
const TARGET_RACE = null

function toFiniteNumber(value, defaultValue = 0) {
    const numberValue = Number(value)
    return Number.isFinite(numberValue) ? numberValue : defaultValue
}

function finiteFixed(value, digits, defaultValue = 0) {
    return toFiniteNumber(value, defaultValue).toFixed(digits)
}

function parseKv3(file) {
    let content = fs.readFileSync(file, { encoding: 'utf8' });
    return kv3tojs.parse(content);
}

function getUnitFileSuffix(filePath) {
    const match = path.basename(filePath).match(/^npc_units_(.*)\.txt$/)
    return match ? match[1] : null
}

function loadOtherUnitsTree() {
    const otherUnitsTreePath = "./scripts/data/metas/other_units_tree.json"
    if (!fs.existsSync(otherUnitsTreePath)) {
        return { trees: [] }
    }

    return JSON.parse(fs.readFileSync(otherUnitsTreePath, { encoding: 'utf8' }))
}

function buildUnitFileIndex() {
    const unitDir = "./game/scripts/npc/units"
    const unitFiles = fs.readdirSync(unitDir)
        .filter(fileName => fileName.endsWith(".txt"))
        .map(fileName => path.join(unitDir, fileName))

    let unitToFiles = {}
    let fileCache = {}

    for (const filePath of unitFiles) {
        const suffix = getUnitFileSuffix(filePath)
        if (!suffix) {
            continue
        }

        const unitsKvData = parseKv3(filePath)
        const unitsKv = unitsKvData.DOTAUnits || {}

        fileCache[suffix] = {
            suffix,
            filePath,
            unitsKvData,
            unitsKv
        }

        for (const unitName in unitsKv) {
            if (!unitToFiles[unitName]) {
                unitToFiles[unitName] = []
            }
            unitToFiles[unitName].push(fileCache[suffix])
        }
    }

    return { unitToFiles, fileCache }
}

function findRootUnitFile(rootUnitName, unitFileIndex) {
    const matches = unitFileIndex.unitToFiles[rootUnitName] || []

    if (matches.length === 0) {
        console.error(`Error: root unit ${rootUnitName} was not found under game/scripts/npc/units`)
        process.exit(1)
    }

    if (matches.length > 1) {
        console.error(`Error: root unit ${rootUnitName} appears in several unit files: ${matches.map(match => match.filePath).join(", ")}`)
        process.exit(1)
    }

    return matches[0]
}

function groupOtherUnitTreesByFile(otherUnitsTreeData, unitFileIndex) {
    let groups = {}
    const trees = Array.isArray(otherUnitsTreeData.trees) ? otherUnitsTreeData.trees : []

    for (const tree of trees) {
        if (!tree.name) {
            continue
        }

        const unitFile = findRootUnitFile(tree.name, unitFileIndex)

        if (TARGET_RACE && TARGET_RACE !== unitFile.suffix) {
            continue
        }

        if (!groups[unitFile.suffix]) {
            groups[unitFile.suffix] = {
                raceName: unitFile.suffix,
                trees: [],
                unitFile
            }
        }

        groups[unitFile.suffix].trees.push(tree)
    }

    return groups
}

// Recursively collect every unit of a tree, flagging base units and remembering the parent unit
function collectUnitsFromTree(tree, isBase = true, parentUnit = null) {
    let units = []

    if (tree.name) {
        units.push({
            name: tree.name,
            isBase: isBase,
            parentUnit: parentUnit  // name of the parent unit
        })
    }

    if (tree.upgrades && Array.isArray(tree.upgrades)) {
        for (const upgrade of tree.upgrades) {
            units = units.concat(collectUnitsFromTree(upgrade, false, tree.name))
        }
    }

    return units
}

// Collect the direct upgrades of one unit
function collectUpgrades(tree) {
    let upgrades = []
    if (tree.upgrades && Array.isArray(tree.upgrades)) {
        for (const upgrade of tree.upgrades) {
            if (upgrade && upgrade.name) {
                upgrades.push(upgrade.name)
            }
        }
    }
    return upgrades
}

// Build the unit -> upgrade list map
function buildUnitUpgradesMap(race) {
    let unitUpgradesMap = {}

    function processTree(node) {
        if (node.name) {
            let upgrades = collectUpgrades(node)
            unitUpgradesMap[node.name] = upgrades
        }
        if (node.upgrades && Array.isArray(node.upgrades)) {
            for (const upgrade of node.upgrades) {
                if (upgrade && upgrade.name) {
                    processTree(upgrade)
                }
            }
        }
    }

    for (const tree of race.trees) {
        processTree(tree)
    }

    return unitUpgradesMap
}

function validateRaceUnitsExist(raceName, race, unitsKv, unitFilePath) {
    for (const tree of race.trees) {
        const units = collectUnitsFromTree(tree)

        for (const unit of units) {
            if (!unitsKv[unit.name]) {
                console.error(`Error: unit ${unit.name} of race ${raceName} is missing from ${unitFilePath}`)
                process.exit(1)
            }
        }
    }
}

// Build the ability data for a single unit
function generateAbilityForUnit(unit, template, unitsKv) {
    const unitName = unit.name
    const unitKv = unitsKv[unitName]

    if (!unitKv) {
        return null
    }

    // Deep copy the template
    let ability = JSON.parse(JSON.stringify(template))

    // Override the per-unit fields
    ability.AbilityTextureName = unitName
    ability.UnitName = unitName

    if (!ability.AbilityValues) {
        ability.AbilityValues = {}
    }

    // Required fields
    if (!unitKv.AllGoldCost || !unitKv.AllFoodCost) {
        console.error(`Error: unit ${unitName} is missing AllGoldCost or AllFoodCost`)
        process.exit(1)
    }

    // Work out gold and food
    let goldCost = Number(unitKv.AllGoldCost)
    let foodCost = Number(unitKv.AllFoodCost)

    if (unit.isBase) {
        // Base unit: use AllGoldCost and AllFoodCost directly
        ability.AbilityValues.gold = String(Math.max(0, Math.floor(goldCost)))
        ability.AbilityValues.food = String(Math.max(0, Math.floor(foodCost)))
    } else {
        // Upgrade unit: subtract what the parent unit already cost
        if (!unit.parentUnit) {
            console.error(`Error: upgrade unit ${unitName} has no parent unit`)
            process.exit(1)
        }

        const parentUnitKv = unitsKv[unit.parentUnit]
        if (!parentUnitKv || !parentUnitKv.AllGoldCost || !parentUnitKv.AllFoodCost) {
            console.error(`Error: could not find the full data of parent unit ${unit.parentUnit}`)
            process.exit(1)
        }

        const parentGoldCost = Number(parentUnitKv.AllGoldCost)
        const parentFoodCost = Number(parentUnitKv.AllFoodCost)

        ability.AbilityValues.gold = String(Math.max(0, Math.floor(goldCost - parentGoldCost)))
        ability.AbilityValues.food = String(Math.max(0, Math.floor(foodCost - parentFoodCost)))
    }

    // damage
    if (unitKv.AttackDamageMin && unitKv.AttackDamageMax) {
        const damageMin = toFiniteNumber(unitKv.AttackDamageMin)
        const damageMax = toFiniteNumber(unitKv.AttackDamageMax)
        ability.AbilityValues.damage = finiteFixed((damageMin + damageMax) / 2, 1)
    }

    // speed
    if (unitKv.AttackRate && unitKv.BaseAttackSpeed) {
        const attackRate = toFiniteNumber(unitKv.AttackRate)
        const baseAttackSpeed = toFiniteNumber(unitKv.BaseAttackSpeed)
        ability.AbilityValues.speed = finiteFixed(baseAttackSpeed === 0 ? 0 : 100 * attackRate / baseAttackSpeed, 2)
    }

    // range = AttackRange
    if (unitKv.AttackRange) {
        ability.AbilityValues.range = unitKv.AttackRange
    }

    // hit_points = StatusHealth
    if (unitKv.StatusHealth) {
        ability.AbilityValues.hit_points = unitKv.StatusHealth
    }

    return ability
}

// Build every ability of one race
function generateAbilitiesForRace(raceName, race, buildTemplate, upgradeTemplate, unitsKv) {
    let abilities = {}
    let buildAbilities = []
    let upgradeAbilities = []

    for (const tree of race.trees) {
        let units = collectUnitsFromTree(tree)

        for (const unit of units) {
            const unitName = unit.name
            let abilityName
            let template

            if (unit.isBase) {
                abilityName = `build_${unitName}`
                template = buildTemplate
                buildAbilities.push(abilityName)
            } else {
                abilityName = `upgrade_${unitName}`
                template = upgradeTemplate
                upgradeAbilities.push(abilityName)
            }

            const ability = generateAbilityForUnit(unit, template, unitsKv)
            if (ability) {
                abilities[abilityName] = ability
            }
        }
    }

    return { abilities, buildAbilities, upgradeAbilities }
}

// Update the ability list of every unit
function updateUnitAbilities(unitUpgradesMap, unitsKv) {
    let updatedUnits = 0

    for (const unitName in unitUpgradesMap) {
        const unitKv = unitsKv[unitName]
        if (!unitKv) {
            console.warn(`  Warning: unit ${unitName} does not exist in the KV file`)
            continue
        }

        // Upgrade abilities of this unit
        const upgradeSkills = unitUpgradesMap[unitName]
            .filter(u => u)
            .map(u => `upgrade_${u}`)

        // Keep the other existing abilities (skip sell_building and any upgrade_ entry)
        let originalSkills = []
        for (let i = 1; i <= 24; i++) {
            const abilityKey = `Ability${i}`
            const abilityValue = unitKv[abilityKey]
            if (abilityValue &&
                abilityValue !== "sell_building" &&
                !abilityValue.startsWith("upgrade_") &&
                abilityValue !== "") {
                originalSkills.push(abilityValue)
            }
        }

        // Clear every ability slot
        for (let i = 1; i <= 24; i++) {
            delete unitKv[`Ability${i}`]
        }

        // Reassign the slots
        // Ability1 is always sell_building
        unitKv.Ability1 = "sell_building"

        // Then come the upgrade abilities
        let abilityIndex = 2
        for (const upgradeSkill of upgradeSkills) {
            unitKv[`Ability${abilityIndex}`] = upgradeSkill
            abilityIndex++
        }

        // Finally the original abilities
        for (const skill of originalSkills) {
            unitKv[`Ability${abilityIndex}`] = skill
            abilityIndex++
        }

        // Pad the remaining slots to keep the layout compatible
        while (abilityIndex <= 8) {
            unitKv[`Ability${abilityIndex}`] = ""
            abilityIndex++
        }

        updatedUnits++
    }

    return updatedUnits
}

// Register the abilities in the Lua files
function registerAbilitiesToLua(buildAbilities, upgradeAbilities) {
    // Register the build abilities
    if (buildAbilities.length > 0) {
        const buildLuaPath = "./game/scripts/vscripts/buildinghelper/buildinghelper_build.lua"
        let buildLuaContent = fs.readFileSync(buildLuaPath, { encoding: 'utf8' })
        let buildLuaLines = buildLuaContent.split('\n')
        let newBuildAbilities = []

        for (const abilityName of buildAbilities) {
            const registrationLine = `${abilityName} = buildinghelper_build`
            if (!buildLuaContent.includes(registrationLine)) {
                newBuildAbilities.push(abilityName)
                buildLuaLines.splice(5, 0, registrationLine)
            }
        }

        if (newBuildAbilities.length > 0) {
            fs.writeFileSync(buildLuaPath, buildLuaLines.join('\n'))
            console.log(`\n✓ Registered ${newBuildAbilities.length} build abilities in buildinghelper_build.lua`)
        }
    }

    // Register the upgrade abilities
    if (upgradeAbilities.length > 0) {
        const upgradeLuaPath = "./game/scripts/vscripts/buildinghelper/buildinghelper_upgrade.lua"
        let upgradeLuaContent = fs.readFileSync(upgradeLuaPath, { encoding: 'utf8' })
        let upgradeLuaLines = upgradeLuaContent.split('\n')
        let newUpgradeAbilities = []

        for (const abilityName of upgradeAbilities) {
            const registrationLine = `${abilityName} = buildinghelper_upgrade`
            if (!upgradeLuaContent.includes(registrationLine)) {
                newUpgradeAbilities.push(abilityName)
                upgradeLuaLines.splice(5, 0, registrationLine)
            }
        }

        if (newUpgradeAbilities.length > 0) {
            fs.writeFileSync(upgradeLuaPath, upgradeLuaLines.join('\n'))
            console.log(`✓ Registered ${newUpgradeAbilities.length} upgrade abilities in buildinghelper_upgrade.lua`)
        }
    }
}

function ensureAbilityBaseIncluded(raceName) {
    const customAbilitiesPath = "./game/scripts/npc/npc_abilities_custom.txt"
    const buildingBaseLine = `#base "abilities/npc_ability_${raceName}_building.txt"`
    const normalBaseLine = `#base "abilities/npc_ability_${raceName}.txt"`
    let content = fs.readFileSync(customAbilitiesPath, { encoding: 'utf8' })
    let lines = content.split('\n')

    if (lines.some(line => line.trim().startsWith(buildingBaseLine))) {
        return
    }

    const normalBaseIndex = lines.findIndex(line => line.trim().startsWith(normalBaseLine))

    if (normalBaseIndex >= 0) {
        lines.splice(normalBaseIndex, 0, `${buildingBaseLine} `)
    } else {
        const dotaAbilitiesIndex = lines.findIndex(line => line.trim() === '"DOTAAbilities"')
        const insertIndex = dotaAbilitiesIndex >= 0 ? dotaAbilitiesIndex : lines.length
        lines.splice(insertIndex, 0, `${buildingBaseLine} `)
    }

    fs.writeFileSync(customAbilitiesPath, lines.join('\n'))
    console.log(`✓ Added the ${raceName} building abilities to npc_abilities_custom.txt`)
}

function processBuildingAbilityTarget(raceName, race, unitFilePath, unitsKvData, unitsKv, buildTemplate, upgradeTemplate) {
    validateRaceUnitsExist(raceName, race, unitsKv, unitFilePath)

    // Generate the abilities
    const { abilities, buildAbilities, upgradeAbilities } = generateAbilitiesForRace(
        raceName, race, buildTemplate, upgradeTemplate, unitsKv
    )

    // Build the unit upgrade map and refresh the unit ability lists
    console.log(`\nUpdating the ability lists of ${raceName} units...`)
    const unitUpgradesMap = buildUnitUpgradesMap(race)
    const updatedUnits = updateUnitAbilities(unitUpgradesMap, unitsKv)

    // Save the updated unit KV file
    if (updatedUnits > 0) {
        let fileStr = obj2kv1.objToNpcKv(unitsKvData)
        fs.writeFileSync(unitFilePath, fileStr)
        console.log(`✓ Ability lists updated for ${updatedUnits} units`)
    }

    // Save the building ability KV file for this target
    const outputPath = `./game/scripts/npc/abilities/npc_ability_${raceName}_building.txt`
    let abilityFileStr = obj2kv1.objToNpcKv({ DOTAAbilities: abilities })
    fs.mkdirSync(path.dirname(outputPath), { recursive: true })
    fs.writeFileSync(outputPath, abilityFileStr)
    ensureAbilityBaseIncluded(raceName)
    console.log(`✓ ${raceName} building abilities saved: ${outputPath}`)
    console.log(`  ${Object.keys(abilities).length} abilities generated (${buildAbilities.length} build + ${upgradeAbilities.length} upgrade)`)

    return { buildAbilities, upgradeAbilities }
}

// Generate the unit building abilities
function generateBuildingAbilities() {
    console.log("\nGenerating unit building abilities...")

    // Read the unit tree config
    let unitTreeData = JSON.parse(fs.readFileSync("./scripts/data/metas/unit_tree.json", { encoding: 'utf8' }))
    let otherUnitsTreeData = loadOtherUnitsTree()
    let unitFileIndex = buildUnitFileIndex()
    let otherTreeGroups = groupOtherUnitTreesByFile(otherUnitsTreeData, unitFileIndex)

    // Read the ability templates
    let templateData = parseKv3("./scripts/data/build_template.kv")
    let buildTemplate = templateData.DOTAAbilities.build_template
    let upgradeTemplate = templateData.DOTAAbilities.upgrade_template

    // Special races
    const specialRaces = ["prophet", "hybrid"]

    // Collectors for the whole run
    let allBuildAbilities = []
    let allUpgradeAbilities = []

    // Validate the TARGET_RACE setting
    if (TARGET_RACE) {
        const hasNormalRace = !!unitTreeData[TARGET_RACE]
        const hasOtherTreeGroup = !!otherTreeGroups[TARGET_RACE]

        if (!hasNormalRace && !hasOtherTreeGroup) {
            console.error(`Error: race "${TARGET_RACE}" does not exist`)
            process.exit(1)
        }
        if (hasNormalRace && specialRaces.includes(TARGET_RACE)) {
            console.error(`Error: "${TARGET_RACE}" is a special race and needs no building abilities`)
            process.exit(1)
        }
        console.log(`Target race: ${TARGET_RACE}`)
    } else {
        console.log(`No target race configured, processing every normal race`)
    }

    // Walk every race
    for (const raceName in unitTreeData) {
        const race = unitTreeData[raceName]

        // Skip the other races when a target race is set
        if (TARGET_RACE && raceName !== TARGET_RACE) {
            continue
        }

        // Skip the special races
        if (specialRaces.includes(raceName)) {
            console.log(`Skipping special race: ${raceName}`)
            continue
        }

        // Skip races without a unit tree
        if (!race.trees || !Array.isArray(race.trees) || race.trees.length === 0) {
            console.log(`Skipping race without a unit tree: ${raceName}`)
            continue
        }

        console.log(`\nProcessing race: ${raceName}`)

        // Read the unit KV file of this race
        const cachedUnitFile = unitFileIndex.fileCache[raceName]
        const unitFilePath = cachedUnitFile ? cachedUnitFile.filePath : `./game/scripts/npc/units/npc_units_${raceName}.txt`
        let unitsKvData = cachedUnitFile ? cachedUnitFile.unitsKvData : parseKv3(unitFilePath)
        let unitsKv = cachedUnitFile ? cachedUnitFile.unitsKv : unitsKvData.DOTAUnits

        const { buildAbilities, upgradeAbilities } = processBuildingAbilityTarget(
            raceName, race, unitFilePath, unitsKvData, unitsKv, buildTemplate, upgradeTemplate
        )

        // Add to the run-wide ability lists
        allBuildAbilities = allBuildAbilities.concat(buildAbilities)
        allUpgradeAbilities = allUpgradeAbilities.concat(upgradeAbilities)
    }

    // Handle the extra unit trees from other_units_tree.json
    for (const raceName in otherTreeGroups) {
        const group = otherTreeGroups[raceName]
        const race = { trees: group.trees }
        const unitFile = group.unitFile

        console.log(`\nProcessing extra unit tree: ${raceName}`)
        console.log(`Root unit lives in: ${unitFile.filePath}`)

        const { buildAbilities, upgradeAbilities } = processBuildingAbilityTarget(
            raceName, race, unitFile.filePath, unitFile.unitsKvData, unitFile.unitsKv, buildTemplate, upgradeTemplate
        )

        allBuildAbilities = allBuildAbilities.concat(buildAbilities)
        allUpgradeAbilities = allUpgradeAbilities.concat(upgradeAbilities)
    }

    // Register the abilities in the Lua files
    registerAbilitiesToLua(allBuildAbilities, allUpgradeAbilities)

    console.log(`\nAll targets processed: ${allBuildAbilities.length} build abilities, ${allUpgradeAbilities.length} upgrade abilities`)
}

// Run when invoked directly
if (require.main === module) {
    generateBuildingAbilities();
}

// Exports for other modules
module.exports = {
    generateBuildingAbilities
};
