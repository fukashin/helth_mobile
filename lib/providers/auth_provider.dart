import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';

/// 認証状態管理プロバイダー
///
/// ユーザーの認証状態（ログイン状態、トークン、ユーザー情報）を管理します。
/// ログイン、ユーザー登録、ログアウト機能を提供し、認証状態の永続化も行います。
class AuthProvider with ChangeNotifier {
  /// ユーザーが認証されているかどうか
  bool _isAuthenticated = false;

  /// 認証トークン
  String? _token;

  /// ユーザー情報
  Map<String, dynamic>? _user;

  /// ユーザーID
  int? _userId;

  /// 処理中かどうか（ログイン中、登録中など）
  bool _isLoading = false;

  /// 初期化が完了したかどうか
  bool _isInitialized = false;

  /// ユーザーが認証されているかどうかを取得
  bool get isAuthenticated => _isAuthenticated;

  /// 認証トークンを取得
  String? get token => _token;

  /// ユーザー情報を取得
  Map<String, dynamic>? get user => _user;

  /// ユーザーIDを取得
  int? get userId => _userId;

  /// 処理中かどうかを取得
  bool get isLoading => _isLoading;

  /// 初期化が完了したかどうかを取得
  bool get isInitialized => _isInitialized;

  /// APIサービスのインスタンス
  final ApiService _apiService = ApiService();

  /// Google認証サービスのインスタンス
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  /// デバッグ用のログ出力メソッド
  ///
  /// [action] 実行中のアクション名
  /// [details] 詳細情報（任意）
  /// [error] エラー情報（任意）
  void _debugLog(String action, {String? details, String? error}) {
    print('=== AuthProvider Debug Log ===');
    print('アクション: $action');
    print('認証状態: $_isAuthenticated');
    print('トークン有無: ${_token != null ? "あり" : "なし"}');
    print('ユーザー情報: ${_user != null ? _user!['email'] ?? "不明" : "なし"}');
    print('ローディング状態: $_isLoading');
    if (details != null) {
      print('詳細: $details');
    }
    if (error != null) {
      print('エラー: $error');
    }
    print('=============================');
  }

  /// コンストラクタ
  ///
  /// 初期化時に保存された認証状態を読み込みます。
  AuthProvider() {
    print('AuthProvider初期化開始');
    _loadAuthState();
  }

  /// 保存された認証状態を読み込むメソッド
  ///
  /// SharedPreferencesから認証トークンを読み込み、
  /// トークンが存在する場合はユーザー情報も取得します。
  Future<void> _loadAuthState() async {
    try {
      _debugLog('認証状態読み込み開始');
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      _userId = prefs.getInt('user_id');
      if (_token != null) {
        _isAuthenticated = true;
        _debugLog('保存されたトークンを発見', details: 'ユーザー情報を取得します');
        // ユーザー情報を取得
        try {
          await _loadUserInfo();
        } catch (e) {
          _debugLog(
            'ユーザー情報取得エラー',
            error: e.toString(),
            details: 'トークンは保持したまま続行します',
          );
          // ユーザー情報取得に失敗しても、トークンがあれば認証状態を維持
          _isAuthenticated = true;
        }
      } else {
        _debugLog('保存されたトークンなし', details: '未認証状態で開始');
      }
      // 初期化完了フラグをセット
      _isInitialized = true;
      notifyListeners();
      _debugLog('認証状態読み込み完了');
    } catch (e) {
      _debugLog('認証状態読み込みエラー', error: e.toString());
      // エラーが発生しても初期化完了フラグをセット
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// ユーザー情報を取得するメソッド
  ///
  /// 認証トークンを使用してAPIからユーザー情報を取得します。
  /// トークンが無効な場合はログアウトします。
  Future<void> _loadUserInfo() async {
    try {
      _debugLog('ユーザー情報取得開始');
      final userInfo = await _apiService.getUserProfile(_token!);
      _user = userInfo;

      // ユーザーIDを取得して保存
      if (_user != null && _user!['id'] != null) {
        _userId = _user!['id'];
        // ユーザーIDをローカルストレージに保存
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', _userId!);
        _debugLog('ユーザーID取得成功', details: 'ユーザーID: $_userId');
      }

      _debugLog('ユーザー情報取得成功', details: 'ユーザー: ${_user!['email'] ?? "不明"}');
    } catch (e) {
      _debugLog('ユーザー情報取得失敗', error: e.toString(), details: 'APIリクエストに失敗しました');
      // Webモードでのリロード時はエラーを上位に伝播させる
      throw e;
    }
  }

  /// ログイン処理を行うメソッド
  ///
  /// [email] ユーザーのメールアドレス
  /// [password] ユーザーのパスワード
  ///
  /// ログイン成功時はtrueを、失敗時はfalseを返します。
  Future<bool> login(String email, String password) async {
    _debugLog('ログイン開始', details: 'ユーザー: $email');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      _token = response['access_token'];
      _user = response['user'];
      _isAuthenticated = true;

      // ユーザーIDを取得
      if (_user != null && _user!['id'] != null) {
        _userId = _user!['id'];
      }

      // トークンとユーザーIDを保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      if (_userId != null) {
        await prefs.setInt('user_id', _userId!);
        _debugLog('ユーザーID保存', details: 'ユーザーID: $_userId');
      }

      _isLoading = false;
      notifyListeners();
      _debugLog('ログイン成功', details: 'ユーザー: $email, トークンを保存しました');
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _debugLog('ログイン失敗', error: e.toString(), details: 'ユーザー: $email');
      return false;
    }
  }

  /// ユーザー登録処理を行うメソッド
  ///
  /// [email] ユーザーのメールアドレス
  /// [password] ユーザーのパスワード
  /// [name] ユーザーの名前
  ///
  /// 登録成功時はtrueを、失敗時はfalseを返します。
  /// 登録成功時は自動的にログインも行います。
  Future<bool> register(String email, String password, String name) async {
    _debugLog('ユーザー登録開始', details: 'ユーザー: $email, 名前: $name');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register(email, password, name: name);

      if (response != false) {
        _debugLog('ユーザー登録成功', details: 'ユーザー: $email, トークンを取得しました');

        // レスポンスからトークンとユーザー情報を取得
        _token = response['access_token'];
        _user = response['user'];
        _isAuthenticated = true;

        // ユーザーIDを取得
        if (_user != null && _user!['id'] != null) {
          _userId = _user!['id'];
        }

        // トークンとユーザーIDを保存
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        if (_userId != null) {
          await prefs.setInt('user_id', _userId!);
          _debugLog('ユーザーID保存', details: 'ユーザーID: $_userId');
        }

        _isLoading = false;
        notifyListeners();
        _debugLog('ユーザー登録・ログイン完了', details: 'ユーザー: $email, トークンを保存しました');
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        _debugLog('ユーザー登録失敗', details: 'ユーザー: $email, APIから失敗レスポンス');
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _debugLog('ユーザー登録エラー', error: e.toString(), details: 'ユーザー: $email');
      return false;
    }
  }

  /// Google Sign-Inでログイン処理を行うメソッド
  ///
  /// Google認証を使用してログインを行います。
  /// 成功時はtrueを、失敗時はfalseを返します。
  Future<bool> signInWithGoogle() async {
    _debugLog('Google Sign-Inログイン開始');
    _isLoading = true;
    notifyListeners();

    try {
      // Googleサインインを実行
      final GoogleSignInAccount? googleUser = await _googleAuthService
          .signInWithGoogle();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        _debugLog('Google Sign-Inキャンセル', details: 'ユーザーがサインインをキャンセルしました');
        return false;
      }

      // Googleユーザー情報を取得
      final googleUserInfo = _googleAuthService.getUserInfo(googleUser);

      // IDトークンを取得
      final String? idToken = await _googleAuthService.getIdToken(googleUser);

      if (idToken == null) {
        _isLoading = false;
        notifyListeners();
        _debugLog('Google IDトークン取得失敗');
        return false;
      }

      // バックエンドでGoogle認証を処理（今回はテスト実装のため、ローカルで認証状態を設定）
      // 実際の実装では、IDトークンをバックエンドに送信して検証し、JWTトークンを取得する
      _token = 'google_sso_token_${googleUser.id}'; // テスト用のトークン
      _user = {
        'id': googleUser.id.hashCode, // テスト用のユーザーID
        'email': googleUser.email,
        'name': googleUser.displayName ?? googleUser.email,
        'auth_type': 'google_sso',
      };
      _userId = googleUser.id.hashCode;
      _isAuthenticated = true;

      // トークンとユーザーIDを保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setInt('user_id', _userId!);
      await prefs.setString('auth_type', 'google_sso');

      _isLoading = false;
      notifyListeners();
      _debugLog('Google Sign-Inログイン成功', details: 'ユーザー: ${googleUser.email}');
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _debugLog('Google Sign-Inログインエラー', error: e.toString());
      return false;
    }
  }

  /// ログアウト処理を行うメソッド
  ///
  /// 認証状態をクリアし、保存されたトークンを削除します。
  /// Google Sign-Inの場合はGoogleからもサインアウトします。
  Future<void> logout() async {
    _debugLog('ログアウト開始');
    try {
      // Google Sign-Inからサインアウト
      await _googleAuthService.signOut();

      _isAuthenticated = false;
      _token = null;
      _user = null;
      _userId = null;

      // 保存されたトークンとユーザーIDを削除
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('auth_type');

      notifyListeners();
      _debugLog('ログアウト完了', details: 'トークン、ユーザー情報、ユーザーIDを削除しました');
    } catch (e) {
      _debugLog('ログアウトエラー', error: e.toString());
      notifyListeners();
    }
  }
}
