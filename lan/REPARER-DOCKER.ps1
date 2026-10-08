# REPARER-DOCKER.ps1 - see REPARER-DOCKER.bat
$names = @("Docker Desktop", "com.docker.backend", "com.docker.build", "com.docker.extensions", "docker-ai", "docker-sandbox", "docker")
Write-Host "Fermeture de Docker Desktop..."
Get-Process | Where-Object { $names -contains $_.ProcessName } | ForEach-Object {
    try { Stop-Process -Id $_.Id -Force -ErrorAction Stop } catch {}
}
Start-Sleep -Seconds 4
wsl --shutdown
Start-Sleep -Seconds 2

$stamp = Get-Date -Format "yyyyMMddHHmmss"
foreach ($d in @("$env:LOCALAPPDATA\Docker\run", "$env:LOCALAPPDATA\docker-secrets-engine")) {
    if (Test-Path $d) {
        $new = (Split-Path $d -Leaf) + ".stale-" + $stamp
        try {
            Rename-Item -Path $d -NewName $new -ErrorAction Stop
            Write-Host "mis de cote : $d -> $new"
        } catch {
            Write-Host "IMPOSSIBLE de renommer $d : $($_.Exception.Message)"
        }
    }
}

$exe = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
if (Test-Path $exe) {
    Start-Process $exe
    Write-Host "Docker Desktop relance. Attente du moteur..."
    for ($i = 0; $i -lt 60; $i++) {
        docker info *> $null
        if ($LASTEXITCODE -eq 0) { Write-Host "Docker est pret."; exit 0 }
        Start-Sleep -Seconds 3
    }
    Write-Host "Docker n'est toujours pas pret apres 3 minutes : regardez sa fenetre pour le message d'erreur."
} else {
    Write-Host "Docker Desktop introuvable ($exe)."
}
