#!/usr/bin/env node

const inquirer = require('inquirer');
const chalk = require('chalk');

const precache = require('./scripts/precache.js');
const meta = require('./scripts/meta.js');
const buildingAbility = require('./scripts/building_ability.js');
const normalize = require('./scripts/normalize.js');

// Balance test unit config (kept in one place for easy editing)
const BALANCE_TEST_UNITS = {
    'Melee': [
        'elf_nightsaber',
        'orc_wolverine',
        'goblin_goblin_blaster'
    ],
    'Ranged': [
        'elf_maverick'
    ],
    'Archer': [
        'mech_zeus',
        'paladin_elite_archer'
    ],
    'Dragon': [
        'undead_death_dragon',
        'beast_ogre_dragon_aspect'
    ]
};

class ProcessExitError extends Error {
    constructor(code, stepName) {
        super(`${stepName} called process.exit(${code})`);
        this.name = 'ProcessExitError';
        this.code = code;
    }
}

function printFatalError(title, error) {
    const message = error && error.message ? error.message : String(error || 'Unknown error');

    console.error('');
    console.error(chalk.bgRed.white.bold('  !!! Operation failed, exiting !!!  '));
    console.error(chalk.red.bold(`  ${title}`));
    console.error(chalk.red(`  ${message}`));

    if (error && error.stack) {
        console.error(chalk.gray('\n' + error.stack));
    }

    console.error('');
}

function runWithProcessExitGuard(stepName, fn) {
    const originalExit = process.exit;

    process.exit = (code = 0) => {
        throw new ProcessExitError(code, stepName);
    };

    try {
        return fn();
    } finally {
        process.exit = originalExit;
    }
}

// Show the welcome banner
function showWelcome() {
    console.clear();
    console.log('\n=== Legion TD Dev Tool v1.0.0 ===\n');
}

// Core function for compiling game files
function compileFiles() {
    return new Promise((resolve, reject) => {
        console.log('\n✨ Compiling game files...\n');
        console.log(chalk.cyan('═══════════════════════════════════\n'));

        try {
            // Step 1: normalize unit data
            console.log(chalk.yellow('[1/4] Normalizing unit data...\n'));

            runWithProcessExitGuard('normalize.js', () => normalize.main());

            console.log(chalk.green('\n✓ Unit data normalized\n'));
            console.log(chalk.cyan('═══════════════════════════════════\n'));

            // Step 2: generate build abilities
            console.log(chalk.yellow('[2/4] Generating build abilities...\n'));

            runWithProcessExitGuard('building_ability.js', () => buildingAbility.generateBuildingAbilities());

            console.log(chalk.green('\n✓ Build abilities generated\n'));
            console.log(chalk.cyan('═══════════════════════════════════\n'));

            // Step 3: run precache.js
            console.log(chalk.yellow('[3/4] Generating precache file...\n'));

            runWithProcessExitGuard('precache.js', () => precache.main());

            console.log(chalk.green('\n✓ Precache file generated\n'));
            console.log(chalk.cyan('═══════════════════════════════════\n'));

            // Step 4: run meta.js
            console.log(chalk.yellow('[4/4] Generating game metadata...\n'));

            runWithProcessExitGuard('meta.js', () => meta.main());

            console.log(chalk.cyan('\n═══════════════════════════════════'));
            console.log(chalk.green('\n🎉 Compile complete! All files generated successfully!\n'));

            resolve();
        } catch (error) {
            reject(error);
        }
    });
}


// Show help text
function showHelp() {
    console.log('\nCommand help\n');
    console.log('Available actions:\n');
    console.log('  Compile game files');
    console.log('    - [1/4] Normalize unit data (normalize.js)');
    console.log('    - [2/4] Generate build abilities (building_ability.js)');
    console.log('    - [3/4] Generate precache file (precache_auto.lua)');
    console.log('    - [4/4] Generate game metadata from scripts/data/metas/*.json (metas/*.kv and meta.js)');
    console.log('    - Scans and processes units, abilities, items and other configs\n');
    console.log('  Balance test');
    console.log('    - Generates a list of combat test commands');
    console.log('    - Format: -ft <test unit> <opponent unit> 3000');
    console.log('    - For quick in-game unit balance comparisons\n');
    console.log('Notes:');
    console.log('  - Compile files: re-run after changing game configs\n');
}

// Generate the balance test command list
function generateBalanceTestCommands() {
    console.log('\n');
    console.log(chalk.cyan('═══════════════════════════════════════════════════════════'));
    console.log(chalk.yellow.bold('               Balance Test Command Generator'));
    console.log(chalk.cyan('═══════════════════════════════════════════════════════════'));
    console.log('\n');
    console.log(chalk.gray('How to use:'));
    console.log(chalk.gray('1. Copy one of the commands below into the in-game chat box'));
    console.log(chalk.gray('2. Format: -ft <test unit> <opponent unit> <value>'));
    console.log(chalk.gray('3. XXX is the placeholder for the unit you want to test'));
    console.log(chalk.gray('4. Use -ft_close to end a running test early\n'));

    console.log(chalk.cyan('═══════════════════════════════════════════════════════════'));
    console.log(chalk.green.bold('                      Test Command List'));
    console.log(chalk.cyan('═══════════════════════════════════════════════════════════\n'));

    // Iterate over every unit category
    for (const [category, units] of Object.entries(BALANCE_TEST_UNITS)) {
        console.log(chalk.yellow(`[${category} units]`));
        console.log(chalk.gray('─'.repeat(60)));

        // Generate a test command for each unit
        units.forEach(unit => {
            console.log(chalk.white(`-ft XXX ${unit} 3000`));
        });

        console.log('');
    }

    console.log(chalk.cyan('═══════════════════════════════════════════════════════════'));
    console.log(chalk.magenta('Tip: replace XXX with the unit you want to test'));
    console.log(chalk.magenta('Example: -ft orc_grunt elf_nightsaber 3000'));
    console.log(chalk.cyan('═══════════════════════════════════════════════════════════\n'));

    // Summary stats
    const totalUnits = Object.values(BALANCE_TEST_UNITS).reduce((sum, units) => sum + units.length, 0);
    console.log(chalk.gray(`${Object.keys(BALANCE_TEST_UNITS).length} categories, ${totalUnits} units to compare against\n`));
}

// Main menu
async function showMainMenu() {
    const answer = await inquirer.prompt([
        {
            type: 'list',
            name: 'action',
            message: 'Select an action:',
            choices: [
                { name: 'Compile game files', value: 'compile' },
                { name: 'Balance test', value: 'balance' },
                { name: 'View help', value: 'help' },
                new inquirer.Separator(),
                { name: 'Exit', value: 'exit' }
            ]
        }
    ]);

    return answer.action;
}

// Main loop
async function main() {
    showWelcome();
    const action = await showMainMenu();

    switch (action) {
        case 'compile':
            await compileFiles();
            break;

        case 'balance':
            generateBalanceTestCommands();
            break;

        case 'help':
            showHelp();
            break;

        case 'exit':
            break;
    }

    console.log('\nThanks for using the Legion TD dev tool!\n');
    process.exit(0);
}

// Error handling
process.on('SIGINT', () => {
    console.log(chalk.yellow('\n\nInterrupted'));
    console.log('\n');
    process.exit(0);
});

// Start the program
main().catch(err => {
    printFatalError('Fatal error', err);
    process.exit(1);
});
