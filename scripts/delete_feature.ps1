param(
    [Parameter(Mandatory=$true)]
    [string]$FeatureName
)

$featureDir = "lib/feature/$FeatureName"

Write-Host ""
Write-Host "Deleting feature: $FeatureName" -ForegroundColor Yellow
Write-Host ""

# 1. Xóa folder feature
if (Test-Path $featureDir) {
    Write-Host "   Removing directory: $featureDir" -ForegroundColor Gray
    Remove-Item -Recurse -Force $featureDir
    Write-Host "   SUCCESS: Deleted folder: $featureDir" -ForegroundColor Green
} else {
    Write-Host "   WARNING: Folder not found: $featureDir" -ForegroundColor Red
}

# 2. Tìm references
Write-Host ""
Write-Host "Searching for references to '$FeatureName'..." -ForegroundColor Yellow
Write-Host ""

$references = Get-ChildItem -Path lib -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue |
    Select-String -Pattern $FeatureName -CaseSensitive:$false |
    Select-Object -ExpandProperty Path -Unique

if ($references) {
    Write-Host "   Found references in:" -ForegroundColor Cyan
    $references | ForEach-Object { Write-Host "   - $_" -ForegroundColor Gray }
} else {
    Write-Host "   SUCCESS: No references found" -ForegroundColor Green
}

Write-Host ""
Write-Host "WARNING: Manual cleanup needed:" -ForegroundColor Yellow
Write-Host "   1. Remove imports/routes in lib/router/app_router.dart" -ForegroundColor Gray
Write-Host "   2. Remove Hive box init in main.dart (if exists)" -ForegroundColor Gray
Write-Host "   3. Remove any navigation/tab references" -ForegroundColor Gray
Write-Host "   4. Run: flutter pub get" -ForegroundColor Gray
Write-Host ""
Write-Host "SUCCESS: Feature deletion completed!" -ForegroundColor Green
Write-Host ""

