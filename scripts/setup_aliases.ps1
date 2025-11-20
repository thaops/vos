# scripts/setup_aliases.ps1

$profilePath = $PROFILE
$profileDir = Split-Path $profilePath -Parent

# Create folder if not exists
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$functions = @'
# ===============================
# Feature automation commands
# ===============================

function mfeature {
    param([Parameter(Mandatory=$true)][string]$name)
    & ".\scripts\make_feature.ps1" -FeatureName $name
}

function dfeature {
    param([Parameter(Mandatory=$true)][string]$name)
    & ".\scripts\delete_feature.ps1" -FeatureName $name
}

# Short aliases
Set-Alias mgen mfeature -ErrorAction SilentlyContinue
Set-Alias dgen dfeature -ErrorAction SilentlyContinue
'@

# Inject into PowerShell profile if missing
if (Test-Path $profilePath) {
    $content = Get-Content $profilePath -Raw
    if ($content -notmatch "function mfeature") {
        Add-Content $profilePath "`n$functions"
        Write-Host "Added alias functions to profile" -ForegroundColor Green
    } else {
        Write-Host "Alias already exists in profile" -ForegroundColor Yellow
    }
} else {
    Set-Content $profilePath $functions
    Write-Host "Created profile with alias functions" -ForegroundColor Green
}

. $profilePath
Write-Host ""
Write-Host "Aliases ready!"
Write-Host "Use: mfeature news"
Write-Host "Use: dfeature news"
