var kv3tojs = require('./lib/kv3parser');
const fs = require('fs');
var glob = require("glob");
var obj2kv1 = require('./lib/obj2kv1');
let path = require('path');
const { loadMetaConfig } = require('./meta_config');

// Race to process (leave null to process every normal race)
// Example: const TARGET_RACE = "arctic" or const TARGET_RACE = null
const TARGET_RACE = null

const DEFAULT_UNIT_KV = {
    ConstructionSize: "2",
    BlockPathingSize: "0",
    DisableTurning: "1",
    Disarmed: "1",
    noHealthBar: "1",
    OverrideBuildingGhost: "building_ghost"
}

function toFiniteNumber(value, defaultValue = 0) {
    const numberValue = Number(value)
    return Number.isFinite(numberValue) ? numberValue : defaultValue
}

function finiteString(value, defaultValue = 0) {
    return String(toFiniteNumber(value, defaultValue))
}

function finiteFixed(value, digits, defaultValue = 0) {
    return toFiniteNumber(value, defaultValue).toFixed(digits)
}

function loadMetaData() {
    return loadMetaConfig()
}

// Read the race list from scripts/data/metas/*.json
function loadRacesFromMeta(metaData) {
    const races = metaData.races || {}

    // Special races (prophet and hybrid are handled separately)
    const SPECIAL_RACES = ["prophet", "hybrid"]

    // Every race defined in metas/races.json
    const allRaces = Object.keys(races)

    // Normal races = all races minus the special ones
    const NORMAL_RACES = allRaces.filter(race => !SPECIAL_RACES.includes(race))

    return {
        SPECIAL_RACES,
        NORMAL_RACES,
        allRaces
    }
}

function loadOtherFighterUnitFiles(metaData) {
    const files = metaData.otherFighters && Array.isArray(metaData.otherFighters.files) ? metaData.otherFighters.files : []

    return files.map(fileName => `./game/scripts/npc/units/${fileName}`)
}

// Load the race lists
const metaConfig = loadMetaData()
const { SPECIAL_RACES, NORMAL_RACES } = loadRacesFromMeta(metaConfig)

function parseKv3(file) {
    let content = fs.readFileSync(file, { encoding: 'utf8' });
    return kv3tojs.parse(content);
}

function saveKv(data, filePath) {
    let fileStr = obj2kv1.objToNpcKv(data)
    fs.mkdirSync(path.dirname(filePath), { recursive: true })
    fs.writeFileSync(filePath, fileStr);
}

// Calculate DPS
function calculateDps(unitKv) {
    const baseAttackSpeed = toFiniteNumber(unitKv.BaseAttackSpeed)
    const attackRate = toFiniteNumber(unitKv.AttackRate)
    const attackDamageMin = toFiniteNumber(unitKv.AttackDamageMin)
    const attackDamageMax = toFiniteNumber(unitKv.AttackDamageMax)

    // Attack interval = AttackRate / (BaseAttackSpeed / 100)
    const attackInterval = baseAttackSpeed === 0 ? 0 : attackRate / (baseAttackSpeed / 100)

    // Average damage
    const avgDamage = (attackDamageMin + attackDamageMax) / 2

    // DPS = average damage / attack interval
    const dps = attackInterval === 0 ? 0 : avgDamage / attackInterval

    return {
        dps: toFiniteNumber(dps),
        avgDamage: toFiniteNumber(avgDamage),
        attackInterval: toFiniteNumber(attackInterval)
    }
}

// Calculate the AttackMinMax offset
function calculateAttackMinMax(attackDamageMin, attackDamageMax) {
    attackDamageMin = toFiniteNumber(attackDamageMin)
    attackDamageMax = toFiniteNumber(attackDamageMax)
    const avgDamage = (attackDamageMin + attackDamageMax) / 2

    // AttackMinMax = (Max - Avg) / Avg
    // How far Max sits above the average, as a ratio
    const offset = avgDamage === 0 ? 0 : (attackDamageMax - avgDamage) / avgDamage

    return toFiniteNumber(offset)
}

// Reverse calculation: derive the unit stats from the normalized fields
function reverseCalculateStats(unitName, unitKv) {
    // Required fields
    if (!unitKv.AllGoldCost || !unitKv.BaseAttackSpeed || !unitKv.AttackRate) {
        console.log(`  ⚠ Unit ${unitName} is missing required fields, cannot reverse calculate`)
        return false
    }

    const allGoldCost = toFiniteNumber(unitKv.AllGoldCost)
    const dpsPerGold = toFiniteNumber(unitKv.DpsPerGold)
    const healthPerGold = toFiniteNumber(unitKv.HealthPerGold)
    const attackMinMax = toFiniteNumber(unitKv.AttackMinMax)
    const baseAttackSpeed = toFiniteNumber(unitKv.BaseAttackSpeed)
    const attackRate = toFiniteNumber(unitKv.AttackRate)

    // Skip units whose price is zero or negative
    if (allGoldCost <= 0) {
        console.log(`  ⚠ Unit ${unitName} has AllGoldCost <= 0, skipping`)
        return false
    }

    // 1. Reverse calculate StatusHealth
    // Round to the nearest 5, never below 1
    const calculatedHealth = healthPerGold * allGoldCost
    const newStatusHealth = Math.max(1, Math.round(calculatedHealth / 5) * 5)

    // 2. Reverse calculate DPS
    const dps = dpsPerGold * allGoldCost

    // 3. Attack interval
    const attackInterval = baseAttackSpeed === 0 ? 0 : attackRate / (baseAttackSpeed / 100)

    // 4. Average damage
    const avgDamage = dps * attackInterval

    // 5. Reverse calculate AttackDamageMax and AttackDamageMin
    // AttackMinMax = (Max - Avg) / Avg
    // => Max = Avg * (1 + AttackMinMax)
    const newAttackDamageMax = toFiniteNumber(Math.round(avgDamage * (1 + attackMinMax)))

    // Min + Max = 2 * Avg
    // => Min = 2 * Avg - Max
    const newAttackDamageMin = toFiniteNumber(Math.round(2 * avgDamage - newAttackDamageMax))

    // Write back into the unit KV
    const oldHealth = unitKv.StatusHealth
    const oldMin = unitKv.AttackDamageMin
    const oldMax = unitKv.AttackDamageMax

    unitKv.StatusHealth = finiteString(newStatusHealth)
    unitKv.AttackDamageMin = finiteString(newAttackDamageMin)
    unitKv.AttackDamageMax = finiteString(newAttackDamageMax)

    console.log(`  ✓ ${unitName} [reverse calculation]:`)
    console.log(`    - normalized inputs: DpsPerGold=${finiteFixed(dpsPerGold, 6)}, HealthPerGold=${finiteFixed(healthPerGold, 6)}, AttackMinMax=${finiteFixed(attackMinMax, 4)}`)
    console.log(`    - results: DPS=${finiteFixed(dps, 2)}, avg damage=${finiteFixed(avgDamage, 2)}, attack interval=${finiteFixed(attackInterval, 2)}s`)
    console.log(`    - StatusHealth: ${oldHealth} → ${newStatusHealth}`)
    console.log(`    - AttackDamageMin: ${oldMin} → ${newAttackDamageMin}`)
    console.log(`    - AttackDamageMax: ${oldMax} → ${newAttackDamageMax}`)

    return true
}

// Forward calculation: derive the normalized fields from the unit stats
function forwardCalculateStats(unitName, unitKv) {
    // Required fields
    if (!unitKv.BaseAttackSpeed || !unitKv.AttackRate ||
        !unitKv.AttackDamageMin || !unitKv.AttackDamageMax ||
        !unitKv.StatusHealth) {
        console.log(`  ⚠ Unit ${unitName} is missing required fields, skipping`)
        return false
    }

    const allGoldCost = toFiniteNumber(unitKv.AllGoldCost)

    // Skip units whose price is zero or negative
    if (allGoldCost <= 0) {
        console.log(`  ⚠ Unit ${unitName} has AllGoldCost <= 0, skipping`)
        return false
    }

    // Calculate DPS
    const dpsData = calculateDps(unitKv)

    // DpsPerGold
    const dpsPerGold = dpsData.dps / allGoldCost

    // HealthPerGold
    const statusHealth = toFiniteNumber(unitKv.StatusHealth)
    const healthPerGold = statusHealth / allGoldCost

    // AttackMinMax
    const attackDamageMin = toFiniteNumber(unitKv.AttackDamageMin)
    const attackDamageMax = toFiniteNumber(unitKv.AttackDamageMax)
    const attackMinMax = calculateAttackMinMax(attackDamageMin, attackDamageMax)

    // Write the normalized fields into the unit KV
    unitKv.DpsPerGold = finiteFixed(dpsPerGold, 6)
    unitKv.HealthPerGold = finiteFixed(healthPerGold, 6)
    unitKv.AttackMinMax = finiteFixed(attackMinMax, 4)

    console.log(`  ✓ ${unitName} [forward calculation]:`)
    console.log(`    - DPS: ${finiteFixed(dpsData.dps, 2)} (avg damage: ${finiteFixed(dpsData.avgDamage, 1)}, attack interval: ${finiteFixed(dpsData.attackInterval, 2)}s)`)
    console.log(`    - DpsPerGold: ${finiteFixed(dpsPerGold, 6)}`)
    console.log(`    - HealthPerGold: ${finiteFixed(healthPerGold, 6)} (health: ${statusHealth}, gold: ${allGoldCost})`)
    console.log(`    - AttackMinMax: ${finiteFixed(attackMinMax, 4)} (max damage is ${finiteFixed(1 + attackMinMax, 2)}x the average)`)

    return true
}

// Update the Creature fields of a unit
function updateCreatureStats(unitName, unitKv) {
    // Required fields
    if (!unitKv.StatusHealth || !unitKv.AttackDamageMin || !unitKv.AttackDamageMax) {
        return false
    }

    const statusHealth = toFiniteNumber(unitKv.StatusHealth)
    const attackDamageMin = toFiniteNumber(unitKv.AttackDamageMin)
    const attackDamageMax = toFiniteNumber(unitKv.AttackDamageMax)
    const avgDamage = toFiniteNumber((attackDamageMin + attackDamageMax) / 2)

    // Create the Creature table when it is missing
    if (!unitKv.Creature) {
        unitKv.Creature = {}
    }

    const oldHPGain = unitKv.Creature.HPGain
    const oldDamageGain = unitKv.Creature.DamageGain

    // Write the new Creature values
    unitKv.Creature.HPGain = finiteString(statusHealth)
    unitKv.Creature.DamageGain = finiteString(Math.round(avgDamage))

    console.log(`  ✓ ${unitName} [Creature update]:`)
    console.log(`    - HPGain: ${oldHPGain || '(none)'} → ${statusHealth}`)
    console.log(`    - DamageGain: ${oldDamageGain || '(none)'} → ${toFiniteNumber(Math.round(avgDamage))}`)

    return true
}

function updateDefaultUnitKv(unitName, unitKv) {
    let updatedFields = []

    for (const [key, value] of Object.entries(DEFAULT_UNIT_KV)) {
        if (!Object.prototype.hasOwnProperty.call(unitKv, key)) {
            unitKv[key] = value
            updatedFields.push(key)
        }
    }

    if (updatedFields.length === 0) {
        return false
    }

    console.log(`  ✓ ${unitName} [default KV filled]: ${updatedFields.join(', ')}`)

    return true
}

// Normalize a single unit
function normalizeUnit(unitName, unitKv, raceName) {
    // Only units with an AllGoldCost are normalized
    if (!unitKv.AllGoldCost) {
        return false
    }

    // Decide between forward and reverse calculation
    const hasStandardFields = unitKv.DpsPerGold && unitKv.HealthPerGold && unitKv.AttackMinMax

    if (hasStandardFields) {
        // Normalized fields already exist, so reverse calculate
        return reverseCalculateStats(unitName, unitKv)
    } else {
        // No normalized fields yet, so forward calculate
        return forwardCalculateStats(unitName, unitKv)
    }
}

// Normalize every unit inside one unit file
function normalizeUnitFile(unitFilePath, label) {
    console.log(`\nProcessing unit file: ${label}`)
    console.log("=".repeat(60))

    try {
        let unitsKvData = parseKv3(unitFilePath)
        let unitsKv = unitsKvData.DOTAUnits

        let normalizedCount = 0
        let creatureUpdateCount = 0
        let defaultKvUpdateCount = 0
        let skippedCount = 0

        // Walk every unit
        for (const unitName in unitsKv) {
            // Skip base units
            if (unitName.includes('_base')) {
                skippedCount++
                continue
            }

            const unitKv = unitsKv[unitName]

            // Normalize the unit (only units carrying an AllGoldCost)
            const normalized = normalizeUnit(unitName, unitKv, label)

            if (normalized) {
                normalizedCount++
            }

            // Update the Creature fields (runs for every unit)
            const creatureUpdated = updateCreatureStats(unitName, unitKv)

            if (creatureUpdated) {
                creatureUpdateCount++
            }

            const defaultKvUpdated = updateDefaultUnitKv(unitName, unitKv)

            if (defaultKvUpdated) {
                defaultKvUpdateCount++
            }

            // Only count a unit as skipped when nothing at all changed
            if (!normalized && !creatureUpdated && !defaultKvUpdated) {
                skippedCount++
            }
        }

        // Save the file when anything changed
        if (normalizedCount > 0 || creatureUpdateCount > 0 || defaultKvUpdateCount > 0) {
            saveKv(unitsKvData, unitFilePath)
            console.log(`\n✓ Unit data saved: ${unitFilePath}`)
            console.log(`  normalized units: ${normalizedCount}`)
            console.log(`  Creature updates: ${creatureUpdateCount}`)
            console.log(`  default KV filled: ${defaultKvUpdateCount}`)
            console.log(`  skipped units: ${skippedCount}`)
        } else {
            console.log(`\n○ ${label} needs no update (${skippedCount} units skipped)`)
        }

        return normalizedCount

    } catch (err) {
        console.log(`  ⚠ Error: failed to read or process unit file ${unitFilePath}`)
        console.log(`  details: ${err.message}`)
        return 0
    }
}

// Normalize every unit of one race
function normalizeRace(raceName) {
    const unitFilePath = `./game/scripts/npc/units/npc_units_${raceName}.txt`
    return normalizeUnitFile(unitFilePath, raceName)
}

function normalizeOtherFighterFiles(processedFiles) {
    const otherFighterFiles = loadOtherFighterUnitFiles(metaConfig)
    let totalNormalized = 0
    let processedCount = 0

    if (otherFighterFiles.length === 0) {
        console.log("\nNo otherFighters.files configured, skipping the extra unit files")
        return { totalNormalized, processedCount }
    }

    console.log(`\notherFighters.files: ${otherFighterFiles.map(filePath => path.basename(filePath)).join(', ')}`)

    for (const filePath of otherFighterFiles) {
        const normalizedPath = path.normalize(filePath)

        if (processedFiles.has(normalizedPath)) {
            console.log(`\nSkipping already processed file: ${filePath}`)
            continue
        }

        const count = normalizeUnitFile(filePath, path.basename(filePath, ".txt"))
        processedFiles.add(normalizedPath)
        totalNormalized += count
        processedCount++
    }

    return { totalNormalized, processedCount }
}

// Set AttackAcquisitionRange for every wave unit
function normalizeWaveAttackAcquisitionRange() {
    const waveUnitFilePath = "./game/scripts/npc/units/npc_units_wave.txt"

    try {
        let unitsKvData = parseKv3(waveUnitFilePath)
        let unitsKv = unitsKvData.DOTAUnits

        let updatedCount = 0
        let skippedCount = 0

        for (const unitName in unitsKv) {
            const unitKv = unitsKv[unitName]

            if (!unitKv || typeof unitKv !== "object") {
                skippedCount++
                continue
            }

            if (unitKv.AttackAcquisitionRange !== "900") {
                unitKv.AttackAcquisitionRange = "900"
                updatedCount++
            } else {
                skippedCount++
            }
        }

        if (updatedCount > 0) {
            saveKv(unitsKvData, waveUnitFilePath)
            console.log(`\n✓ Wave unit attack acquisition range updated: ${waveUnitFilePath}`)
            console.log(`  updated: ${updatedCount}`)
            console.log(`  unchanged: ${skippedCount}`)
        } else {
            console.log(`\n○ Wave unit attack acquisition range needs no update (${skippedCount} units unchanged)`)
        }
    } catch (err) {
        console.log(`\n⚠ Error: failed to read or process the wave unit file`)
        console.log(`  details: ${err.message}`)
    }
}

function main() {
    console.log("======================================")
    console.log("Normalizing unit data...")
    console.log("======================================")

    // Validate the TARGET_RACE setting
    if (TARGET_RACE) {
        if (SPECIAL_RACES.includes(TARGET_RACE)) {
            console.error(`\nError: "${TARGET_RACE}" is a special race and needs no normalization`)
            process.exit(1)
        }
        if (!NORMAL_RACES.includes(TARGET_RACE)) {
            console.error(`\nError: race "${TARGET_RACE}" does not exist`)
            process.exit(1)
        }
        console.log(`\nTarget race: ${TARGET_RACE}`)
    } else {
        console.log(`\nNo target race configured, processing every normal race`)
    }

    console.log(`\nSpecial races (skipped): ${SPECIAL_RACES.join(', ')}`)
    console.log(`Normal races: ${NORMAL_RACES.join(', ')}`)

    let totalNormalized = 0
    let processedRaces = 0
    let processedFiles = new Set()

    // Walk every normal race
    for (const raceName of NORMAL_RACES) {
        // Skip the other races when a target race is set
        if (TARGET_RACE && raceName !== TARGET_RACE) {
            continue
        }

        const unitFilePath = `./game/scripts/npc/units/npc_units_${raceName}.txt`
        const count = normalizeUnitFile(unitFilePath, raceName)
        processedFiles.add(path.normalize(unitFilePath))
        totalNormalized += count
        processedRaces++
    }

    const otherFighterResult = normalizeOtherFighterFiles(processedFiles)
    totalNormalized += otherFighterResult.totalNormalized

    console.log("\n======================================")
    console.log("Normalization complete!")
    console.log("======================================")
    console.log(`Races processed: ${processedRaces}`)
    console.log(`Extra unit files processed: ${otherFighterResult.processedCount}`)
    console.log(`Units normalized in total: ${totalNormalized}`)

    normalizeWaveAttackAcquisitionRange()

    console.log("\nMay the winds bless your journey~")
}

// Run when invoked directly
if (require.main === module) {
    main();
}

// Exports for other modules
module.exports = {
    main,
    normalizeRace,
    normalizeUnitFile,
    normalizeOtherFighterFiles,
    normalizeUnit,
    calculateDps,
    calculateAttackMinMax,
    reverseCalculateStats,
    forwardCalculateStats,
    updateCreatureStats,
    updateDefaultUnitKv,
    normalizeWaveAttackAcquisitionRange
};
