$ErrorActionPreference = 'Stop'

function Invoke-Packwiz {
    & $packwiz @args
    if ($LASTEXITCODE -ne 0) {
        throw "packwiz $($args -join ' ') failed with exit code $LASTEXITCODE."
    }
}

Push-Location -LiteralPath (Join-Path $PSScriptRoot 'pack')
try {
    if (-not (Test-Path -LiteralPath 'mods/voxy-0.6.0.jar' -PathType Leaf)) {
        throw 'Restore pack/mods/voxy-0.6.0.jar from the source PrismLauncher instance before building.'
    }

    $packwizName = if ($env:OS -eq 'Windows_NT') { 'packwiz.exe' } else { 'packwiz' }
    $packwiz = Join-Path $PSScriptRoot ".tools/bin/$packwizName"
    if (-not (Test-Path -LiteralPath $packwiz -PathType Leaf)) {
        $command = Get-Command -Name packwiz -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if (-not $command) {
            throw "Install packwiz on PATH or place $packwizName in .tools/bin/."
        }
        $packwiz = $command.Source
    }

    Invoke-Packwiz list
    Invoke-Packwiz refresh

    New-Item -ItemType Directory -Path '../dist' -Force | Out-Null
    $output = '../dist/MODPACK-Full-0.1.0-snapshot.mrpack'
    $temporaryPack = "../dist/.build-$([guid]::NewGuid()).mrpack"
    try {
        Invoke-Packwiz --cache ../.tools/packwiz-cache modrinth export -o $temporaryPack
        Move-Item -LiteralPath $temporaryPack -Destination $output -Force
    } finally {
        if (Test-Path -LiteralPath $temporaryPack) {
            Remove-Item -LiteralPath $temporaryPack -Force
        }
    }

    Write-Host 'Built dist/MODPACK-Full-0.1.0-snapshot.mrpack'
} finally {
    Pop-Location
}
