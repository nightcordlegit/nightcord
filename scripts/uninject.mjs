/*
 * YouCord â€” Local un-injector for Discord Desktop
 * Annule l'injection en :
 * 1. Supprimant le dossier app/ crÃ©Ã© par inject.mjs
 * 2. Restaurant _app.asar â†’ app.asar
 *
 * Usage: pnpm uninject   (ou: node scripts/uninject.mjs)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import "./checkNodeVersion.js";

import { existsSync, readdirSync, readFileSync, renameSync, rmSync } from "fs";
import { join } from "path";

// â”€â”€ Locate Discord installations (mÃªme logique que inject.mjs) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function findAllDiscordResources() {
    const platform = process.platform;
    const candidates = [];

    if (platform === "win32") {
        const localAppData = process.env.LOCALAPPDATA || "";

        for (const channel of ["Discord", "DiscordPTB", "DiscordCanary", "DiscordDevelopment"]) {
            const base = join(localAppData, channel);
            if (!existsSync(base)) continue;
            try {
                const versions = readdirSync(base)
                    .filter(d => /^app-\d+\.\d+\.\d+$/.test(d))
                    .sort()
                    .reverse();
                for (const ver of versions) {
                    candidates.push(join(base, ver, "resources"));
                }
            } catch { }
        }
    } else if (platform === "darwin") {
        candidates.push(
            "/Applications/Discord.app/Contents/Resources",
            "/Applications/Discord PTB.app/Contents/Resources",
            "/Applications/Discord Canary.app/Contents/Resources"
        );
    } else if (platform === "linux") {
        candidates.push(
            "/usr/share/discord/resources",
            "/usr/lib/discord/resources",
            "/opt/discord/resources",
            "/opt/Discord/resources"
        );
    }

    // Filtrer uniquement les paths avec une injection YouCord prÃ©sente
    return candidates.filter(p => {
        if (!existsSync(p)) return false;
        return existsSync(join(p, "app")) || existsSync(join(p, "_app.asar"));
    });
}

// â”€â”€ Uninject â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function uninject(resourcesDir) {
    const appDirPath = join(resourcesDir, "app");
    const backupPath = join(resourcesDir, "_app.asar");
    const appAsarPath = join(resourcesDir, "app.asar");

    // VÃ©rifier que le dossier app/ a bien Ã©tÃ© crÃ©Ã© par YouCord
    if (existsSync(appDirPath)) {
        try {
            if (existsSync(join(appDirPath, "index.js"))) {
                const indexContent = readFileSync(join(appDirPath, "index.js"), "utf-8");
                if (!indexContent.includes("YouCord Injector") && !indexContent.includes("YouCord")) {
                    console.warn(`\x1b[33m[YouCord] Le dossier app/ existe mais n'a pas l'air d'avoir Ã©tÃ© crÃ©Ã© par YouCord.\x1b[0m`);
                    console.warn("\x1b[33m            Abandon pour Ã©viter de casser un autre mod.\x1b[0m");
                    return false;
                }
            }
        } catch { }

        console.log("[YouCord] Suppression du dossier app/ injectÃ©...");
        rmSync(appDirPath, { recursive: true, force: true });
    } else {
        console.log("\x1b[33m[YouCord] Aucun dossier app/ injectÃ© trouvÃ©.\x1b[0m");
    }

    // Restaurer le backup
    if (existsSync(backupPath) && !existsSync(appAsarPath)) {
        console.log("[YouCord] Restauration _app.asar â†’ app.asar...");
        renameSync(backupPath, appAsarPath);
    } else if (existsSync(backupPath) && existsSync(appAsarPath)) {
        console.log("[YouCord] app.asar dÃ©jÃ  prÃ©sent, nettoyage du backup...");
        rmSync(backupPath, { force: true });
    }

    console.log(`\x1b[32m[YouCord] DÃ©sinjection rÃ©ussie depuis : ${resourcesDir}\x1b[0m`);
    console.log("\x1b[36m[YouCord] RedÃ©marrez Discord pour appliquer les changements.\x1b[0m");
    return true;
}

// â”€â”€ Main â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const allResources = findAllDiscordResources();

if (allResources.length === 0) {
    console.error("\x1b[31m[YouCord] Aucune installation Discord avec YouCord injectÃ© trouvÃ©e.\x1b[0m");
    console.error("\x1b[33m           Assurez-vous que YouCord a bien Ã©tÃ© injectÃ© via 'pnpm inject'.\x1b[0m");
    process.exit(1);
}

let uninjectCount = 0;
for (const res of allResources) {
    console.log(`\n[YouCord] TrouvÃ© : ${res}`);
    if (uninject(res)) uninjectCount++;
}

if (uninjectCount === 0) {
    console.error("\x1b[31m[YouCord] Aucune dÃ©sinjection rÃ©ussie.\x1b[0m");
    process.exit(1);
}

console.log(`\n\x1b[32m[YouCord] ${uninjectCount}/${allResources.length} dÃ©sinjection(s) rÃ©ussie(s).\x1b[0m`);
