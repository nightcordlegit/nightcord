import { createHash } from "crypto";
import { readFileSync, writeFileSync, readdirSync, statSync } from "fs";
import { join, resolve } from "path";
import { fileURLToPath } from "url";

const projectDir = resolve(fileURLToPath(import.meta.url), "../..");
const releaseDir = join(projectDir, "release");

let files;
try {
    files = readdirSync(releaseDir)
        .filter(f => statSync(join(releaseDir, f)).isFile() && f !== "checksums.txt")
        .sort();
} catch {
    console.error("[checksums] Dossier release/ introuvable. Exécutez d'abord 'pnpm package'.");
    process.exit(1);
}

if (files.length === 0) {
    console.error("[checksums] Aucun fichier trouvé dans release/ (ignoré: checksums.txt)");
    process.exit(1);
}

const lines = [];
for (const file of files) {
    const data = readFileSync(join(releaseDir, file));
    const sha256 = createHash("sha256").update(data).digest("hex");
    const sha1 = createHash("sha1").update(data).digest("hex");
    const md5 = createHash("md5").update(data).digest("hex");
    const size = (data.length / 1024 / 1024).toFixed(2);
    lines.push(`${sha256}  ${file}`);
    lines.push(`  SHA-1: ${sha1}`);
    lines.push(`  MD5:   ${md5}`);
    lines.push(`  Size:  ${size} MB`);
    lines.push("");
}

const outPath = join(releaseDir, "checksums.txt");
writeFileSync(outPath, lines.join("\n"));
console.log(`[checksums] Écrit ${outPath}`);
console.log(`[checksums] ${files.length} fichier(s) haché(s) :`);
for (const file of files) {
    const size = (statSync(join(releaseDir, file)).size / 1024 / 1024).toFixed(2);
    console.log(`  ${file} (${size} MB)`);
}
