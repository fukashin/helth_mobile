# 健康管理アプリ（Health App）プロジェクトドキュメント

## 目次

1. [プロジェクト概要](#プロジェクト概要)
2. [フォルダ構成](#フォルダ構成)
3. [ファイルごとの役割](#ファイルごとの役割)
4. [環境設定](#環境設定)
5. [実行方法](#実行方法)
6. [開発フロー](#開発フロー)

## プロジェクト概要

このプロジェクトは、Flutterを使用したクロスプラットフォーム対応の健康管理モバイルアプリケーションです。ユーザーは体重、カロリー摂取量、睡眠時間、運動記録などの健康データを記録・管理することができます。

### 主な機能

- ユーザー認証（ログイン・登録）
- 健康データの記録（体重、カロリー、睡眠、運動）
- 日別・週別のデータ表示
- カレンダー表示
- プロフィール管理

### 使用技術

- **フレームワーク**: Flutter 3.8.1+
- **言語**: Dart
- **状態管理**: Provider
- **ローカルストレージ**: Shared Preferences
- **HTTP通信**: http パッケージ
- **グラフ表示**: fl_chart
- **カレンダー表示**: table_calendar
- **日付処理**: intl
- **アイコン**: font_awesome_flutter

## フォルダ構成

```
health_mobile/
├── android/                   # Android固有の設定
├── assets/                    # 画像・アイコンなどのリソース
│   ├── icons/                 # アプリで使用するアイコン
│   └── images/                # アプリで使用する画像
├── build/                     # ビルド出力ディレクトリ
├── ios/                       # iOS固有の設定
├── lib/                       # Dartコードの主要部分
│   ├── config/                # 環境設定
│   ├── models/                # データモデル
│   ├── providers/             # 状態管理
│   ├── screens/               # 画面
│   ├── services/              # API通信
│   └── widgets/               # 再利用可能なウィジェット
├── linux/                     # Linux固有の設定
├── macos/                     # macOS固有の設定
├── test/                      # テストファイル
├── web/                       # Web固有の設定
├── windows/                   # Windows固有の設定
├── .dockerignore              # Dockerビルド時に無視するファイル
├── .gitignore                 # Gitで無視するファイル
├── .metadata                  # Flutterのメタデータ
├── analysis_options.yaml      # 静的解析の設定
├── build_prod.bat             # 本番環境用ビルドスクリプト（Windows）
├── build_prod.sh              # 本番環境用ビルドスクリプト（Unix）
├── dockerfile                 # Dockerコンテナ構築設定
├── pubspec.lock               # 依存関係のロックファイル
├── pubspec.yaml               # プロジェクト設定と依存関係
├── README.md                  # プロジェクト説明
├── run_dev.bat                # 開発環境実行スクリプト（Windows）
├── run_dev.sh                 # 開発環境実行スクリプト（Unix）
├── run_prod.bat               # 本番環境実行スクリプト（Windows）
└── run_prod.sh                # 本番環境実行スクリプト（Unix）
```

## ファイルごとの役割

### 設定ファイル

#### pubspec.yaml
プロジェクトの設定と依存関係を管理するファイルです。アプリ名、バージョン、使用するパッケージなどが定義されています。

```yaml
# 主な依存関係
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8    # iOSスタイルのアイコン
  http: ^1.1.0               # HTTP通信用
  provider: ^6.1.1           # 状態管理用
  shared_preferences: ^2.2.2 # ローカルストレージ用
  fl_chart: ^0.66.2          # グラフ表示用
  intl: ^0.19.0              # 日付処理用
  table_calendar: ^3.0.9     # カレンダー表示用
  font_awesome_flutter: ^10.6.0 # アイコン用
```

#### run_dev.bat / run_dev.sh
開発環境でアプリを起動するためのスクリプトです。環境変数`ENV`を`dev`に設定し、開発環境のAPIエンドポイントに接続します。

```batch
@echo off
echo ================================
echo 開発環境でアプリを起動します
echo 接続先: http://10.0.2.2:8000/api
echo ================================
flutter run -d emulator-5554 --dart-define=ENV=dev
```

#### run_prod.bat / run_prod.sh
本番環境でアプリを起動するためのスクリプトです。環境変数`ENV`を`prod`に設定し、本番環境のAPIエンドポイントに接続します。

```batch
@echo off
echo ================================
echo 本番環境でアプリを起動します
echo 接続先: https://backend-server-fukawa.onrender.com/api
echo ================================
flutter run -d emulator-5554 --dart-define=ENV=prod
```

#### build_prod.bat / build_prod.sh
本番環境用のAPKをビルドするためのスクリプトです。環境変数`ENV`を`prod`に設定し、リリースモードでビルドします。

```batch
@echo off
echo ================================
echo 本番環境でAPKをビルドします
echo 接続先: https://backend-server-fukawa.onrender.com/api
echo ================================
flutter build apk --dart-define=ENV=prod --release
echo.
echo ビルド完了！
echo APKファイルの場所: build\app\outputs\flutter-apk\app-release.apk
```

#### dockerfile
Flutterアプリケーションのコンテナを構築するための設定ファイルです。

```dockerfile
FROM dart:3.8 as build

# Flutter SDK の安定版インストール
RUN git clone https://github.com/flutter/flutter.git /flutter -b stable
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app
COPY . .

EXPOSE 8080
```

### lib/config/

#### environment.dart
環境設定を管理するクラスです。エミュレータ開発環境、Web開発環境、本番環境のAPIエンドポイントを切り替える機能を提供します。

```dart
// 環境設定クラス
// 起動コマンドに応じてバックエンドの接続先を切り替える
class Environment {
  // 環境タイプの定義
  static const String dev = 'dev';
  static const String web = 'web';
  static const String prod = 'prod';
  
  // 現在の環境（デフォルトは開発環境）
  static String _currentEnvironment = dev;
  
  // 環境別のベースURL設定
  static const Map<String, String> _baseUrls = {
    dev: 'http://10.0.2.2:8000/api',  // エミュレータ用（Androidエミュレータからホストマシンへのアクセス）
    web: 'http://localhost:8000/api',  // Web開発環境用（ブラウザからのアクセス）
    prod: 'https://backend-server-fukawa.onrender.com/api',  // 本番環境
  };
  
  // 現在の環境を設定
  static void setEnvironment(String environment) {
    if (_baseUrls.containsKey(environment)) {
      _currentEnvironment = environment;
    } else {
      throw ArgumentError('無効な環境が指定されました: $environment');
    }
  }
  
  // 現在の環境を取得
  static String get currentEnvironment => _currentEnvironment;
  
  // 現在の環境のベースURLを取得
  static String get baseUrl => _baseUrls[_currentEnvironment]!;
  
  // 開発環境かどうかを判定
  static bool get isDev => _currentEnvironment == dev;
  
  // 本番環境かどうかを判定
  static bool get isProd => _currentEnvironment == prod;
  
  // デバッグ情報を出力
  static void printEnvironmentInfo() {
    print('=== 環境設定情報 ===');
    print('現在の環境: $_currentEnvironment');
    print('ベースURL: ${baseUrl}');
    print('==================');
  }
}
```

### lib/models/

#### health_record.dart
健康データのモデルクラスを定義しています。カロリー、体重、睡眠、運動の各記録に対応するクラスがあります。

```dart
// カロリー記録モデル
class CalorieRecord {
  final int? id;
  final DateTime date;
  final double calories;
  final String? description;

  // コンストラクタとJSONシリアライズ/デシリアライズメソッド
}

// 体重記録モデル
class WeightRecord {
  final int? id;
  final DateTime date;
  final double weight;
  final String? notes;

  // コンストラクタとJSONシリアライズ/デシリアライズメソッド
}

// 睡眠記録モデル
class SleepRecord {
  final int? id;
  final DateTime date;
  final double hours;
  final String? quality;
  final String? notes;

  // コンストラクタとJSONシリアライズ/デシリアライズメソッド
}

// 運動記録モデル
class ExerciseRecord {
  final int? id;
  final DateTime date;
  final String exerciseType;
  final double duration;
  final double? calories;
  final String? notes;

  // コンストラクタとJSONシリアライズ/デシリアライズメソッド
}
```

### lib/providers/

#### auth_provider.dart
認証状態を管理するプロバイダークラスです。ログイン、ユーザー登録、ログアウト機能を提供します。

```dart
class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  // ゲッター
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;

  // APIサービス
  final ApiService _apiService = ApiService();

  // 初期化時に保存された認証状態を読み込む
  AuthProvider() {
    _loadAuthState();
  }

  // 認証状態の読み込み
  Future<void> _loadAuthState() async { /* ... */ }

  // ユーザー情報の読み込み
  Future<void> _loadUserInfo() async { /* ... */ }

  // ログイン処理
  Future<bool> login(String email, String password) async { /* ... */ }

  // ユーザー登録処理
  Future<bool> register(String email, String password, String name) async { /* ... */ }

  // ログアウト処理
  Future<void> logout() async { /* ... */ }
}
```

#### health_data_provider.dart
健康データを管理するプロバイダークラスです。各種健康データの取得と追加機能を提供します。

```dart
class HealthDataProvider with ChangeNotifier {
  List<CalorieRecord> _calorieRecords = [];
  List<WeightRecord> _weightRecords = [];
  List<SleepRecord> _sleepRecords = [];
  List<ExerciseRecord> _exerciseRecords = [];
  bool _isLoading = false;

  // ゲッター
  List<CalorieRecord> get calorieRecords => _calorieRecords;
  List<WeightRecord> get weightRecords => _weightRecords;
  List<SleepRecord> get sleepRecords => _sleepRecords;
  List<ExerciseRecord> get exerciseRecords => _exerciseRecords;
  bool get isLoading => _isLoading;

  // APIサービス
  final ApiService _apiService = ApiService();

  // 健康データの読み込み
  Future<void> loadHealthData(String token) async { /* ... */ }

  // カロリー記録の追加
  Future<void> addCalorieRecord(String token, CalorieRecord record) async { /* ... */ }

  // 体重記録の追加
  Future<void> addWeightRecord(String token, WeightRecord record) async { /* ... */ }

  // 睡眠記録の追加
  Future<void> addSleepRecord(String token, SleepRecord record) async { /* ... */ }

  // 運動記録の追加
  Future<void> addExerciseRecord(String token, ExerciseRecord record) async { /* ... */ }
}
```

### lib/services/

#### api_service.dart
バックエンドAPIとの通信を担当するサービスクラスです。認証関連のAPI呼び出しと健康データ関連のAPI呼び出しを提供します。

```dart
class ApiService {
  // バックエンドサーバーのベースURL（環境設定から取得）
  static String get baseUrl => Environment.baseUrl;

  // 認証関連
  Future<Map<String, dynamic>> login(String email, String password) async { /* ... */ }
  Future<bool> register(String email, String password) async { /* ... */ }
  Future<Map<String, dynamic>> getUserProfile(String token) async { /* ... */ }

  // カロリー記録関連
  Future<List<dynamic>> getCalorieRecords(String token) async { /* ... */ }
  Future<Map<String, dynamic>> addCalorieRecord(String token, Map<String, dynamic> data) async { /* ... */ }

  // 体重記録関連
  Future<List<dynamic>> getWeightRecords(String token) async { /* ... */ }
  Future<Map<String, dynamic>> addWeightRecord(String token, Map<String, dynamic> data) async { /* ... */ }

  // 睡眠記録関連
  Future<List<dynamic>> getSleepRecords(String token) async { /* ... */ }
  Future<Map<String, dynamic>> addSleepRecord(String token, Map<String, dynamic> data) async { /* ... */ }

  // 運動記録関連
  Future<List<dynamic>> getExerciseRecords(String token) async { /* ... */ }
  Future<Map<String, dynamic>> addExerciseRecord(String token, Map<String, dynamic> data) async { /* ... */ }
}
```

### lib/screens/

#### login_screen.dart
ログイン画面を実装しています。メールアドレスとパスワードによるログイン機能と、新規登録画面への遷移機能を提供します。

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // フォーム関連の変数
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ログイン処理
  Future<void> _login() async { /* ... */ }

  // UI構築
  @override
  Widget build(BuildContext context) { /* ... */ }
}
```

#### register_screen.dart
新規登録画面を実装しています。名前、メールアドレス、パスワードによるユーザー登録機能を提供します。

```dart
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // フォーム関連の変数
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 登録処理
  Future<void> _register() async { /* ... */ }

  // UI構築
  @override
  Widget build(BuildContext context) { /* ... */ }
}
```

#### home_screen.dart
ホーム画面を実装しています。ボトムナビゲーションバーによる4つのタブ（ダッシュボード、記録、統計、プロフィール）を提供します。

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  // 健康データの読み込み
  Future<void> _loadHealthData() async { /* ... */ }

  // タブ切り替え
  void _onItemTapped(int index) { /* ... */ }

  // UI構築
  @override
  Widget build(BuildContext context) { /* ... */ }
}

// ダッシュボードタブ
class DashboardTab extends StatefulWidget { /* ... */ }

// 記録タブ（プレースホルダー）
class RecordsTab extends StatelessWidget { /* ... */ }

// 統計タブ（プレースホルダー）
class StatisticsTab extends StatelessWidget { /* ... */ }

// プロフィールタブ（プレースホルダー）
class ProfileTab extends StatelessWidget { /* ... */ }
```

### lib/widgets/

#### weekly_calendar.dart
週間カレンダーを表示するウィジェットです。現在の週の日付を表示し、日付の選択機能を提供します。

```dart
class WeeklyCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime? initialSelectedDate;

  const WeeklyCalendar({
    Key? key,
    required this.onDateSelected,
    this.initialSelectedDate,
  }) : super(key: key);

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  late DateTime _currentDate;
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  
  // 初期化
  @override
  void initState() { /* ... */ }

  // 週の日付を生成
  void _generateWeekDays() { /* ... */ }

  // 日付選択
  void _selectDate(DateTime date) { /* ... */ }

  // 前の週に移動
  void _previousWeek() { /* ... */ }

  // 次の週に移動
  void _nextWeek() { /* ... */ }

  // 月と年を取得
  String _getMonthYear() { /* ... */ }

  // UI構築
  @override
  Widget build(BuildContext context) { /* ... */ }
}
```

#### daily_health_data.dart
選択された日付の健康データを表示するウィジェットです。カロリー、体重、睡眠、運動のデータを表示します。

```dart
class DailyHealthData extends StatelessWidget {
  final DateTime selectedDate;

  const DailyHealthData({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  // UI構築
  @override
  Widget build(BuildContext context) { /* ... */ }

  // データカードの構築
  Widget _buildDataCard({ /* ... */ }) { /* ... */ }

  // 選択された日付のカロリーデータを取得
  CalorieRecord? _getCalorieDataForDate(List<CalorieRecord> records, DateTime date) { /* ... */ }

  // 選択された日付の体重データを取得
  WeightRecord? _getWeightDataForDate(List<WeightRecord> records, DateTime date) { /* ... */ }

  // 選択された日付の睡眠データを取得
  SleepRecord? _getSleepDataForDate(List<SleepRecord> records, DateTime date) { /* ... */ }

  // 選択された日付の運動データを取得
  ExerciseRecord? _getExerciseDataForDate(List<ExerciseRecord> records, DateTime date) { /* ... */ }
}
```

### lib/main.dart
アプリケーションのエントリーポイントです。環境設定の初期化とアプリケーションの起動を行います。

```dart
void main() {
  // 環境設定の初期化
  // コマンドライン引数から環境を取得（デフォルトは開発環境）
  final env = const String.fromEnvironment('ENV', defaultValue: 'dev');
  
  // 環境に応じて適切な設定を行う
  switch (env) {
    case 'prod':
      Environment.setEnvironment(Environment.prod);
      break;
    case 'web':
      Environment.setEnvironment(Environment.web);
      break;
    default:
      Environment.setEnvironment(Environment.dev);
  }
  
  // 環境情報をデバッグ出力
  Environment.printEnvironmentInfo();
  
  runApp(const HealthApp());
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HealthDataProvider()),
      ],
      child: MaterialApp(
        title: '健康管理アプリ',
        theme: ThemeData(/* ... */),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isAuthenticated) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

## 環境設定

このアプリケーションは、エミュレータ開発環境、Web開発環境、本番環境の3つの環境設定を持っています。

### エミュレータ開発環境

- **APIエンドポイント**: `http://10.0.2.2:8000/api`
- **用途**: Androidエミュレータからホストマシンへのアクセス（エミュレータでの開発・テスト用）
- **起動方法**: `run_dev.bat` または `flutter run -d emulator-5554 --dart-define=ENV=dev`

### Web開発環境

- **APIエンドポイント**: `http://localhost:8000/api`
- **用途**: ブラウザからのアクセス（Web開発・テスト用）
- **起動方法**: `run_web.bat` または `flutter run -d chrome --web-port=8080 --dart-define=ENV=web`

### 本番環境

- **APIエンドポイント**: `https://backend-server-fukawa.onrender.com/api`
- **用途**: 実際の本番サーバーへのアクセス（本番疎通テスト・実機テスト用）
- **起動方法**: `run_prod.bat` または `flutter run --dart-define=ENV=prod`
- **ビルド方法**: `build_prod.bat` または `flutter build apk --dart-define=ENV=prod --release`

## 実行方法

### エミュレータ開発環境での実行

```bash
# Windowsの場合
run_dev.bat

# macOS/Linuxの場合
./run_dev.sh
```

### Web開発環境での実行

```bash
# Windowsの場合
run_web.bat

# macOS/Linuxの場合
./run_web.sh
```

### 本番環境での実行

```bash
# Windowsの場合
run_prod.bat

# macOS/Linuxの場合
./run_prod.sh
```

### 本番環境用APKのビルド

```bash
# Windowsの場合
build_prod.bat

# macOS/Linuxの場合
./build_prod.sh
```

## 開発フロー

1. **環境構築**
   - Flutter SDKのインストール
   - 依存関係のインストール: `flutter pub get`

2. **開発**
   - 開発環境での実行: `run_dev.bat` または `./run_dev.sh`
   - コード修正とテスト

3. **テスト**
   - 単体テスト: `flutter test`
   - ウィジェットテスト: `flutter test test/widget_test.dart`

4. **ビルドとデプロイ**
   - 本番環境用APKのビルド: `build_prod.bat` または `./build_prod.sh`
   - APKファイルの配布
