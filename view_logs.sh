#!/bin/bash

# Script để xem log của app VOS

echo "🔍 VOS App Log Viewer"
echo "===================="
echo ""

# Kiểm tra platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - iOS Simulator
    echo "📱 Detected: macOS (iOS Simulator)"
    echo ""
    echo "Chọn option:"
    echo "1. Xem log real-time từ simulator"
    echo "2. Xem crash logs"
    echo "3. Xem log file trong app"
    echo ""
    read -p "Nhập số (1-3): " choice
    
    case $choice in
        1)
            echo "📺 Đang stream log từ simulator..."
            echo "Nhấn Ctrl+C để dừng"
            echo ""
            xcrun simctl spawn booted log stream --level=debug --predicate 'processImagePath contains "vos"'
            ;;
        2)
            echo "💥 Đang tìm crash logs..."
            echo ""
            # Tìm crash logs gần nhất
            find ~/Library/Logs/DiagnosticReports -name "*vos*" -o -name "*VOS*" | head -5
            echo ""
            read -p "Mở file nào? (đường dẫn): " crash_file
            if [ ! -z "$crash_file" ]; then
                open "$crash_file"
            fi
            ;;
        3)
            echo "📄 Log files được lưu tại:"
            echo "~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Documents/logs/"
            echo ""
            echo "Để tìm chính xác, chạy app và xem console output:"
            echo "flutter run"
            ;;
        *)
            echo "❌ Invalid choice"
            ;;
    esac
else
    echo "❌ Script này chỉ hỗ trợ macOS"
    echo "Cho Android, dùng: adb logcat | grep -i vos"
fi

