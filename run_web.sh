#!/bin/bash
echo "================================"
echo "Web開発環境でアプリを起動します"
echo "接続先: http://localhost:8000/api"
echo "================================"
flutter run -d chrome --web-port=8080 --dart-define=ENV=web
