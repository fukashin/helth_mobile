import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/health_data_provider.dart';
import 'config/environment.dart';

/// 健康管理アプリケーション
///
/// このアプリケーションは、ユーザーが健康データ（カロリー、体重、睡眠、運動）を
/// 記録・管理するためのモバイルアプリケーションです。

/// アプリケーションのエントリーポイント
///
/// 環境設定の初期化とアプリケーションの起動を行います。
/// 起動時のコマンドライン引数 `--dart-define=ENV=prod`、`--dart-define=ENV=web`、または `--dart-define=ENV=dev` に基づいて
/// 環境（本番環境、Web開発環境、またはエミュレータ開発環境）を設定します。
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

/// アプリケーションのルートウィジェット
///
/// アプリケーション全体の設定（テーマ、プロバイダー、ルーティングなど）を行います。
class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  /// ウィジェットの構築
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 状態管理のためのプロバイダーを設定
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),      // 認証状態の管理
        ChangeNotifierProvider(create: (_) => HealthDataProvider()), // 健康データの管理
      ],
      child: MaterialApp(
        title: '健康管理アプリ',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'NotoSansJP',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        // 認証状態に基づいて表示する画面を切り替え
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isAuthenticated) {
              return const HomeScreen(); // 認証済みの場合はホーム画面
            } else {
              return const LoginScreen(); // 未認証の場合はログイン画面
            }
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
