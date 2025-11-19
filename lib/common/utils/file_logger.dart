import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// File logger để ghi log vào file, giữ log ngay cả khi app crash
class FileLogger {
  static File? _logFile;
  static bool _initialized = false;

  /// Khởi tạo file logger
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _logFile = File('${logDir.path}/app_log_$timestamp.txt');
      
      await _logFile!.writeAsString(
        '=== App Log Started at ${DateTime.now()} ===\n\n',
        mode: FileMode.append,
      );
      
      _initialized = true;
      if (kDebugMode) {
        print('✅ File logger initialized: ${_logFile!.path}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing file logger: $e');
      }
    }
  }

  /// Ghi log vào file
  static Future<void> log(String message, {String level = 'INFO'}) async {
    if (!_initialized) {
      await initialize();
    }

    if (_logFile == null) return;

    try {
      final timestamp = DateTime.now().toIso8601String();
      final logMessage = '[$timestamp] [$level] $message\n';
      
      await _logFile!.writeAsString(
        logMessage,
        mode: FileMode.append,
      );

      // Cũng in ra console
      if (kDebugMode) {
        print(logMessage.trim());
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error writing to log file: $e');
      }
    }
  }

  /// Ghi error với stack trace
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    await log(
      'ERROR: $error${context != null ? ' | Context: $context' : ''}',
      level: 'ERROR',
    );
    
    if (stackTrace != null) {
      await log('Stack trace: $stackTrace', level: 'ERROR');
    }
  }

  /// Lấy đường dẫn file log
  static String? getLogFilePath() {
    return _logFile?.path;
  }

  /// Đọc toàn bộ log file
  static Future<String?> readLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return null;
    }
    
    try {
      return await _logFile!.readAsString();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading log file: $e');
      }
      return null;
    }
  }

  /// Xóa log file cũ (giữ lại 5 file gần nhất)
  static Future<void> cleanOldLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      if (!await logDir.exists()) return;

      final logFiles = await logDir
          .list()
          .where((entity) => entity.path.endsWith('.txt'))
          .toList();

      if (logFiles.length > 5) {
        // Sắp xếp theo thời gian sửa đổi
        logFiles.sort((a, b) {
          final aStat = (a as File).statSync();
          final bStat = (b as File).statSync();
          return bStat.modified.compareTo(aStat.modified);
        });

        // Xóa các file cũ
        for (var i = 5; i < logFiles.length; i++) {
          await logFiles[i].delete();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cleaning old logs: $e');
      }
    }
  }
}

