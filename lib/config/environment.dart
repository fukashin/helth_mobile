// 環境設定クラス
// 起動コマンドに応じてバックエンドの接続先を切り替える
class Environment {
  // 環境タイプの定義
  static const String dev = 'dev';
  static const String prod = 'prod';
  
  // 現在の環境（デフォルトは開発環境）
  static String _currentEnvironment = dev;
  
  // 環境別のベースURL設定
  static const Map<String, String> _baseUrls = {
    dev: 'http://10.0.2.2:8000/api',  // エミュレータ用（Androidエミュレータからホストマシンへのアクセス）
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
