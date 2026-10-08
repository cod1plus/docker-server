@echo off
rem REPARER-DOCKER.bat - quand Docker Desktop refuse de demarrer avec
rem   "remove ...\dockerInference" ou "...\docker-secrets-engine\engine.sock:
rem    The file cannot be accessed by the system"
rem Windows n'arrive pas a supprimer les sockets laisses par Docker a sa derniere fermeture.
rem Ce script ferme Docker, met ces dossiers de cote (renommes, rien n'est efface) et le relance.
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0REPARER-DOCKER.ps1"
pause
