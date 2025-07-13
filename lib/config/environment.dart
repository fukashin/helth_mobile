/// 環境設定クラス
///
/// 起動コマンドに応じてバックエンドの接続先を切り替えます。
/// `--dart-define=ENV=prod` または `--dart-define=ENV=dev` のフラグに基づいて
/// 開発環境または本番環境のAPIエンドポイントを設定します。
class Environment {
  /// 環境タイプの定義
  /// 
  /// 開発環境を表す定数（エミュレータ用）
  static const String dev = 'dev';
  
  /// 本番環境を表す定数
  static const String prod = 'prod';
  
  /// Web開発環境を表す定数（ブラウザからのアクセス用）
  static const String web = 'web';
  
  /// 現在の環境（デフォルトは開発環境）
  static String _currentEnvironment = dev;
  
  /// 環境別のベースURL設定
  /// 
  /// 各環境に対応するAPIのベースURLを定義します。
  static const Map<String, String> _baseUrls = {
    dev: 'http://10.0.2.2:8000/api',  // エミュレータ用（Androidエミュレータからホストマシンへのアクセス）
    web: 'http://localhost:8000/api',  // Web開発環境用（ブラウザからのアクセス）
    prod: 'https://backend-server-fukawa.onrender.com/api',  // 本番環境
  };
  
  /// 現在の環境を設定するメソッド
  /// 
  /// [environment] 設定する環境（'dev'または'prod'）
  /// 
  /// 無効な環境が指定された場合は例外をスローします。
  static void setEnvironment(String environment) {
    if (_baseUrls.containsKey(environment)) {
      _currentEnvironment = environment;
    } else {
      throw ArgumentError('無効な環境が指定されました: $environment');
    }
  }
  
  /// 現在の環境を取得するゲッター
  static String get currentEnvironment => _currentEnvironment;
  
  /// 現在の環境のベースURLを取得するゲッター
  /// 
  /// APIリクエストの際に使用するベースURLを返します。
  static String get baseUrl => _baseUrls[_currentEnvironment]!;
  
  /// 開発環境かどうかを判定するゲッター
  static bool get isDev => _currentEnvironment == dev;
  
  /// 本番環境かどうかを判定するゲッター
  static bool get isProd => _currentEnvironment == prod;
  
  /// デバッグ情報を出力するメソッド
  /// 
  /// 現在の環境設定情報をコンソールに出力します。
  static void printEnvironmentInfo() {
    print('=== 環境設定情報 ===');
    print('現在の環境: $_currentEnvironment');
    print('ベースURL: ${baseUrl}');
    print('==================');
  }
}
