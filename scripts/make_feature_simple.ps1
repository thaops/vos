param(
    [Parameter(Mandatory=$true)]
    [string]$FeatureName
)

# Auto-set model_name = feature_name
$ModelName = $FeatureName

Write-Host ""
Write-Host "Generating feature: $FeatureName" -ForegroundColor Green
Write-Host "   Model: $ModelName" -ForegroundColor Gray
Write-Host "   Usecases: 1 (skeleton only)" -ForegroundColor Gray
Write-Host ""

# Tạo config file tạm chỉ với 2 vars cần thiết
$tempConfig = @{
    feature_name = $FeatureName
    model_name = $ModelName
} | ConvertTo-Json

$tempConfigPath = "mason_presets/temp_config_$([System.Guid]::NewGuid().ToString('N').Substring(0,8)).json"
$tempConfig | Set-Content $tempConfigPath

# Chạy Mason với brick feature_simple (KHÔNG dùng config cũ)
mason make feature_simple -c $tempConfigPath --on-conflict overwrite

# Xóa file config tạm
if (Test-Path $tempConfigPath) {
    Remove-Item $tempConfigPath -Force
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS: Feature '$FeatureName' generated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "   1. Add route in lib/router/app_router.dart" -ForegroundColor Gray
    Write-Host "   2. Register DioApi if not already registered" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to generate feature" -ForegroundColor Red
    exit 1
}

