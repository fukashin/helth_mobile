#!/bin/bash
echo "================================"
echo "本番環境でアプリを起動します"
echo "接続先: https://backend-server-fukawa.onrender.com/api"
echo "================================"
flutter run -d emulator-5554 --dart-define=ENV=prod
