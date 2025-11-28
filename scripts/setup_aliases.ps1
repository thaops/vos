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
    & ".\scripts\make_feature_simple.ps1" -FeatureName $name
}

function dfeature {
    param([Parameter(Mandatory=$true)][string]$name)
    & ".\scripts\delete_feature.ps1" -FeatureName $name
}

# Short aliases
Set-Alias mgen mfeature -ErrorAction SilentlyContinue
Set-Alias dgen dfeature -ErrorAction SilentlyContinue
'@

# Inject into PowerShell profile - always update to latest version
if (Test-Path $profilePath) {
    $content = Get-Content $profilePath -Raw
    if ($content -match "function mfeature") {
        # Replace existing mfeature function
        $newContent = $content -replace '(?s)function mfeature.*?Set-Alias mgen mfeature', $functions.Trim()
        if ($newContent -ne $content) {
            Set-Content $profilePath $newContent
            Write-Host "Updated mfeature function in profile" -ForegroundColor Green
        } else {
            Write-Host "Alias already up to date" -ForegroundColor Yellow
        }
    } else {
        Add-Content $profilePath "`n$functions"
        Write-Host "Added alias functions to profile" -ForegroundColor Green
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
