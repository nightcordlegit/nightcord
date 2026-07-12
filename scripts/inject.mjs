/*
 * YouCord â€” Local injector for Discord Desktop
 * Injecte YouCord dans une installation Discord existante en :
 * 1. Trouvant le rÃ©pertoire resources de Discord
 * 2. Renommant app.asar â†’ _app.asar (backup)
 * 3. CrÃ©ant un dossier app/ avec un loader qui require le patcher.js de YouCord
 *
 * Usage: pnpm inject   (ou: node scripts/inject.mjs)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import "./checkNodeVersion.js";

import { existsSync, mkdirSync, readdirSync, readFileSync, renameSync, rmSync, statSync, writeFileSync } from "fs";
import { dirname, join, resolve } from "path";
import { fileURLToPath } from "url";

const BASE_DIR = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const DIST_DIR = join(BASE_DIR, "dist", "desktop");

// â”€â”€ Locate Discord installations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/**
 * Retourne tous les rÃ©pertoires resources Discord trouvÃ©s sur la machine.
 * @returns {string[]}
 */
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
            "/opt/Discord/resources",
            join(process.env.HOME || "", ".local/share/flatpak/app/com.discordapp.Discord/current/active/files/discord/resources"),
            "/snap/discord/current/usr/share/discord/resources"
        );
    }

    // Filtrer les paths qui existent et contiennent app.asar ou app/
    return candidates.filter(p => {
        if (!existsSync(p)) return false;
        return existsSync(join(p, "app.asar")) || existsSync(join(p, "app")) || existsSync(join(p, "_app.asar"));
    });
}

// â”€â”€ Check dist/ exists â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function checkBuild() {
    const patcherPath = join(DIST_DIR, "patcher.js");
    if (!existsSync(patcherPath)) {
        console.error("\x1b[31m[YouCord] dist/desktop/patcher.js introuvable !\x1b[0m");
        console.error("\x1b[33m           Lancez 'pnpm build' d'abord, puis rÃ©essayez.\x1b[0m");
        process.exit(1);
    }
}

// â”€â”€ Inject â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function inject(resourcesDir) {
    const appAsarPath = join(resourcesDir, "app.asar");
    const backupPath = join(resourcesDir, "_app.asar");
    const appDirPath = join(resourcesDir, "app");

    // VÃ©rifier si dÃ©jÃ  injectÃ©
    if (existsSync(appDirPath) && existsSync(join(appDirPath, "index.js"))) {
        try {
            const indexContent = readFileSync(join(appDirPath, "index.js"), "utf-8");
            if (indexContent.includes("YouCord Injector") || indexContent.includes("YouCord")) {
                console.log("\x1b[33m[YouCord] DÃ©jÃ  injectÃ© ! Utilisez 'pnpm uninject' d'abord pour rÃ©injecter.\x1b[0m");
                return false;
            }
        } catch { }
    }

    // Ã‰tape 1 : Backup app.asar â†’ _app.asar
    if (existsSync(appAsarPath) && !existsSync(backupPath)) {
        let isDir = false;
        try { isDir = statSync(appAsarPath).isDirectory(); } catch { }
        if (isDir) {
            console.warn("\x1b[33m[YouCord] app.asar est un dossier â€” un autre mod est peut-Ãªtre installÃ©.\x1b[0m");
            console.warn("\x1b[33m            Abandon. Utilisez 'pnpm uninject' pour nettoyer d'abord.\x1b[0m");
            return false;
        }
        console.log("[YouCord] Sauvegarde app.asar â†’ _app.asar...");
        renameSync(appAsarPath, backupPath);
    } else if (!existsSync(backupPath)) {
        console.error("\x1b[31m[YouCord] Aucun app.asar ou _app.asar trouvÃ© dans resources !\x1b[0m");
        return false;
    }

    // Ã‰tape 2 : Supprimer l'ancien app.asar s'il existe (pourrait Ãªtre un dossier d'une injection prÃ©cÃ©dente)
    if (existsSync(appAsarPath)) {
        try {
            rmSync(appAsarPath, { recursive: true, force: true });
        } catch (e) {
            console.error(`\x1b[31m[YouCord] Impossible de supprimer l'ancien app.asar : ${e.message}\x1b[0m`);
            return false;
        }
    }

    // Ã‰tape 3 : CrÃ©er le dossier app/ avec le loader
    mkdirSync(appDirPath, { recursive: true });

    writeFileSync(join(appDirPath, "package.json"), JSON.stringify({
        name: "discord",
        main: "index.js"
    }, null, 2));

    // Le loader require simplement le patcher YouCord depuis dist/
    const patcherPath = join(DIST_DIR, "patcher.js").replace(/\\/g, "\\\\");
    writeFileSync(join(appDirPath, "index.js"),
        `// YouCord Injector â€” auto-generated, do not edit\n"use strict";\nrequire("${patcherPath}");\n`
    );

    console.log(`\x1b[32m[YouCord] InjectÃ© avec succÃ¨s dans : ${resourcesDir}\x1b[0m`);
    console.log(`\x1b[32m[YouCord] RÃ©pertoire YouCord dist : ${DIST_DIR}\x1b[0m`);
    console.log("\x1b[36m[YouCord] RedÃ©marrez Discord pour appliquer les changements.\x1b[0m");
    return true;
}

// â”€â”€ Main â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
checkBuild();

const allResources = findAllDiscordResources();
if (allResources.length === 0) {
    console.error("\x1b[31m[YouCord] Aucune installation Discord trouvÃ©e !\x1b[0m");
    console.error("\x1b[33m           Assurez-vous que Discord (Stable, PTB ou Canary) est installÃ©.\x1b[0m");
    process.exit(1);
}

if (allResources.length === 1) {
    // Un seul Discord trouvÃ© : injection directe
    console.log(`[YouCord] Discord trouvÃ© : ${allResources[0]}`);
    inject(allResources[0]);
} else {
    // Plusieurs Discord trouvÃ©s : injecter dans tous
    console.log(`[YouCord] ${allResources.length} installations Discord trouvÃ©es :`);
    let injectedCount = 0;
    for (const res of allResources) {
        console.log(`\n  â†’ ${res}`);
        if (inject(res)) injectedCount++;
    }
    console.log(`\n\x1b[32m[YouCord] ${injectedCount}/${allResources.length} injection(s) rÃ©ussie(s).\x1b[0m`);
}
