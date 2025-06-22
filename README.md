# Health App - Flutter モバイルアプリ

健康管理のためのFlutterモバイルアプリケーションです。体重、カロリー、睡眠、運動データの記録と管理ができます。

## 📱 アプリの機能

- ユーザー認証（ログイン・登録）
- 健康データの記録（体重、カロリー、睡眠、運動）
- データの可視化（グラフ表示）
- カレンダー表示
- プロフィール管理

## 🛠️ 環境構築手順

### 前提条件

以下のソフトウェアがインストールされている必要があります：

1. **Flutter SDK** (3.8.1以上)
2. **Dart SDK** (Flutter SDKに含まれています)
3. **Android Studio** または **Visual Studio Code**
4. **Git**

### 1. Flutter SDKのインストール

#### Windows の場合：

1. [Flutter公式サイト](https://docs.flutter.dev/get-started/install/windows)からFlutter SDKをダウンロード
2. ダウンロードしたzipファイルを展開（例：`C:\flutter`）
3. 環境変数PATHに`C:\flutter\bin`を追加

#### macOS の場合：

```bash
# Homebrewを使用してインストール
brew install flutter
```

#### Linux の場合：

```bash
# snapを使用してインストール
sudo snap install flutter --classic
```

### 2. 開発環境の確認

Flutter環境が正しくセットアップされているか確認：

```bash
flutter doctor
```

### 3. プロジェクトのクローンと初期設定

```bash
# リポジトリをクローン
git clone <リポジトリURL>

# プロジェクトディレクトリに移動
cd <プロジェクト名>/frontend_mobile

# 依存関係をインストール
flutter pub get
```

### 4. 必要な依存関係

このプロジェクトでは以下のパッケージを使用しています：

- `http: ^1.1.0` - HTTP通信
- `provider: ^6.1.1` - 状態管理
- `shared_preferences: ^2.2.2` - ローカルストレージ
- `fl_chart: ^0.66.2` - グラフ表示
- `intl: ^0.19.0` - 日付処理
- `table_calendar: ^3.0.9` - カレンダー表示
- `font_awesome_flutter: ^10.6.0` - アイコン

### 5. バックエンドサーバーの起動

アプリを正常に動作させるには、バックエンドサーバーが起動している必要があります：

```bash
# プロジェクトルートディレクトリに移動
cd ..

# Dockerを使用してバックエンドを起動
docker-compose up -d
```

### 6. アプリの起動

#### Android エミュレーターで起動：

```bash
# Android エミュレーターを起動
flutter emulators --launch <エミュレーター名>

# アプリを起動
flutter run
```

#### iOS シミュレーターで起動（macOSのみ）：

```bash
# iOS シミュレーターを起動
open -a Simulator

# アプリを起動
flutter run
```

#### 実機で起動：

```bash
# 接続されたデバイスを確認
flutter devices

# 特定のデバイスで起動
flutter run -d <デバイスID>
```

#### Webブラウザで起動：

```bash
# Webブラウザで起動
flutter run -d chrome
```

## 🔧 開発用コマンド

### ビルド

```bash
# Android APKをビルド
flutter build apk

# iOS アプリをビルド（macOSのみ）
flutter build ios

# Webアプリをビルド
flutter build web
```

### テスト

```bash
# 単体テストを実行
flutter test

# ウィジェットテストを実行
flutter test test/widget_test.dart
```

### コード解析

```bash
# コードの静的解析
flutter analyze

# コードフォーマット
flutter format .
```

### 依存関係の管理

```bash
# 依存関係を更新
flutter pub upgrade

# 古い依存関係をチェック
flutter pub outdated

# キャッシュをクリア
flutter clean
flutter pub get
```

## 📁 プロジェクト構造

```
frontend_mobile/
├── lib/
│   ├── main.dart              # アプリのエントリーポイント
│   ├── models/                # データモデル
│   │   └── health_record.dart
│   ├── providers/             # 状態管理
│   │   ├── auth_provider.dart
│   │   └── health_data_provider.dart
│   ├── screens/               # 画面
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── services/              # API通信
│   │   └── api_service.dart
│   └── widgets/               # 再利用可能なウィジェット
├── assets/                    # 画像・アイコンなどのリソース
│   ├── icons/
│   └── images/
├── android/                   # Android固有の設定
├── ios/                       # iOS固有の設定
├── web/                       # Web固有の設定
└── test/                      # テストファイル
```

## 🌐 API設定

アプリはバックエンドAPIと通信します。API設定は`lib/services/api_service.dart`で管理されています。

デフォルトのAPI URL：
- 開発環境：`http://localhost:8000`
- 本番環境：設定に応じて変更

## 🚨 トラブルシューティング

### よくある問題と解決方法

1. **`flutter doctor`でエラーが出る場合**
   - Android Studio、Xcode、Visual Studio Codeが正しくインストールされているか確認
   - Android SDKのライセンスに同意：`flutter doctor --android-licenses`

2. **依存関係のエラー**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **ビルドエラー**
   ```bash
   # Gradleキャッシュをクリア（Android）
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

4. **iOS ビルドエラー（macOSのみ）**
   ```bash
   cd ios
   pod install
   cd ..
   ```

## 📚 参考リンク

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Dart言語ガイド](https://dart.dev/guides)
- [Flutter Widget カタログ](https://docs.flutter.dev/ui/widgets)
- [Provider パッケージ](https://pub.dev/packages/provider)

## 🤝 開発に参加する

1. このリポジトリをフォーク
2. 機能ブランチを作成：`git checkout -b feature/新機能名`
3. 変更をコミット：`git commit -m '新機能を追加'`
4. ブランチにプッシュ：`git push origin feature/新機能名`
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトは私的利用のためのものです。
