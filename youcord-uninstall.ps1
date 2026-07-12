# ==============================================================================
#  YouCord â€” DÃ©sinstalleur utilisateur (PowerShell)
#  Supprime l'injection YouCord de Discord
#
#  Usage : Clic droit â†’ "ExÃ©cuter avec PowerShell"
# ==============================================================================

$ErrorActionPreference = "Stop"

$InstallDir    = Join-Path $env:LOCALAPPDATA "YouCord-Client"
$DistDir       = Join-Path $InstallDir "dist\desktop"
$InstallerDir  = Join-Path $InstallDir "installer"
$EquilotlExe   = Join-Path $InstallerDir "EquilotlCli.exe"

Clear-Host
Write-Host ""
Write-Host "  â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—" -ForegroundColor Cyan
Write-Host "  â•‘      YOUCORD â€” DÃ©sinstalleur           â•‘" -ForegroundColor Cyan
Write-Host "  â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $EquilotlExe)) {
    Write-Host "  [INFO] EquilotlCli.exe introuvable." -ForegroundColor Yellow
    Write-Host "         TÃ©lÃ©chargement de l'outil de dÃ©sinstallation..." -ForegroundColor Yellow
    Write-Host ""
    New-Item -ItemType Directory -Force -Path $InstallerDir | Out-Null
    $EquilotlUrl = "https://github.com/Equicord/Equilotl/releases/latest/download/EquilotlCli.exe"
    Invoke-WebRequest -Uri $EquilotlUrl `
        -Headers @{ "User-Agent" = "YouCord-Installer/2.0" } `
        -OutFile $EquilotlExe -UseBasicParsing
}

Write-Host "  Lancement du dÃ©sinstalleur graphique..." -ForegroundColor Yellow
Write-Host "  Une fenÃªtre va s'ouvrir pour choisir votre Discord cible." -ForegroundColor Yellow
Write-Host ""

$env:EQUICORD_USER_DATA_DIR = $InstallDir
$env:EQUICORD_DIRECTORY     = $DistDir
$env:EQUICORD_DEV_INSTALL   = "1"

try {
    & $EquilotlExe "--uninstall"
} catch {
    Write-Host "  [ERREUR] La dÃ©sinstallation a Ã©chouÃ© : $_" -ForegroundColor Red
    Write-Host "  Appuyez sur une touche pour quitter..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""
Write-Host "  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”" -ForegroundColor Green
Write-Host "  â”‚  YouCord dÃ©sinstallÃ© avec succÃ¨s !                 â”‚" -ForegroundColor Green
Write-Host "  â”‚  RedÃ©marrez Discord pour appliquer les changements.  â”‚" -ForegroundColor Green
Write-Host "  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 3
