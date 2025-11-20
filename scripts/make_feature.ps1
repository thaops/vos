param(
    [Parameter(Mandatory=$true)]
    [string]$FeatureName,
    
    [string]$ModelName = "",
    [string[]]$Usecases = @(),
    [string]$ApiBasePath = ""
)

# Load config từ file
$configPath = "mason_presets/config.json"
if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: Config file not found: $configPath" -ForegroundColor Red
    Write-Host "   Creating default config..." -ForegroundColor Yellow
    $defaultConfig = @{
        feature_name = ""
        model_name = ""
        usecase_definitions = @()
        has_local_storage = $true
        has_remote_api = $true
        has_pagination = $false
        has_search = $false
        has_full_cache = $false
        api_base_path = ""
    } | ConvertTo-Json -Depth 5
    $defaultConfig | Set-Content $configPath
}

$config = Get-Content $configPath | ConvertFrom-Json

# Auto-fill feature_name và model_name từ tham số
$config.feature_name = $FeatureName
$config.model_name = if ($ModelName -ne "") { $ModelName } else { $FeatureName }

# Hỏi usecase_definitions nếu chưa truyền
if ($Usecases.Count -eq 0) {
    Write-Host ""
    Write-Host "Enter usecase definitions (comma separated, format: name:type)" -ForegroundColor Cyan
    Write-Host "Example: get_news:List<Article>,get_article_detail:Article,create_article:void" -ForegroundColor Gray
    Write-Host "Press Enter to skip (will use defaults)" -ForegroundColor Yellow
    $usecaseInput = Read-Host "Usecases"
    
    if ($usecaseInput -ne "") {
        $config.usecase_definitions = $usecaseInput.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    }
} else {
    $config.usecase_definitions = $Usecases
}

# Hỏi các flags
Write-Host ""
Write-Host "Configure feature flags (Y/N, default shown in brackets):" -ForegroundColor Cyan

$hasLocalStorage = Read-Host "Has local storage? [Y]"
$config.has_local_storage = if ($hasLocalStorage -eq "" -or $hasLocalStorage -eq "Y" -or $hasLocalStorage -eq "y") { $true } else { $false }

$hasRemoteApi = Read-Host "Has remote API? [Y]"
$config.has_remote_api = if ($hasRemoteApi -eq "" -or $hasRemoteApi -eq "Y" -or $hasRemoteApi -eq "y") { $true } else { $false }

$hasPagination = Read-Host "Has pagination? [N]"
$config.has_pagination = if ($hasPagination -eq "Y" -or $hasPagination -eq "y") { $true } else { $false }

$hasSearch = Read-Host "Has search? [N]"
$config.has_search = if ($hasSearch -eq "Y" -or $hasSearch -eq "y") { $true } else { $false }

$hasFullCache = Read-Host "Has full cache (cache all pages)? [N]"
$config.has_full_cache = if ($hasFullCache -eq "Y" -or $hasFullCache -eq "y") { $true } else { $false }

# Hỏi API base path nếu chưa truyền
if ($ApiBasePath -eq "") {
    Write-Host ""
    $apiPath = Read-Host "API base path [/api/$FeatureName]"
    $config.api_base_path = if ($apiPath -ne "") { $apiPath } else { "/api/$FeatureName" }
} else {
    $config.api_base_path = $ApiBasePath
}

# Validate usecases
if ($config.usecase_definitions.Count -eq 0) {
    Write-Host "WARNING: No usecases defined. Using default..." -ForegroundColor Yellow
    $modelPascal = (Get-Culture).TextInfo.ToTitleCase($config.model_name)
    $config.usecase_definitions = @(
        "get_$($config.model_name)s:List<$modelPascal>",
        "get_$($config.model_name)_detail:$modelPascal"
    )
}

# Lưu config
$config | ConvertTo-Json -Depth 5 | Set-Content $configPath

Write-Host ""
Write-Host "Generating feature: $($config.feature_name)" -ForegroundColor Green
Write-Host "   Model: $($config.model_name)" -ForegroundColor Gray
Write-Host "   API Path: $($config.api_base_path)" -ForegroundColor Gray
Write-Host "   Usecases: $($config.usecase_definitions.Count)" -ForegroundColor Gray
Write-Host ""

# Chạy Mason với flag overwrite để tự động ghi đè file conflict
mason make feature_clean_architecture -c $configPath --on-conflict overwrite

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS: Feature '$($config.feature_name)' generated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "   1. Add route in lib/router/app_router.dart" -ForegroundColor Gray
    Write-Host "   2. Register DioApi if not already registered" -ForegroundColor Gray
    Write-Host "   3. Initialize Hive box if using local storage" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to generate feature" -ForegroundColor Red
    exit 1
}

