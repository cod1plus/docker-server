@echo off
rem DEMARRER.bat - lance les serveurs COD1.6X du LAN (docker-compose.yml de ce dossier).
rem La premiere fois : charge l'image depuis cod1-lan-*.tar (1 a 2 minutes).
setlocal
cd /d "%~dp0"
title COD1.6X LAN

set IMAGE=
for /f "usebackq tokens=1,* delims==" %%a in (".env") do if /i "%%a"=="COD1_IMAGE" set IMAGE=%%b
if not defined IMAGE (
    echo Le fichier .env de ce dossier ne donne pas COD1_IMAGE.
    pause
    exit /b 1
)

docker info >nul 2>&1
if not errorlevel 1 goto docker_ok
echo Demarrage de Docker Desktop...
if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
for /l %%i in (1,1,60) do (
    timeout /t 3 /nobreak >nul
    docker info >nul 2>&1 && goto docker_ok
)
echo.
echo Docker ne demarre pas.
echo - Docker Desktop est-il installe ? https://www.docker.com/products/docker-desktop/
echo - Erreur "The file cannot be accessed by the system" : lancez REPARER-DOCKER.bat
pause
exit /b 1

:docker_ok
docker image inspect %IMAGE% >nul 2>&1
if not errorlevel 1 goto image_ok
if not exist "cod1-lan-*.tar" (
    echo L'image %IMAGE% n'est pas chargee et il n'y a pas de fichier cod1-lan-*.tar ici.
    pause
    exit /b 1
)
echo Chargement de l'image du serveur, une seule fois : 1 a 2 minutes...
for %%f in (cod1-lan-*.tar) do docker load -i "%%f"
docker image inspect %IMAGE% >nul 2>&1
if errorlevel 1 (
    echo Le .tar ne contient pas %IMAGE%.
    pause
    exit /b 1
)

:image_ok
docker compose up -d
if errorlevel 1 (
    echo Echec du lancement - voir le message ci-dessus.
    pause
    exit /b 1
)
echo.
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo.
echo Adresse IP de ce PC sur le LAN :
powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' -and $_.InterfaceAlias -notlike 'vEthernet*' -and $_.InterfaceAlias -notlike '*WSL*' } | ForEach-Object { '   ' + $_.IPAddress + '   (' + $_.InterfaceAlias + ')' }"
echo.
echo Les joueurs, dans la console du jeu : /connect IP:28960   (serveur 2 : IP:28961)
echo L'onglet LAN du jeu ne voit pas les serveurs Docker sous Windows : connexion par IP ou favori.
echo Si personne ne voit les serveurs : OUVRIR-PORTS-ADMIN.bat (pare-feu Windows), une seule fois.
echo.
pause
