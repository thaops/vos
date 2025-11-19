# 🌐 WebView Integration Guide

## 📋 Tổng quan

Hướng dẫn tích hợp WebView với Flutter app để xử lý authentication và token sharing.

## 🔧 Các thay đổi đã thực hiện

### ✅ 1. Sửa lỗi "Invalid data" khi login

**Vấn đề:** `clearCache()` và `clearLocalStorage()` được gọi mỗi lần `onPageStarted` → xóa cookie/session → backend trả về "invalid data".

**Giải pháp:** 
- ✅ Gỡ bỏ `clearCache()` và `clearLocalStorage()` khỏi `onPageStarted`
- ✅ Chỉ clear cache một lần duy nhất khi khởi tạo WebView
- ✅ Thêm kiểm tra cookies sau khi load xong

### ✅ 2. Thêm JavaScript Channel để nhận token

**Channel:** `LoginChannel`
**Mục đích:** Nhận token từ web và xử lý trong Flutter

## 🚀 Cách sử dụng cho Developer Web

### 1. Gửi token sau khi login thành công

```javascript
// Trong web app, sau khi login thành công
function onLoginSuccess(token) {
    // Gửi token về Flutter app
    LoginChannel.postMessage(token);
    
    // Hoặc gửi object phức tạp hơn
    const loginData = {
        token: token,
        user: userData,
        expires: expirationTime
    };
    LoginChannel.postMessage(JSON.stringify(loginData));
}
```

### 2. Gửi thông báo logout

```javascript
// Khi user logout
function onLogout() {
    LoginChannel.postMessage('LOGOUT');
}
```

### 3. Gửi thông báo lỗi

```javascript
// Khi có lỗi authentication
function onAuthError(errorMessage) {
    LoginChannel.postMessage(`ERROR:${errorMessage}`);
}
```

## 🔍 Debug và Monitoring

### 1. Kiểm tra cookies

Flutter app sẽ tự động log cookies sau mỗi lần load page:

```
🍪 Current cookies: session_id=abc123; token=xyz789; user=auth_data
✅ Found authentication cookies!
```

### 2. Kiểm tra token từ web

```
✅ Received token from web: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 📱 Flutter App - Xử lý token

### 1. Lưu token vào storage

```dart
// Trong LoginChannel handler
..addJavaScriptChannel(
  'LoginChannel',
  onMessageReceived: (JavaScriptMessage message) {
    try {
      final token = message.message;
      print('✅ Received token from web: $token');
      
      // Lưu token vào SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('auth_token', token);
      });
      
      // Hoặc lưu vào Hive
      Hive.box('auth').put('token', token);
      
    } catch (e) {
      print('❌ Error handling login token: $e');
    }
  },
)
```

### 2. Sử dụng token cho API calls

```dart
// Lấy token từ storage
final token = await SharedPreferences.getInstance()
    .then((prefs) => prefs.getString('auth_token'));

// Sử dụng trong API calls
final response = await dio.get('/api/user', 
    options: Options(headers: {'Authorization': 'Bearer $token'}));
```

## ⚠️ Lưu ý quan trọng

### 1. Security
- ✅ Token được gửi qua JavaScript channel (an toàn trong app)
- ✅ Không lưu token trong localStorage của web
- ✅ Sử dụng HTTPS cho tất cả API calls

### 2. Error Handling
- ✅ Luôn wrap JavaScript channel calls trong try-catch
- ✅ Validate token trước khi sử dụng
- ✅ Handle logout khi token hết hạn

### 3. Performance
- ✅ Chỉ gửi token khi cần thiết (login success)
- ✅ Không gửi token mỗi lần page load
- ✅ Cache token trong Flutter app

## 🧪 Testing

### 1. Test login flow
1. Mở web trong WebView
2. Thực hiện login
3. Kiểm tra console log: `✅ Received token from web: ...`
4. Kiểm tra cookies: `🍪 Current cookies: ...`

### 2. Test logout flow
1. Gọi logout từ web
2. Kiểm tra token được clear
3. Verify user bị redirect về login page

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra console logs
2. Verify JavaScript channel được gọi đúng
3. Check token format và validation
4. Test trên thiết bị thật (không phải emulator)

---

**Cập nhật lần cuối:** $(date)
**Phiên bản:** 1.0.0
Platform  Firebase App Id
web       1:119692400826:web:3e6a398b8ba23ac1a24a83
android   1:119692400826:android:d3e9897866b28138a24a83
ios       1:119692400826:ios:2b98cef5df373e91a24a83
macos     1:119692400826:ios:2b98cef5df373e91a24a83
windows   1:119692400826:web:10ac891158e858d0a24a83