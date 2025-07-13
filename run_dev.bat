@echo off
echo ================================
echo 開発環境でアプリを起動します
echo 接続先: http://10.0.2.2:8000/api
echo ================================
flutter run -d emulator-5554 --dart-define=ENV=dev
