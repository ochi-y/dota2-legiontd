"use strict";

/**
 * Strip development-only content before the addon is published.
 *
 * The Hero Demo debug UI is created by HeroDemo, which is only loaded in tools
 * mode (see addon_game_mode.lua), so it never shows up in a published match.
 * The files would still ship inside the addon, which is why this script removes
 * them:
 *
 *   npm run prepare-publish
 *
 * The paths are deleted from the working tree, so `git status` reports them as
 * deleted. Restore them with `git checkout -- <path>` when the Hero Demo is
 * needed again in tools mode.
 */

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");

// Paths relative to the addon root that exist for development only.
const PUBLISH_EXCLUDES = [
    "content/panorama/layout/custom_game/hud_demo",
    "game/panorama/layout/custom_game/hud_demo"
];

function directorySize(target) {
    let size = 0;
    const stack = [target];

    while (stack.length > 0) {
        const current = stack.pop();
        for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
            const fullPath = path.join(current, entry.name);
            if (entry.isDirectory()) {
                stack.push(fullPath);
            } else {
                size += fs.statSync(fullPath).size;
            }
        }
    }

    return size;
}

function formatSize(bytes) {
    return (bytes / 1048576).toFixed(1) + " MB";
}

function main() {
    const removed = [];
    let totalBytes = 0;

    for (const relative of PUBLISH_EXCLUDES) {
        const absolute = path.join(ROOT, relative);

        if (!fs.existsSync(absolute)) {
            continue;
        }

        const size = directorySize(absolute);
        fs.rmSync(absolute, { recursive: true, force: true });

        removed.push(relative);
        totalBytes += size;
        console.log(`removed  ${relative}  (${formatSize(size)})`);
    }

    if (removed.length === 0) {
        console.log("Nothing to remove, the addon is already publish ready.");
    } else {
        console.log(`\nRemoved ${removed.length} path(s), ${formatSize(totalBytes)} in total. The addon is ready to publish.`);
    }

    return { removed, totalBytes };
}

if (require.main === module) {
    main();
}

module.exports = {
    main,
    PUBLISH_EXCLUDES
};
