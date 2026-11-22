$ErrorActionPreference = 'Stop'

function Invoke-Packwiz {
    & $packwiz @args
    if ($LASTEXITCODE -ne 0) {
        throw "packwiz $($args -join ' ') failed with exit code $LASTEXITCODE."
    }
}

$source = Join-Path $PSScriptRoot 'pack'
if (-not (Test-Path -LiteralPath (Join-Path $source 'mods/voxy-0.6.0.jar') -PathType Leaf)) {
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

$timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$outputs = [ordered]@{
    full = "MODPACK-$timestamp.mrpack"
    lite = "MODPACK-$timestamp-lite.mrpack"
    server = "MODPACK-$timestamp-server.mrpack"
}
$cache = Join-Path $PSScriptRoot '.tools/packwiz-cache'
$dist = (New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot 'dist') -Force).FullName
$work = (New-Item -ItemType Directory -Path (Join-Path $dist ".build-$([guid]::NewGuid())")).FullName

try {
    $baseline = Join-Path $work 'full'
    Copy-Item -LiteralPath $source -Destination $baseline -Recurse -Force
    foreach ($profile in 'lite', 'server') {
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
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'profiles/lite/options.txt') -Destination (Join-Path $work 'lite')

    foreach ($profile in $outputs.Keys) {
        $archive = Join-Path $work $outputs[$profile]
        Push-Location -LiteralPath (Join-Path $work $profile)
        try {
            Invoke-Packwiz refresh
            Invoke-Packwiz --cache $cache modrinth export -o $archive
            if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) {
                throw "packwiz did not export $($outputs[$profile])."
            }
        } finally {
            Pop-Location
        }
    }

    foreach ($filename in $outputs.Values) {
        Move-Item -LiteralPath (Join-Path $work $filename) -Destination (Join-Path $dist $filename) -Force
        Write-Host "Built dist/$filename"
    }
} finally {
    $resolvedWork = (Resolve-Path -LiteralPath $work).Path
    $resolvedDist = (Resolve-Path -LiteralPath $dist).Path
    if ((Split-Path -Parent $resolvedWork) -eq $resolvedDist) {
        Remove-Item -LiteralPath $resolvedWork -Recurse -Force
    }
}
