# build-installer.ps1 â€” Build YouCord-Installer.exe (Electron + electron-builder)
# Usage: .\build-installer.ps1

$ErrorActionPreference = "Stop"
$Root      = $PSScriptRoot
$SrcDir    = Join-Path $Root "installer-src"
$OutDir    = Join-Path $Root "release\installer"
$OutExe    = Join-Path $OutDir "YouCord-Installer.exe"

Write-Host ""
Write-Host "  [YouCord] Building Electron installer..." -ForegroundColor Cyan

# â”€â”€ Prerequis â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$nodeOk = $null
try { $nodeOk = & node --version 2>$null } catch {}
if (-not $nodeOk) {
    Write-Host "  [ERREUR] Node.js introuvable. Installez-le depuis https://nodejs.org" -ForegroundColor Red
    exit 1
}
Write-Host "  Node.js : $nodeOk" -ForegroundColor DarkGray

# â”€â”€ Dossier de sortie â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# â”€â”€ Installer les dependances si besoin â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$nodeModules = Join-Path $SrcDir "node_modules"
if (-not (Test-Path $nodeModules)) {
    Write-Host "  [1/3] npm install --legacy-peer-deps..." -ForegroundColor DarkGray
    Push-Location $SrcDir
    & npm install --legacy-peer-deps
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERREUR] npm install a echoue." -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
    Write-Host "  [1/3] Dependances installees." -ForegroundColor Green
} else {
    Write-Host "  [1/3] node_modules present, installation ignoree." -ForegroundColor DarkGray
}

# â”€â”€ Compilation webpack â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
Write-Host "  [2/3] electron-webpack (compilation)..." -ForegroundColor DarkGray
Push-Location $SrcDir
& npm run compile
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERREUR] Compilation webpack echouee." -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location
Write-Host "  [2/3] Webpack OK." -ForegroundColor Green

# â”€â”€ Packaging electron-builder â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
Write-Host "  [3/3] electron-builder --win (packaging)..." -ForegroundColor DarkGray
Push-Location $SrcDir
& npx electron-builder --win -p never
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERREUR] electron-builder a echoue." -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location
Write-Host "  [3/3] Packaging OK." -ForegroundColor Green

# â”€â”€ Verification â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if (Test-Path $OutExe) {
    $size = [math]::Round((Get-Item $OutExe).Length / 1KB, 0)
    Write-Host ""
    Write-Host "  OK  YouCord-Installer.exe compile ($size KB)" -ForegroundColor Green
    Write-Host "    -> $OutExe" -ForegroundColor DarkGray
    Write-Host ""
} else {
    Write-Host "  [ERREUR] YouCord-Installer.exe introuvable apres compilation." -ForegroundColor Red
    exit 1
}
