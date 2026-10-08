@echo off
rem LOGS.bat - ce qu'affichent les serveurs (Ctrl+C pour fermer, les serveurs continuent).
cd /d "%~dp0"
docker compose logs -f --tail 80
