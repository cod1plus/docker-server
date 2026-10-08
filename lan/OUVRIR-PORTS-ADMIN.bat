@echo off
rem OUVRIR-PORTS-ADMIN.bat - autorise les ports UDP 28960-28969 dans le pare-feu Windows,
rem pour que les autres PC du LAN voient et rejoignent les serveurs. A faire une seule fois.
net session >nul 2>&1
if errorlevel 1 (
    echo Demande des droits administrateur...
    powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0'"
    exit /b
)
netsh advfirewall firewall delete rule name="COD1.6X LAN" >nul 2>&1
netsh advfirewall firewall add rule name="COD1.6X LAN" dir=in action=allow protocol=UDP localport=28960-28969 profile=any
echo.
echo Ports UDP 28960-28969 ouverts (regle "COD1.6X LAN").
pause
