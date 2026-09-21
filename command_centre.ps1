<#
.SYNOPSIS
    Generalised project launcher using Windows Terminal (wt.exe).

.DESCRIPTION
    Reads projects.json, filters entries by mode, optionally ensures Docker
    is running, then opens each entry as a new tab or split pane in wt.exe.

.PARAMETER ProjectName
    The key of the project in projects.json (e.g. "MYPROJECT").

.PARAMETER Mode
    auto  = only entries with type "service"
    cmd   = only entries with type "terminal"
    all   = everything (default)

.PARAMETER DockerPath
    Optional override path to Docker Desktop.exe

.PARAMETER ConfigPath
    Optional override path to projects.json

.EXAMPLE
    .\command_centre.ps1 MYPROJECT all
.EXAMPLE
    .\command_centre.ps1 MYPROJECT auto -DockerPath "D:\Docker\Docker Desktop.exe"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [ValidateSet("auto", "cmd", "all")]
    [string]$Mode = "all",

    [string]$DockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe",

    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"

# ---------- Locate config ----------
if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot "projects.json"
}

if (-not (Test-Path $ConfigPath)) {
    Write-Host "❌ No projects.json found at $ConfigPath" -ForegroundColor Red
    Write-Host "   Copy projects.example.json to projects.json and edit it." -ForegroundColor Yellow
    exit 1
}

# ---------- Check wt.exe ----------
$wt = Get-Command wt.exe -ErrorAction SilentlyContinue
if (-not $wt) {
    Write-Host "❌ Windows Terminal (wt.exe) not found in PATH." -ForegroundColor Red
    Write-Host "   Install from: https://aka.ms/terminal" -ForegroundColor Yellow
    exit 1
}

# ---------- Load config ----------
try {
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
}
catch {
    Write-Host "❌ Failed to parse $ConfigPath" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

$project = $config.$ProjectName
if (-not $project) {
    Write-Host "❌ Project '$ProjectName' not found in $ConfigPath" -ForegroundColor Red
    $available = ($config.PSObject.Properties.Name) -join ", "
    Write-Host "   Available projects: $available" -ForegroundColor Yellow
    exit 1
}

# ---------- Filter by mode ----------
switch ($Mode) {
    "auto" { $items = @($project | Where-Object { $_.type -eq "service" }) }
    "cmd" { $items = @($project | Where-Object { $_.type -eq "terminal" }) }
    "all" { $items = @($project) }
}

if (-not $items -or $items.Count -eq 0) {
    Write-Host "⚠  No entries matched mode '$Mode' for project '$ProjectName'." -ForegroundColor Yellow
    exit 0
}

# ---------- Validate entries ----------
$valid = @()
foreach ($it in $items) {
    if (-not $it.name) { Write-Host "⚠  Skipping entry with no name." -ForegroundColor Yellow; continue }
    if (-not $it.path) { Write-Host "⚠  '$($it.name)' has no path — skipping." -ForegroundColor Yellow; continue }
    if (-not (Test-Path $it.path)) {
        Write-Host "⚠  Path does not exist for '$($it.name)': $($it.path)" -ForegroundColor Yellow
        continue
    }
    $valid += $it
}
$items = $valid

if ($items.Count -eq 0) {
    Write-Host "❌ No valid entries to launch." -ForegroundColor Red
    exit 1
}

# ---------- Ensure Docker if needed ----------
$needsDocker = @($items | Where-Object { $_.cmd -match '\bdocker\b' })
if ($needsDocker.Count -gt 0) {
    $dockerReady = $false
    try { docker info *> $null; $dockerReady = ($LASTEXITCODE -eq 0) } catch { $dockerReady = $false }

    if (-not $dockerReady) {
        if (-not (Test-Path $DockerPath)) {
            Write-Host "⚠  Docker needed but not found at $DockerPath" -ForegroundColor Yellow
            Write-Host "   Pass -DockerPath 'C:\path\to\Docker Desktop.exe' to override." -ForegroundColor Yellow
        }
        else {
            Write-Host "🐳 Starting Docker Desktop..." -ForegroundColor Yellow
            Start-Process $DockerPath

            $maxWait = 120   # seconds
            $waited = 0
            while (-not $dockerReady -and $waited -lt $maxWait) {
                Start-Sleep -Seconds 3
                $waited += 3
                try { docker info *> $null; $dockerReady = ($LASTEXITCODE -eq 0) } catch { $dockerReady = $false }
                Write-Host "." -NoNewline
            }
            Write-Host ""

            if ($dockerReady) {
                Write-Host "✅ Docker is ready." -ForegroundColor Green
            }
            else {
                Write-Host "⚠  Docker did not become ready in ${maxWait}s. Continuing anyway..." -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "✅ Docker already running." -ForegroundColor Green
    }
}

# ---------- Build wt.exe args ----------
$wtArgs = @()
for ($i = 0; $i -lt $items.Count; $i++) {
    $svc = $items[$i]
    $action = if ($i -eq 0) { "new-tab" } else { "split-pane" }

    $wtArgs += $action
    $wtArgs += "-d"; $wtArgs += $svc.path
    $wtArgs += "--title"; $wtArgs += $svc.name

    if ($svc.cmd -and $svc.cmd.ToString().Trim() -ne "") {
        $wtArgs += "cmd"; $wtArgs += "/k"; $wtArgs += $svc.cmd
    }
    else {
        $wtArgs += "cmd"
    }

    if ($i -lt $items.Count - 1) { $wtArgs += ";" }
}

Write-Host ""
Write-Host "🚀 Launching '$ProjectName' (mode: $Mode) — $($items.Count) pane(s)" -ForegroundColor Green
Write-Host ""

& wt.exe @wtArgs