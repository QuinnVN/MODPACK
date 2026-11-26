[CmdletBinding()]
param(
    [ValidatePattern('^(?:[2-9]|[1-9][0-9]+)$')]
    [string]$ServerRevision
)

$ErrorActionPreference = 'Stop'

function Invoke-Packwiz {
    & $packwiz @args
    if ($LASTEXITCODE -ne 0) {
        throw "packwiz $($args -join ' ') failed with exit code $LASTEXITCODE."
    }
}

$source = Join-Path $PSScriptRoot 'pack'

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

$python = Get-Command -Name python3, python -CommandType Application -ErrorAction SilentlyContinue |
    Select-Object -First 1
if (-not $python) {
    throw 'Install Python 3 on PATH to package the Packwiz exports.'
}
$cache = Join-Path $PSScriptRoot '.tools/packwiz-cache'
$dist = (New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot 'dist') -Force).FullName
$work = (New-Item -ItemType Directory -Path (Join-Path $dist ".build-$([guid]::NewGuid())")).FullName

try {
    $baseline = $source
    $profiles = @('server')
    if (-not $ServerRevision) {
        $baseline = Join-Path $work 'full'
        Copy-Item -LiteralPath $source -Destination $baseline -Recurse -Force
        $profiles = @('full', 'lite', 'server')
    }
    foreach ($profile in $profiles) {
        if ($profile -eq 'full') { continue }
        $stage = Join-Path $work $profile
        New-Item -ItemType Directory -Path (Join-Path $stage 'mods'), (Join-Path $stage 'shaderpacks') -Force | Out-Null
        foreach ($item in Get-ChildItem -LiteralPath $baseline -Force) {
            if ($item.Name -cin 'mods', 'shaderpacks') { continue }
            Copy-Item -LiteralPath $item.FullName -Destination $stage -Recurse -Force
        }

        $list = Join-Path $PSScriptRoot "profiles/$profile/allow.txt"
        foreach ($line in Get-Content -LiteralPath $list) {
            $entry = $line.Trim()
            if ($entry -eq '' -or $entry.StartsWith('#')) { continue }
            if ($entry -cnotmatch '^(mods|shaderpacks)/[a-zA-Z0-9_.+ -]+\.(pw\.toml|jar|zip)$') {
                throw "Invalid entry in profiles/$profile/allow.txt: $entry"
            }
            $includedFile = Join-Path $baseline $entry
            $target = Join-Path $stage $entry
            if (-not (Test-Path -LiteralPath $includedFile -PathType Leaf) -or (Test-Path -LiteralPath $target)) {
                throw "Missing or duplicate entry in profiles/$profile/allow.txt: $entry"
            }
            Copy-Item -LiteralPath $includedFile -Destination $target
        }
    }
    if (-not $ServerRevision) {
        $liteDefaults = Join-Path $work 'lite/configureddefaults'
        New-Item -ItemType Directory -Path $liteDefaults -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'profiles/lite/configureddefaults/options.txt') -Destination $liteDefaults
    }

    foreach ($profile in $profiles) {
        $archive = Join-Path $work "$profile.mrpack"
        Push-Location -LiteralPath (Join-Path $work $profile)
        try {
            Invoke-Packwiz refresh
            Invoke-Packwiz --cache $cache modrinth export -o $archive
            if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) {
                throw "packwiz did not export $profile.mrpack."
            }
        } finally {
            Pop-Location
        }
    }

    $packageArgs = if ($ServerRevision) {
        @('server', (Join-Path $work 'server.mrpack'), $work, $ServerRevision)
    } else {
        @('both', (Join-Path $work 'full.mrpack'), (Join-Path $work 'lite.mrpack'),
            (Join-Path $work 'server.mrpack'), $work)
    }
    & $python.Source (Join-Path $PSScriptRoot 'package-mrpack.py') @packageArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Packaging the Packwiz exports failed with exit code $LASTEXITCODE."
    }

    foreach ($pack in Get-ChildItem -LiteralPath $work -Filter 'MODPACK-*.mrpack' -File) {
        Move-Item -LiteralPath $pack.FullName -Destination (Join-Path $dist $pack.Name) -Force
        Write-Host "Built dist/$($pack.Name)"
    }
} finally {
    $resolvedWork = (Resolve-Path -LiteralPath $work).Path
    $resolvedDist = (Resolve-Path -LiteralPath $dist).Path
    if ((Split-Path -Parent $resolvedWork) -eq $resolvedDist) {
        Remove-Item -LiteralPath $resolvedWork -Recurse -Force
    }
}
