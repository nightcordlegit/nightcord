@echo off
:: Wrapper .bat pour lancer youcord-uninstall.ps1 facilement (double-clic)
title YouCord â€” DÃ©sinstallation
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0youcord-uninstall.ps1"
if %errorlevel% neq 0 pause
