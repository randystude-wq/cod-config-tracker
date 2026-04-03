#Requires -Version 5.1
<#
.SYNOPSIS
    Call of Duty Graphics Settings File Tracker v2.0

.DESCRIPTION
    Detects installed Call of Duty games across the unified "Call of Duty HQ"
    Steam/Battle.net launcher AND older standalone titles, then:
      1. Reports the graphics/video settings file for each game found.
      2. Copies those files to a capture folder.
      3. Optionally monitors game-launch events so captures stay current.

    Modern titles (2020-present) all ship inside the unified "Call of Duty HQ"
    client. Each game's graphics settings are written to the user profile on
    first launch, NOT when installed. This script watches those folders and
    identifies the game from the filename (e.g. cod24 = Black Ops 6).

    Also probes HP OMEN AI 2.0 telemetry data for additional install-path hints.

.PARAMETER CaptureFolder
    Where captured configs are stored. Default: <ScriptDir>\Captured_Configs

.PARAMETER Monitor
    After initial scan + copy, keep running and auto-copy when any game is
    launched and updates its graphics config. Press Ctrl+C to stop.

.PARAMETER ScanOnly
    Report file paths only, no copying.

.PARAMETER PollSeconds
    Monitor polling interval in seconds. Default: 5

.EXAMPLE
    .\CoD_Config_Tracker.ps1
    Scan and copy current graphics configs.

.EXAMPLE
    .\CoD_Config_Tracker.ps1 -Monitor
    Scan, copy, then watch for future game launches.

.EXAMPLE
    .\CoD_Config_Tracker.ps1 -ScanOnly
    Scan and report only.
#>

[CmdletBinding()]
param(
    [string]$CaptureFolder = (Join-Path $PSScriptRoot "Captured_Configs"),
    [switch]$Monitor,
    [switch]$ScanOnly,
    [int]$PollSeconds = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# =============================================================================
#  FILENAME -> GAME MAP
#  Used to identify games from their config filenames.
# =============================================================================
$FileToGame = [ordered]@{
    "s.1.0.cod25.txt0"    = [PSCustomObject]@{ Name="Call of Duty: Black Ops 7 (2025)";        Code="BO7"   }
    "s.1.0.cod25.txt1"    = [PSCustomObject]@{ Name="Call of Duty: Black Ops 7 (2025)";        Code="BO7"   }
    "s.1.0.cod24.txt0"    = [PSCustomObject]@{ Name="Call of Duty: Black Ops 6 (2024)";        Code="BO6"   }
    "s.1.0.cod24.txt1"    = [PSCustomObject]@{ Name="Call of Duty: Black Ops 6 (2024)";        Code="BO6"   }
    "options.4.cod23.cst" = [PSCustomObject]@{ Name="Call of Duty: Modern Warfare III (2023)"; Code="MW323" }
    "options.3.cod22.txt" = [PSCustomObject]@{ Name="Call of Duty: Modern Warfare II (2022)";  Code="MW222" }
    "config.ini"          = [PSCustomObject]@{ Name="Call of Duty: Black Ops Cold War (2020)"; Code="BOCW"  }
}

# Wildcard pattern - catches future cod titles automatically
$CodFilePattern = "s.1.0.cod*.txt*"

# =============================================================================
#  USER-PROFILE WATCH FOLDERS
#  Modern titles write configs here regardless of Steam or Battle.net install.
# =============================================================================
$Docs     = [Environment]::GetFolderPath("MyDocuments")
$LocalApp = $env:LOCALAPPDATA

$WatchFolders = @(
    # BO7+ moved storage to LocalAppData\Activision starting with cod25
    [PSCustomObject]@{
        Path        = Join-Path $LocalApp "Activision\Call of Duty\Players"
        GameLabel   = "CoD-HQ"
        MatchFiles  = @("s.1.0.cod*.txt*")
        Description = "BO7+ era (LocalAppData\Activision)"
    },
    # BO6 / MW3-2023 / MW2-2022 / Cold War - shared Documents folder
    [PSCustomObject]@{
        Path        = Join-Path $Docs "Call of Duty\players"
        GameLabel   = "CoD-HQ"
        MatchFiles  = @("s.1.0.cod*.txt*","options.*.cod??.cst","options.*.cod??.txt","config.ini","adv_options")
        Description = "Modern era (Documents\Call of Duty\players)"
    },
    # Vanguard uses its own separate Documents subfolder
    [PSCustomObject]@{
        Path        = Join-Path $Docs "Call of Duty Vanguard\players"
        GameLabel   = "Vanguard"
        MatchFiles  = @("adv_options")
        Description = "Vanguard (Documents\Call of Duty Vanguard\players)"
    }
)

# =============================================================================
#  CLASSIC / STANDALONE GAME DEFINITIONS  (configs stored in install directory)
# =============================================================================
$ClassicGames = @(
    [PSCustomObject]@{
        Name         = "Call of Duty: Modern Warfare (2019) / Warzone 1"
        Code         = "MW19"
        Subfolder    = "main\players\player"
        GraphicsFile = "config.cfg"
        SteamAppId   = $null
        SteamFolder  = $null
        BNetFolder   = "Call of Duty Modern Warfare"
        BNetRoots    = @("C:\Program Files (x86)\Call of Duty","C:\Program Files\Call of Duty")
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: Black Ops 4 (2018)"
        Code         = "BO4"
        Subfolder    = "players"
        GraphicsFile = "config.ini"
        SteamAppId   = $null
        SteamFolder  = $null
        BNetFolder   = "Call of Duty Black Ops 4"
        BNetRoots    = @("C:\Program Files (x86)\Call of Duty Black Ops 4","C:\Program Files\Call of Duty Black Ops 4")
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: WWII (2017)"
        Code         = "WWII"
        Subfolder    = "players2"
        GraphicsFile = "user_config_mp.cfg"
        SteamAppId   = "476600"
        SteamFolder  = "Call of Duty WWII"
        BNetFolder   = $null
        BNetRoots    = @()
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: Modern Warfare Remastered (2017)"
        Code         = "MWR"
        Subfolder    = "players2"
        GraphicsFile = "config"
        SteamAppId   = "393080"
        SteamFolder  = "Call of Duty Modern Warfare Remastered"
        BNetFolder   = $null
        BNetRoots    = @()
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: Infinite Warfare (2016)"
        Code         = "IW"
        Subfolder    = "players2"
        GraphicsFile = "config_mp.cfg"
        SteamAppId   = "292730"
        SteamFolder  = "Call of Duty Infinite Warfare"
        BNetFolder   = $null
        BNetRoots    = @()
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: Black Ops III (2015)"
        Code         = "BO3"
        Subfolder    = "players"
        GraphicsFile = "config.ini"
        SteamAppId   = "311210"
        SteamFolder  = "Call of Duty Black Ops III"
        BNetFolder   = $null
        BNetRoots    = @()
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: Advanced Warfare (2014)"
        Code         = "AW"
        Subfolder    = "Players2"
        GraphicsFile = "config_mp.cfg"
        SteamAppId   = "209650"
        SteamFolder  = "Call of Duty Advanced Warfare"
        BNetFolder   = $null
        BNetRoots    = @()
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: Ghosts (2013)"
        Code         = "Ghosts"
        Subfolder    = "players2"
        GraphicsFile = "config_mp.cfg"
        SteamAppId   = "209160"
        SteamFolder  = "Call of Duty Ghosts"
        BNetFolder   = $null
        BNetRoots    = @()
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: Black Ops II (2012)"
        Code         = "BO2"
        Subfolder    = "players"
        GraphicsFile = "hardware_mp.chp"
        SteamAppId   = "202970"
        SteamFolder  = "Call of Duty Black Ops II"
        BNetFolder   = $null
        BNetRoots    = @()
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: Modern Warfare 3 (2011)"
        Code         = "MW3_2011"
        Subfolder    = "players2"
        GraphicsFile = "config_mp.cfg"
        SteamAppId   = "115300"
        SteamFolder  = "Call of Duty Modern Warfare 3"
        BNetFolder   = $null
        BNetRoots    = @()
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: Black Ops (2010)"
        Code         = "BO1"
        Subfolder    = "players"
        GraphicsFile = "config_mp.cfg"
        SteamAppId   = "42700"
        SteamFolder  = "Call of Duty Black Ops"
        BNetFolder   = $null
        BNetRoots    = @()
    },
    [PSCustomObject]@{
        Name         = "Call of Duty: Modern Warfare 2 (2009)"
        Code         = "MW2_2009"
        Subfolder    = "players"
        GraphicsFile = "config_mp.cfg"
        SteamAppId   = "10180"
        SteamFolder  = "Call of Duty Modern Warfare 2"
        BNetFolder   = $null
        BNetRoots    = @()
    }
)

# =============================================================================
#  CONSOLE HELPERS  (ASCII only - no Unicode)
# =============================================================================
function Write-Header {
    param([string]$Text)
    $line = "=" * 70
    Write-Host ""
    Write-Host $line -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host $line -ForegroundColor Cyan
}
function Write-Step    { param([string]$t) Write-Host "  >> $t" -ForegroundColor Yellow }
function Write-Found   { param([string]$t) Write-Host "  [OK]  $t" -ForegroundColor Green }
function Write-Missing { param([string]$t) Write-Host "  [--]  $t" -ForegroundColor DarkGray }
function Write-Info    { param([string]$t) Write-Host "         $t" -ForegroundColor White }
function Write-Warn    { param([string]$t) Write-Host "  [!!]  $t" -ForegroundColor Magenta }
function Write-Event   { param([string]$t) Write-Host "  [>>]  $t" -ForegroundColor Cyan }

# =============================================================================
#  OMEN AI 2.0 - supplement game install-path detection
# =============================================================================
function Get-OmenGamePaths {
    $paths = @{}

    $omenPkg = Get-ChildItem (Join-Path $env:LOCALAPPDATA "Packages") `
        -Directory -Filter "AD2F1837.OMENCommandCenter*" -ErrorAction SilentlyContinue |
        Select-Object -First 1

    $omenLocalState = if ($omenPkg) { Join-Path $omenPkg.FullName "LocalState" } else { $null }

    foreach ($root in @($omenLocalState, (Join-Path $env:LOCALAPPDATA "Omen Gaming Hub"))) {
        if (-not $root -or -not (Test-Path $root)) { continue }

        Get-ChildItem $root -Recurse -Include "*.json","*.xml","*.db" -ErrorAction SilentlyContinue |
        ForEach-Object {
            try {
                $raw = Get-Content $_.FullName -Raw -ErrorAction Stop
                [regex]::Matches($raw, '"[^"]*(?:install|path|exe|dir)[^"]*"\s*:\s*"([^"]+)"', 'IgnoreCase') |
                ForEach-Object {
                    $p = $_.Groups[1].Value -replace '\\\\', '\'
                    if ($p -match 'Call of Duty' -and (Test-Path $p)) {
                        $leaf = Split-Path $p -Leaf
                        if (-not $paths.ContainsKey($leaf)) { $paths[$leaf] = $p }
                    }
                }
            } catch {}
        }
    }

    foreach ($rp in @("HKCU:\SOFTWARE\HP\OMEN","HKCU:\SOFTWARE\HP\OmenGamingHub","HKLM:\SOFTWARE\WOW6432Node\HP\OMEN")) {
        if (-not (Test-Path $rp)) { continue }
        try {
            Get-ChildItem $rp -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                foreach ($vn in @("GamePath","ExePath","InstallPath")) {
                    $v = $_.GetValue($vn)
                    if ($v -and $v -match 'Call of Duty' -and (Test-Path $v)) {
                        $leaf = Split-Path $v -Leaf
                        if (-not $paths.ContainsKey($leaf)) { $paths[$leaf] = $v }
                    }
                }
            }
        } catch {}
    }
    return $paths
}

# =============================================================================
#  STEAM DETECTION
# =============================================================================
function Get-SteamLibraries {
    $libs = @()
    foreach ($rp in @("HKLM:\SOFTWARE\WOW6432Node\Valve\Steam","HKLM:\SOFTWARE\Valve\Steam")) {
        if (-not (Test-Path $rp)) { continue }
        try {
            $root = (Get-ItemProperty $rp).InstallPath
            if ($root -and (Test-Path $root) -and ($libs -notcontains $root)) { $libs += $root }
            $vdf = Join-Path $root "config\libraryfolders.vdf"
            if (Test-Path $vdf) {
                [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"') | ForEach-Object {
                    $p = $_.Groups[1].Value -replace '\\\\', '\'
                    if ((Test-Path $p) -and ($libs -notcontains $p)) { $libs += $p }
                }
            }
        } catch {}
    }
    return $libs
}

function Get-SteamGamePath {
    param([string[]]$Libraries, [string]$AppId, [string]$FolderHint)
    foreach ($lib in $Libraries) {
        $apps = Join-Path $lib "steamapps"
        if ($AppId) {
            $mf = Join-Path $apps "appmanifest_$AppId.acf"
            if (Test-Path $mf) {
                $m = [regex]::Match((Get-Content $mf -Raw), '"installdir"\s+"([^"]+)"')
                if ($m.Success) {
                    $p = Join-Path $apps "common\$($m.Groups[1].Value)"
                    if (Test-Path $p) { return $p }
                }
            }
        }
        if ($FolderHint) {
            $p = Join-Path $apps "common\$FolderHint"
            if (Test-Path $p) { return $p }
        }
    }
    return $null
}

# =============================================================================
#  BATTLE.NET DETECTION
# =============================================================================
function Get-BNetGamePath {
    param([string]$FolderName, [string[]]$KnownRoots)
    if (-not $FolderName) { return $null }

    foreach ($base in @(
        "HKLM:\SOFTWARE\WOW6432Node\Blizzard Entertainment",
        "HKLM:\SOFTWARE\Blizzard Entertainment",
        "HKCU:\SOFTWARE\Blizzard Entertainment",
        "HKLM:\SOFTWARE\WOW6432Node\Activision",
        "HKLM:\SOFTWARE\Activision"
    )) {
        if (-not (Test-Path $base)) { continue }
        Get-ChildItem $base -ErrorAction SilentlyContinue | ForEach-Object {
            foreach ($vn in @("InstallPath","GamePath","Path")) {
                $v = $_.GetValue($vn)
                if ($v -and $v -like "*$FolderName*" -and (Test-Path $v)) { return $v }
            }
        }
    }

    foreach ($hive in @(
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    )) {
        if (-not (Test-Path $hive)) { continue }
        Get-ChildItem $hive -ErrorAction SilentlyContinue | ForEach-Object {
            $disp = $_.GetValue("DisplayName")
            $loc  = $_.GetValue("InstallLocation")
            if ($disp -and $loc -and $disp -like "*$FolderName*" -and (Test-Path $loc)) { return $loc }
        }
    }

    foreach ($root in $KnownRoots) { if (Test-Path $root) { return $root } }

    foreach ($d in @("C","D","E","F")) {
        foreach ($pf in @("Program Files (x86)","Program Files","Games")) {
            $c = "${d}:\$pf\$FolderName"
            if (Test-Path $c) { return $c }
        }
    }
    return $null
}

# =============================================================================
#  DETECT UNIFIED "CALL OF DUTY HQ" LAUNCHER  (Steam App 1938090 / BNet)
# =============================================================================
function Get-CoDHQLauncherInfo {
    param([string[]]$SteamLibs)

    $info = [PSCustomObject]@{
        Found          = $false
        Launcher       = $null
        InstallPath    = $null
        InstalledPacks = @()
    }

    # Steam: App 1938090, folder "Call of Duty HQ"
    $steamPath = Get-SteamGamePath -Libraries $SteamLibs -AppId "1938090" -FolderHint "Call of Duty HQ"
    if ($steamPath) {
        $info.Found = $true
        $info.Launcher = "Steam"
        $info.InstallPath = $steamPath
    }

    # Battle.net
    if (-not $info.Found) {
        $bnetPath = Get-BNetGamePath -FolderName "Call of Duty" -KnownRoots @(
            "C:\Program Files (x86)\Call of Duty",
            "C:\Program Files\Call of Duty",
            "D:\Games\Call of Duty",
            "E:\Games\Call of Duty"
        )
        if ($bnetPath) {
            $info.Found = $true
            $info.Launcher = "Battle.net"
            $info.InstallPath = $bnetPath
        }
    }

    if (-not $info.Found) { return $info }

    # Try to detect which game content packs are present inside HQ folder
    $packPatterns = @{
        "Black Ops 7"        = @("BlackOps7","BO7","cod25*")
        "Black Ops 6"        = @("BlackOps6","BO6","cod24*")
        "Modern Warfare III" = @("ModernWarfareIII","MWIII","cod23*")
        "Modern Warfare II"  = @("ModernWarfareII","MWII","cod22*")
        "Warzone"            = @("Warzone","WZ","warzone*")
        "Cold War"           = @("BlackOpsColdWar","BOCW","cod20*")
        "Vanguard"           = @("Vanguard","VG","cod21*")
    }

    foreach ($pack in $packPatterns.GetEnumerator()) {
        foreach ($pattern in $pack.Value) {
            $match = Get-ChildItem $info.InstallPath -Directory -Filter $pattern -ErrorAction SilentlyContinue |
                     Select-Object -First 1
            if ($match) {
                $info.InstalledPacks += $pack.Key
                break
            }
        }
    }

    $dataProduct = Join-Path $info.InstallPath "Data\Product"
    if (Test-Path $dataProduct) {
        Get-ChildItem $dataProduct -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            if ($info.InstalledPacks -notcontains $_.Name) { $info.InstalledPacks += $_.Name }
        }
    }

    return $info
}

# =============================================================================
#  COPY HELPER
# =============================================================================
function Copy-GraphicsConfig {
    param([string]$SourcePath, [string]$GameCode, [string]$Launcher, [string]$CaptureRoot)

    $destDir = Join-Path $CaptureRoot "$GameCode\$Launcher"
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

    $ts       = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $baseName = Split-Path $SourcePath -Leaf
    $ext      = [System.IO.Path]::GetExtension($baseName)
    $stem     = [System.IO.Path]::GetFileNameWithoutExtension($baseName)

    $destCurrent = Join-Path $destDir $baseName
    $destBackup  = Join-Path $destDir "${stem}_${ts}${ext}"

    try {
        if (Test-Path $destCurrent) {
            Copy-Item -Path $destCurrent -Destination $destBackup -Force
        }
        Copy-Item -Path $SourcePath -Destination $destCurrent -Force
        Write-Found "Copied [$GameCode][$Launcher] $baseName  ->  $destDir"
        return $true
    } catch {
        Write-Warn "Copy failed: $_"
        return $false
    }
}

# =============================================================================
#  IDENTIFY GAME FROM CONFIG FILENAME
# =============================================================================
function Resolve-GameFromFilename {
    param([string]$FileName, [string]$ParentFolder)

    if ($FileToGame.Contains($FileName)) { return $FileToGame[$FileName] }

    if ($FileName -like $CodFilePattern) {
        $ver = [regex]::Match($FileName, 'cod(\d+)').Groups[1].Value
        return [PSCustomObject]@{ Name="Call of Duty cod$ver (auto-detected)"; Code="cod$ver" }
    }

    if ($FileName -eq "adv_options" -and $ParentFolder -match "Vanguard") {
        return [PSCustomObject]@{ Name="Call of Duty: Vanguard (2021)"; Code="VG" }
    }

    if ($FileName -eq "config.ini" -and $ParentFolder -match "Call of Duty\\players") {
        return [PSCustomObject]@{ Name="Call of Duty: Black Ops Cold War (2020)"; Code="BOCW" }
    }

    return $null
}

# =============================================================================
#  SCAN -- modern games (user-profile config files)
# =============================================================================
function Invoke-ModernScan {
    param([string]$LauncherLabel, [switch]$CopyFiles)

    $results = New-Object System.Collections.Generic.List[PSCustomObject]

    foreach ($wf in $WatchFolders) {
        if (-not (Test-Path $wf.Path)) {
            Write-Missing "Folder not found: $($wf.Path)  [$($wf.Description)]"
            continue
        }

        Write-Info "Scanning: $($wf.Path)"

        foreach ($pattern in $wf.MatchFiles) {
            $files = Get-ChildItem $wf.Path -Filter $pattern -ErrorAction SilentlyContinue
            foreach ($f in $files) {
                $game = Resolve-GameFromFilename -FileName $f.Name -ParentFolder $wf.Path
                if (-not $game) { continue }

                Write-Found "[$LauncherLabel] $($game.Name)  ->  $($f.Name)"
                Write-Info  "Path: $($f.FullName)"
                Write-Info  "Last modified: $($f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))"

                $r = [PSCustomObject]@{
                    Game         = $game.Name
                    Code         = $game.Code
                    Launcher     = $LauncherLabel
                    GraphicsFile = $f.Name
                    FullPath     = $f.FullName
                    Folder       = $f.DirectoryName
                    LastModified = $f.LastWriteTime
                }
                $results.Add($r)

                if ($CopyFiles) {
                    $null = Copy-GraphicsConfig -SourcePath $f.FullName -GameCode $game.Code `
                        -Launcher $LauncherLabel -CaptureRoot $CaptureFolder
                }
            }
        }
    }
    return $results
}

# =============================================================================
#  SCAN -- classic standalone games (install-directory configs)
# =============================================================================
function Invoke-ClassicScan {
    param([string[]]$SteamLibs, $OmenPaths, [switch]$CopyFiles)

    $results = New-Object System.Collections.Generic.List[PSCustomObject]

    foreach ($game in $ClassicGames) {
        Write-Step $game.Name
        $installDir = $null
        $launcher   = $null

        if ($SteamLibs.Count -gt 0 -and $game.SteamAppId) {
            $installDir = Get-SteamGamePath -Libraries $SteamLibs -AppId $game.SteamAppId -FolderHint $game.SteamFolder
            if ($installDir) { $launcher = "Steam" }
        }

        if (-not $installDir -and $game.BNetFolder) {
            $installDir = Get-BNetGamePath -FolderName $game.BNetFolder -KnownRoots $game.BNetRoots
            if ($installDir) { $launcher = "Battle.net" }
        }

        if (-not $installDir) {
            foreach ($k in $OmenPaths.Keys) {
                $sfHint = if ($game.SteamFolder) { $game.SteamFolder } else { "NOMATCH" }
                if ($k -like "*$($game.Code)*" -or $k -like "*$sfHint*") {
                    $installDir = $OmenPaths[$k]
                    $launcher   = "OMEN-AI"
                    break
                }
            }
        }

        if (-not $installDir) { Write-Missing "Not installed"; continue }
        Write-Info "[$launcher] $installDir"

        $cfgPath = Join-Path $installDir "$($game.Subfolder)\$($game.GraphicsFile)"

        if (Test-Path $cfgPath) {
            $mod = (Get-Item $cfgPath).LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            Write-Found "Graphics file: $($game.GraphicsFile)   Modified: $mod"
            Write-Info  "Path: $cfgPath"

            $r = [PSCustomObject]@{
                Game         = $game.Name
                Code         = $game.Code
                Launcher     = $launcher
                GraphicsFile = $game.GraphicsFile
                FullPath     = $cfgPath
                Folder       = Split-Path $cfgPath -Parent
                LastModified = (Get-Item $cfgPath).LastWriteTime
            }
            $results.Add($r)

            if ($CopyFiles) {
                $null = Copy-GraphicsConfig -SourcePath $cfgPath -GameCode $game.Code `
                    -Launcher $launcher -CaptureRoot $CaptureFolder
            }
        } else {
            Write-Missing "Config not yet created at: $cfgPath"
            Write-Info   "(Launch the game once to generate the settings file)"
        }
    }
    return $results
}

# =============================================================================
#  MONITOR
#  Polls user-profile watch folders and known file list. Auto-copies whenever
#  a CoD game is launched and updates its graphics config.
# =============================================================================
function Start-Monitor {
    param(
        [System.Collections.Generic.List[PSCustomObject]]$InitialFiles,
        [string]$HqLauncher
    )

    Write-Header "MONITORING FOR GAME LAUNCHES  --  Press Ctrl+C to stop"
    Write-Info "Watching profile folders + $($InitialFiles.Count) known file(s)"
    Write-Info "Poll interval: ${PollSeconds}s"
    Write-Host ""
    Write-Host "  When you launch any CoD title its graphics file will be captured automatically." -ForegroundColor Yellow
    Write-Host ""

    # Seed last-write-time table from initial scan
    $watchList = @{}
    foreach ($f in $InitialFiles) {
        $seedItem = Get-Item $f.FullPath -ErrorAction SilentlyContinue
        $watchList[$f.FullPath] = if ($seedItem) { $seedItem.LastWriteTime } else { [datetime]::MinValue }
    }

    try {
        while ($true) {

            # 1. Check known files for changes
            foreach ($path in @($watchList.Keys)) {
                if (-not (Test-Path $path)) { continue }
                $item = Get-Item $path -ErrorAction SilentlyContinue
                if (-not $item) { continue }
                $cur = $item.LastWriteTime
                if ($cur -ne $watchList[$path]) {
                    $watchList[$path] = $cur
                    $ts   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                    $fn   = Split-Path $path -Leaf
                    $game = Resolve-GameFromFilename -FileName $fn -ParentFolder (Split-Path $path -Parent)
                    $gName = if ($game) { $game.Name } else { "Unknown CoD Title" }
                    $gCode = if ($game) { $game.Code } else { "unknown" }

                    Write-Event "[$ts] GAME LAUNCHED -- $gName"
                    Write-Info  "Updated file: $path"
                    $null = Copy-GraphicsConfig -SourcePath $path -GameCode $gCode `
                        -Launcher $HqLauncher -CaptureRoot $CaptureFolder
                }
            }

            # 2. Scan watch folders for NEW config files (new game launched for first time)
            foreach ($wf in $WatchFolders) {
                if (-not (Test-Path $wf.Path)) { continue }
                foreach ($pattern in $wf.MatchFiles) {
                    $newFiles = Get-ChildItem $wf.Path -Filter $pattern -ErrorAction SilentlyContinue |
                                Where-Object { -not $watchList.ContainsKey($_.FullName) }
                    foreach ($nf in $newFiles) {
                        $game  = Resolve-GameFromFilename -FileName $nf.Name -ParentFolder $wf.Path
                        $ts    = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                        $gName = if ($game) { $game.Name } else { "Auto-detected CoD title" }
                        $gCode = if ($game) { $game.Code } else { [System.IO.Path]::GetFileNameWithoutExtension($nf.Name) }

                        Write-Event "[$ts] NEW CONFIG DETECTED -- $gName"
                        Write-Info  "File: $($nf.FullName)"
                        $watchList[$nf.FullName] = $nf.LastWriteTime

                        $null = Copy-GraphicsConfig -SourcePath $nf.FullName -GameCode $gCode `
                            -Launcher $HqLauncher -CaptureRoot $CaptureFolder
                    }
                }
            }

            Start-Sleep -Seconds $PollSeconds
        }
    } finally {
        Write-Host ""
        Write-Host "  Monitor stopped." -ForegroundColor Yellow
    }
}

# =============================================================================
#  ENTRY POINT
# =============================================================================
Write-Header "CALL OF DUTY GRAPHICS CONFIG TRACKER v2.0"
Write-Info "Capture folder : $CaptureFolder"
Write-Info "Mode           : $(if ($ScanOnly) { 'Scan only' } elseif ($Monitor) { 'Scan + Monitor' } else { 'Scan + Copy' })"

if (-not $ScanOnly -and -not (Test-Path $CaptureFolder)) {
    New-Item -ItemType Directory -Path $CaptureFolder -Force | Out-Null
}

# --- Launcher detection ---
Write-Header "LAUNCHER DETECTION"

Write-Step "OMEN AI 2.0 -- querying game telemetry..."
$omenPaths = Get-OmenGamePaths
Write-Info "OMEN: $($omenPaths.Count) CoD-related path(s) found"

Write-Step "Steam -- locating libraries..."
$steamLibs = @(Get-SteamLibraries)
if ($steamLibs.Count -gt 0) {
    Write-Info "Steam libraries: $($steamLibs -join ' | ')"
} else {
    Write-Info "Steam not detected"
}

Write-Step "Unified CoD HQ launcher detection..."
$hqInfo = Get-CoDHQLauncherInfo -SteamLibs $steamLibs
if ($hqInfo.Found) {
    Write-Found "Call of Duty HQ  [$($hqInfo.Launcher)]  ->  $($hqInfo.InstallPath)"
    if ($hqInfo.InstalledPacks.Count -gt 0) {
        Write-Info "Content packs detected: $($hqInfo.InstalledPacks -join ', ')"
    } else {
        Write-Info "Content pack subfolders not yet visible (game may still be installing)"
    }
    $hqLauncher = $hqInfo.Launcher
} else {
    Write-Missing "Call of Duty HQ unified launcher not found (may still be installing)"
    $hqLauncher = "Unknown"
}

# --- Modern game scan ---
Write-Header "MODERN TITLES  (Call of Duty HQ -- user-profile configs)"
Write-Info "Graphics files are created on FIRST LAUNCH of each game."
Write-Info "If a game shows not found, launch it once to generate its settings file."
$modernResults = Invoke-ModernScan -LauncherLabel $hqLauncher -CopyFiles:(-not $ScanOnly)

# --- Classic standalone game scan ---
Write-Header "CLASSIC / STANDALONE TITLES  (install-directory configs)"
$classicResults = Invoke-ClassicScan -SteamLibs $steamLibs -OmenPaths $omenPaths -CopyFiles:(-not $ScanOnly)

# --- Summary ---
$allFound = New-Object System.Collections.Generic.List[PSCustomObject]
foreach ($r in $modernResults)  { $allFound.Add($r) }
foreach ($r in $classicResults) { $allFound.Add($r) }

Write-Header "SUMMARY -- $($allFound.Count) GRAPHICS CONFIG FILE(S) FOUND"

if ($allFound.Count -eq 0) {
    Write-Warn "No graphics config files found yet."
    Write-Info "This is normal if CoD HQ was just installed."
    Write-Info "Launch a game to generate its settings file."
    if ($Monitor) { Write-Info "Monitor mode will capture configs as soon as you play." }
} else {
    Write-Host ""
    $fmt = "  {0,-8}  {1,-12}  {2,-40}  {3}"
    Write-Host ($fmt -f "Code","Launcher","Game","Graphics File") -ForegroundColor Cyan
    Write-Host ($fmt -f "--------","------------","----------------------------------------","--------------------") -ForegroundColor DarkGray
    foreach ($r in $allFound) {
        Write-Host ($fmt -f $r.Code, $r.Launcher, $r.Game, $r.GraphicsFile)
    }
    Write-Host ""
    if (-not $ScanOnly) { Write-Found "Configs copied to: $CaptureFolder" }
}

# --- Start monitor ---
if ($Monitor) {
    Start-Monitor -InitialFiles $allFound -HqLauncher $hqLauncher
}
