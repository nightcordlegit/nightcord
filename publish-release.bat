@echo off
:: â”€â”€â”€ YouCord â€” Publier une nouvelle release sur Gitea â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
:: Usage : publish-release.bat 1.18.1 "Description des changements"
:: Necessite : pnpm, node
::             curl (inclus dans Windows 10+)
::
:: Auth : token Gitea dans %USERPROFILE%\.gitea_token  (une seule ligne, aucun espace)
::        Creer le fichier : echo votre_token > %USERPROFILE%\.gitea_token

setlocal EnableDelayedExpansion

set "VERSION=%~1"
set "NOTES=%~2"

if "%VERSION%"=="" (
    echo [ERREUR] Usage: publish-release.bat VERSION "Notes de version"
    echo Exemple : publish-release.bat 1.18.1 "Correction bug audio"
    pause
    exit /b 1
)

if "%NOTES%"=="" set NOTES=YouCord %VERSION%

:: â”€â”€ Config Gitea â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
set GITEA_URL=https://source.youcord.st
set GITEA_REPO=youcord/youcord
set GITEA_API=%GITEA_URL%/api/v1

:: â”€â”€ Lecture du token depuis le fichier local (non versionne) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
set TOKEN_FILE=%USERPROFILE%\.gitea_token
if not exist "%TOKEN_FILE%" (
    echo  [ERREUR] Fichier de token introuvable : %TOKEN_FILE%
    echo  Creez-le avec : echo votre_token_gitea ^> "%%USERPROFILE%%\.gitea_token"
    echo  Generez un token sur : %GITEA_URL%/user/settings/applications
    pause
    exit /b 1
)

set /p GITEA_TOKEN=<"%TOKEN_FILE%"
set "GITEA_TOKEN=%GITEA_TOKEN: =%"

if "%GITEA_TOKEN%"=="" (
    echo  [ERREUR] Le fichier %TOKEN_FILE% est vide.
    pause
    exit /b 1
)

:: Chemins de sortie
set DIST_DIR=dist\desktop
set OUT_DIR=release\installer
set DIST_ZIP=%OUT_DIR%\youcord-dist.zip
set INSTALLER_EXE=%OUT_DIR%\YouCord-Installer.exe
set VERSION_JSON=%OUT_DIR%\version.json
set DESKTOP_ASAR=dist\desktop.asar

echo.
echo  â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
echo  â•‘    YOUCORD â€” Publication release v%VERSION%
echo  â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
echo.

:: â”€â”€ 1. Mise Ã  jour de la version â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo  [1/8] Mise a jour de la version vers %VERSION%...
node -e "const fs = require('fs'); const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8')); pkg.version = '%VERSION%'; fs.writeFileSync('package.json', JSON.stringify(pkg, null, 4) + '\n', 'utf8');"
echo  [1/8] Version mise a jour.

:: â”€â”€ 2. Envoi du code source sur Gitea â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo.
echo  [2/8] Committer et pusher le code source...
git add .
git diff --quiet --cached
if errorlevel 1 (
    git commit -m "build: release v%VERSION% - %NOTES%"
) else (
    echo  Aucun changement a committer.
)
git push --set-upstream origin master
if errorlevel 1 (
    echo  [ERREUR] Impossible de push sur Gitea. Verifiez vos identifiants/droits d'acces.
    pause
    exit /b 1
)
echo  [2/8] Code source synchronise avec Gitea.

:: â”€â”€ 3. Build JS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo.
echo  [3/8] Build + obfuscation en cours...
taskkill /F /IM Discord.exe /T >nul 2>&1
taskkill /F /IM node.exe    /T >nul 2>&1
timeout /t 2 /nobreak >nul
call pnpm build
if errorlevel 1 (
    echo  [ERREUR] pnpm build a echoue.
    pause
    exit /b 1
)
echo  [3/8] Build + obfuscation termines !

:: â”€â”€ 4. Assets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo.
echo  [4/8] Copie des assets (ffmpeg, node, modules...) vers %DIST_DIR%...
node scripts\build\collect-assets.mjs
echo  [4/8] Assets copies.

:: â”€â”€ 5. YouCord-Installer.exe â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo.
echo  [5/8] Compilation de YouCord-Installer.exe...
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -File "build-installer.ps1"
if errorlevel 1 (
    echo  [ERREUR] Compilation de l'installeur echouee.
    pause
    exit /b 1
)
if not exist "%INSTALLER_EXE%" (
    echo  [ERREUR] YouCord-Installer.exe introuvable apres compilation.
    pause
    exit /b 1
)
for %%F in ("%INSTALLER_EXE%") do echo  [5/8] YouCord-Installer.exe cree (%%~zF octets)

:: â”€â”€ 6. youcord-dist.zip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo.
echo  [6/8] Creation de youcord-dist.zip...
if not exist "%DIST_DIR%\patcher.js" (
    echo  [ERREUR] dist\desktop\patcher.js introuvable.
    pause
    exit /b 1
)
if exist "%DIST_ZIP%" del /F /Q "%DIST_ZIP%"
del /s /q "%DIST_DIR%\*.map" >nul 2>&1
del /s /q "%DIST_DIR%\*.LEGAL.txt" >nul 2>&1
node scripts\build\verify-dist.mjs
if errorlevel 1 (
    echo  [ERREUR] Verification du dist echouee.
    pause
    exit /b 1
)
powershell -NoProfile -Command "Add-Type -Assembly System.IO.Compression.FileSystem; $src = (Resolve-Path '%DIST_DIR%').Path; $dst = (Join-Path (Resolve-Path 'release\installer').Path 'youcord-dist.zip'); [System.IO.Compression.ZipFile]::CreateFromDirectory($src, $dst, [System.IO.Compression.CompressionLevel]::Optimal, $false)"
if not exist "%DIST_ZIP%" (
    echo  [ERREUR] Impossible de creer youcord-dist.zip
    pause
    exit /b 1
)
for %%F in ("%DIST_ZIP%") do echo  [6/8] youcord-dist.zip cree (%%~zF octets)

:: â”€â”€ 7. version.json â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo.
echo  [7/8] Mise a jour de version.json...
for /f "usebackq" %%d in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd'"`) do set ISO_DATE=%%d
(
    echo {
    echo   "version": "%VERSION%",
    echo   "releaseDate": "%ISO_DATE%",
    echo   "installerUrl": "%GITEA_URL%/%GITEA_REPO%/releases/download/v%VERSION%/YouCord-Installer.exe",
    echo   "distUrl": "%GITEA_URL%/%GITEA_REPO%/releases/download/v%VERSION%/youcord-dist.zip",
    echo   "downloadUrl": "%GITEA_URL%/%GITEA_REPO%/releases/download/v%VERSION%/desktop.asar",
    echo   "changelog": "%NOTES%"
    echo }
) > "%VERSION_JSON%"
echo  [7/8] version.json mis a jour.

:: â”€â”€ 8. Publier sur Gitea Releases â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo.
echo  [8/8] Creation de la release v%VERSION% sur Gitea...

:: 8a. Creer la release
set "JSON_TMP=%OUT_DIR%\release_payload.json"
(
    echo {
    echo   "tag_name": "v%VERSION%",
    echo   "name": "YouCord v%VERSION%",
    echo   "body": "%NOTES%",
    echo   "draft": false,
    echo   "prerelease": false
    echo }
) > "%JSON_TMP%"
curl -s -X POST "%GITEA_API%/repos/%GITEA_REPO%/releases" ^
    -H "Authorization: token %GITEA_TOKEN%" ^
    -H "Content-Type: application/json" ^
    -d "@%JSON_TMP%" ^
    -o "%OUT_DIR%\release_response.json"
del /F /Q "%JSON_TMP%" >nul 2>&1
if errorlevel 1 (
    echo  [ERREUR] Echec de la creation de la release Gitea.
    pause
    exit /b 1
)

:: 8b. Extraire l'ID
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "(Get-Content '%OUT_DIR%\release_response.json' | ConvertFrom-Json).id"`) do set RELEASE_ID=%%i
if "%RELEASE_ID%"=="" (
    echo  [ERREUR] Impossible de recuperer l'ID de la release Gitea.
    type "%OUT_DIR%\release_response.json"
    pause
    exit /b 1
)
echo  Release Gitea creee (ID: %RELEASE_ID%)

:: 8c. Upload â€” YouCord-Installer.exe (via curl, < 100MB)
echo  Upload de YouCord-Installer.exe...
curl -s -X POST "%GITEA_API%/repos/%GITEA_REPO%/releases/%RELEASE_ID%/assets?name=YouCord-Installer.exe" ^
    -H "Authorization: token %GITEA_TOKEN%" ^
    -H "Content-Type: application/octet-stream" ^
    --data-binary "@%INSTALLER_EXE%" >nul
if errorlevel 1 ( echo  [ERREUR] Upload YouCord-Installer.exe echoue. & pause & exit /b 1 )

:: 8d. Upload â€” youcord-dist.zip (via curl, < 100MB)
echo  Upload de youcord-dist.zip...
curl -s -X POST "%GITEA_API%/repos/%GITEA_REPO%/releases/%RELEASE_ID%/assets?name=youcord-dist.zip" ^
    -H "Authorization: token %GITEA_TOKEN%" ^
    -H "Content-Type: application/zip" ^
    --data-binary "@%DIST_ZIP%" >nul
if errorlevel 1 ( echo  [ERREUR] Upload youcord-dist.zip echoue. & pause & exit /b 1 )

:: 8e. Upload â€” desktop.asar (via PowerShell, contourne limite Cloudflare 100MB)
echo  Upload de desktop.asar...
powershell -NoProfile -Command ^
    "$token = '%GITEA_TOKEN%';" ^
    "$bytes = [System.IO.File]::ReadAllBytes('dist\desktop.asar');" ^
    "$uri = 'https://source.youcord.st/api/v1/repos/youcord/youcord/releases/%RELEASE_ID%/assets?name=desktop.asar';" ^
    "Invoke-RestMethod -Uri $uri -Method POST -Headers @{Authorization='token '+$token} -ContentType 'application/octet-stream' -Body $bytes | Out-Null;" ^
    "Write-Host 'OK'"
if errorlevel 1 ( echo  [ERREUR] Upload desktop.asar echoue. & pause & exit /b 1 )

:: 8f. Upload â€” version.json (via curl, tiny)
echo  Upload de version.json...
curl -s -X POST "%GITEA_API%/repos/%GITEA_REPO%/releases/%RELEASE_ID%/assets?name=version.json" ^
    -H "Authorization: token %GITEA_TOKEN%" ^
    -H "Content-Type: application/json" ^
    --data-binary "@%VERSION_JSON%" >nul
if errorlevel 1 ( echo  [ERREUR] Upload version.json echoue. & pause & exit /b 1 )

del /F /Q "%OUT_DIR%\release_response.json" >nul 2>&1

:: â”€â”€ Done â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo.
echo  â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
echo  â•‘  YouCord v%VERSION% publie avec succes sur Gitea !
echo  â•‘
echo  â•‘  URL : %GITEA_URL%/%GITEA_REPO%/releases/tag/v%VERSION%
echo  â•‘
echo  â•‘  Fichiers publies :
echo  â•‘    YouCord-Installer.exe    â€” installeur .exe avec GUI
echo  â•‘    youcord-dist.zip         â€” JS obfusques (pour l'injec.)
echo  â•‘    desktop.asar               â€” asar Discord patcher
echo  â•‘    version.json               â€” metadonnees de version
echo  â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
echo.
pause
