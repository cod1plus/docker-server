@echo off
rem ARRETER.bat - arrete les serveurs (les logs et demos de chaque serveur sont gardes).
cd /d "%~dp0"
docker compose down
pause
