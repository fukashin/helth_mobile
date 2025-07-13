#!/bin/bash
echo "================================"
echo "本番環境でAPKをビルドします"
echo "接続先: https://backend-server-fukawa.onrender.com/api"
echo "================================"
flutter build apk --dart-define=ENV=prod --release
echo ""
echo "ビルド完了！"
echo "APKファイルの場所: build/app/outputs/flutter-apk/app-release.apk"
