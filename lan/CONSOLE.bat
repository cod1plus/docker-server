@echo off
rem CONSOLE.bat - la console d'un serveur : tapez des commandes (map mp_carentan, map_restart, status...).
rem Pour la quitter SANS arreter le serveur : Ctrl+P puis Ctrl+Q.
cd /d "%~dp0"
docker ps --filter "name=cod1-server" --format "table {{.Names}}\t{{.Status}}"
echo.
set N=
set /p N=Numero du serveur [1] :
if "%N%"=="" set N=1
echo.
echo Console de cod1-server%N%. Sortir sans l'arreter : Ctrl+P puis Ctrl+Q
echo.
docker attach cod1-server%N%
