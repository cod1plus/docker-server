# make-lan-package.ps1 - build the ready-made LAN image and the folder to hand to a LAN organiser.
#
#   powershell -ExecutionPolicy Bypass -File tools\make-lan-package.ps1 [-Context <dir>] [-Out <dir>] [-Tag <tag>]
#
#   -Context  build context: this repository with gamefiles\ filled (see gamefiles\README.md).
#             Default: the repository. Use a copy outside OneDrive/Dropbox for the ~1.2 GB of paks.
#   -Out      the LAN folder to create [C:\cod1-lan]
#   -Tag      image tag [<yyyyMMdd>]
#
# Result in -Out: lan\ (DEMARRER.bat, docker-compose.yml, servers\...), .env naming the image,
# and cod1-lan-<tag>.tar (docker save). Copy the folder to the LAN machine, double-click
# DEMARRER.bat. PAM is baked in at build time from the official manifest (the files the 1.6X
# clients install), cod1plus.so from gamefiles\ - nothing is downloaded on the LAN day.
param(
    [string]$Context = (Split-Path -Parent $PSScriptRoot),
    [string]$Out = "C:\cod1-lan",
    [string]$Tag = (Get-Date -Format "yyyyMMdd")
)
$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot
$image = "cod1plus/cod1-lan:$Tag"

Write-Host "== build $image from $Context"
docker build -t $image -t "cod1plus/cod1-lan:latest" $Context
if ($LASTEXITCODE -ne 0) { throw "docker build failed" }

Write-Host "== LAN folder $Out"
New-Item -ItemType Directory -Force -Path $Out | Out-Null
Copy-Item -Recurse -Force -Path (Join-Path $repo "lan\*") -Destination $Out
Set-Content -Encoding ascii -Path (Join-Path $Out ".env") -Value "COD1_IMAGE=$image"
Get-ChildItem -Path $Out -Filter "cod1-lan-*.tar" | Where-Object { $_.Name -ne "cod1-lan-$Tag.tar" } | ForEach-Object {
    Write-Host "   older image file kept aside: $($_.Name) -> $($_.Name).old"
    Rename-Item -Path $_.FullName -NewName ($_.Name + ".old")
}

Write-Host "== docker save -> cod1-lan-$Tag.tar"
docker save -o (Join-Path $Out "cod1-lan-$Tag.tar") $image
if ($LASTEXITCODE -ne 0) { throw "docker save failed" }
Get-ChildItem $Out | Select-Object Name, @{ n = "MB"; e = { [math]::Round($_.Length / 1MB, 1) } } | Format-Table -AutoSize
Write-Host "Done: copy $Out to the LAN machine and run DEMARRER.bat"
