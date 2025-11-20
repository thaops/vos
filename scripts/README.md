# Feature Management Scripts

Hệ thống tự động hóa tạo và xóa feature theo Clean Architecture pattern.

## 🚀 Quick Start

### Bước 1: Setup Alias (chỉ cần làm 1 lần)

```powershell
.\scripts\setup_aliases.ps1
```

### Bước 2: Sử dụng

```powershell
# Tạo feature
mfeature news

# Xóa feature
dfeature news
```

## 📋 Chi tiết

### Tạo Feature Mới

#### Cách 1: Chỉ truyền tên (tự động fill config)

```powershell
mfeature news
```

Script sẽ tự động:
- Set `feature_name = "news"`
- Set `model_name = "news"`
- Set `api_base_path = "/api/news"`
- Tạo usecases mặc định nếu chưa có

#### Cách 2: Chỉnh config.json trước

1. Mở `mason_presets/config.json`
2. Điền thông tin feature (usecases, flags, etc.)
3. Chạy:

```powershell
mfeature news
```

#### Cách 3: Truyền đầy đủ tham số

```powershell
.\scripts\make_feature.ps1 `
    -FeatureName "news" `
    -ModelName "article" `
    -Usecases @("get_news:List<Article>", "get_article_detail:Article") `
    -HasPagination $true `
    -HasSearch $true
```

### Xóa Feature

```powershell
dfeature news
```

Script sẽ:
- Xóa thư mục `lib/feature/{feature_name}/`
- Tìm và báo cáo các file có reference
- Hướng dẫn cleanup thủ công

## 📁 Cấu trúc File

```
mason_presets/
  └── config.json          # Template config dùng chung

scripts/
  ├── make_feature.ps1     # Script tạo feature
  ├── delete_feature.ps1    # Script xóa feature
  └── setup_aliases.ps1     # Script setup alias (chạy 1 lần)
```

## ⚙️ Config Format

File `mason_presets/config.json`:

```json
{
  "feature_name": "",
  "model_name": "",
  "usecase_definitions": [],
  "has_local_storage": true,
  "has_remote_api": true,
  "has_pagination": false,
  "has_search": false,
  "has_full_cache": false,
  "api_base_path": ""
}
```

### Usecase Format

```
usecase_name:ReturnType
```

Ví dụ:
- `get_news:List<Article>` - List usecase
- `get_article_detail:Article` - Detail usecase
- `create_article:void` - Create usecase
- `update_article:bool` - Update usecase
- `delete_article:bool` - Delete usecase
- `search_news:List<Article>` - Search usecase

## 🔧 Troubleshooting

### Lỗi "Execution Policy"

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Lỗi "Config file not found"

Script sẽ tự động tạo file mặc định.

### Lỗi "Mason not found"

```powershell
dart pub global activate mason_cli
```

### Alias không hoạt động

```powershell
# Reload profile
. $PROFILE

# Hoặc chạy lại setup
.\scripts\setup_aliases.ps1
```

## 📝 Ví dụ Workflow

### Tạo feature "product"

```powershell
# 1. Chỉnh config.json (hoặc dùng default)
# 2. Chạy:
mfeature product

# 3. Thêm route trong app_router.dart
# 4. Test feature
```

### Xóa feature "product"

```powershell
dfeature product

# Sau đó manually xóa:
# - Route trong app_router.dart
# - Hive box init (nếu có)
# - References khác
```

## 🎯 Lưu ý

1. **Config dùng chung**: Chỉ cần 1 file `config.json`, không cần tạo nhiều preset
2. **Auto-fill**: Script tự động fill config nếu chỉ truyền tên feature
3. **Manual cleanup**: Sau khi xóa feature, cần xóa references thủ công
4. **Alias persistent**: Sau khi setup, alias hoạt động trong mọi PowerShell session

## ✅ Checklist sau khi tạo feature

- [ ] Feature được generate thành công
- [ ] Thêm route trong `lib/router/app_router.dart`
- [ ] Đăng ký `DioApi` nếu chưa có
- [ ] Khởi tạo Hive box nếu dùng local storage
- [ ] Test feature hoạt động

## ✅ Checklist sau khi xóa feature

- [ ] Folder feature đã bị xóa
- [ ] Xóa route trong `app_router.dart`
- [ ] Xóa Hive box init (nếu có)
- [ ] Xóa references trong navigation/tab
- [ ] Chạy `flutter pub get`
- [ ] Test app không bị lỗi

