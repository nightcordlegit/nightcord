#!/usr/bin/env bash
# â”€â”€â”€ YouCord Installer â€” Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Equivalent bash de build-installer.ps1 (converti depuis build-installer.bat)

set -euo pipefail

cd "$(dirname "$0")"

echo ""
echo " ================================"
echo "  YouCord Installer - Build"
echo " ================================"
echo ""

# â”€â”€ VÃ©rifie que node est disponible â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if ! command -v node &>/dev/null; then
    echo " [ERREUR] Node.js introuvable. Installez Node.js depuis https://nodejs.org"
    exit 1
fi

# â”€â”€ CrÃ©e le dossier de sortie si besoin â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
mkdir -p "release/installer"

# â”€â”€ Entre dans le dossier installer-src â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
cd installer-src

# â”€â”€ 1. Installe les dÃ©pendances si node_modules absent â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if [[ ! -d "node_modules" ]]; then
    echo " [1/3] Installation des dependances npm..."
    if ! npm install --legacy-peer-deps; then
        echo " [ERREUR] npm install a echoue."
        cd ..
        exit 1
    fi
    echo " [1/3] Dependances installees."
else
    echo " [1/3] Dependances deja presentes, on passe."
fi

# â”€â”€ 2. Compile avec electron-webpack â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo ""
echo " [2/3] Compilation webpack (electron-webpack)..."

if ! npm run compile; then
    echo " [ERREUR] Compilation webpack echouee."
    cd ..
    exit 1
fi

echo " [2/3] Compilation webpack reussie."

# â”€â”€ 3. Packaging electron-builder â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo ""
echo " [3/3] Packaging electron-builder..."

if ! npx electron-builder --win -p never; then
    echo " [ERREUR] electron-builder a echoue."
    cd ..
    exit 1
fi

cd ..

# â”€â”€ VÃ©rification â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if [[ ! -f "release/installer/YouCord-Installer.exe" ]]; then
    echo ""
    echo " [ERREUR] YouCord-Installer.exe introuvable apres build."
    exit 1
fi

SIZE=$(stat -c%s "release/installer/YouCord-Installer.exe" 2>/dev/null \
    || stat -f%z "release/installer/YouCord-Installer.exe")

echo ""
echo " [OK] Build reussi !"
echo " Fichier : release/installer/YouCord-Installer.exe  ($SIZE octets)"
echo ""