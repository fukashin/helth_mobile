import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/google_sign_in_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  /// また、Google Sign-Inのサイレントサインインも試行します。
  Future<void> _loadAuthState() async {
    try {
      _debugLog('認証状態読み込み開始');
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      _userId = prefs.getInt('user_id');
      final String? authProvider = prefs.getString('auth_provider');

      if (_token != null) {
        _isAuthenticated = true;
        _debugLog('保存されたトークンを発見', details: 'プロバイダー: $authProvider');

        // 認証プロバイダーに応じて処理を分岐
        if (authProvider == 'google') {
          // Google Sign-Inの場合はサイレントサインインを試行
          try {
            final success = await signInWithGoogleSilently();
            if (!success) {
              _debugLog('Google サイレントサインイン失敗', details: '保存されたトークンを使用');
              // サイレントサインインに失敗した場合は保存されたトークンを使用
              _isAuthenticated = true;
            }
          } catch (e) {
            _debugLog('Google サイレントサインインエラー', error: e.toString());
            _isAuthenticated = true;
          }
        } else {
          // 通常のログインの場合はAPIからユーザー情報を取得
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
        }
      } else {
        // 保存されたトークンがない場合もGoogle Sign-Inのサイレントサインインを試行
        _debugLog('保存されたトークンなし', details: 'Google サイレントサインインを試行');
        try {
          final success = await signInWithGoogleSilently();
          if (!success) {
            _debugLog('Google サイレントサインイン失敗', details: '未認証状態で開始');
          }
        } catch (e) {
          _debugLog('Google サイレントサインインエラー', error: e.toString());
        }
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
      await prefs.setString('auth_provider', 'email');
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
        await prefs.setString('auth_provider', 'email');
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
  /// Googleアカウントを使用してサインインします。
  /// 成功時はtrueを、失敗時はfalseを返します。
  Future<bool> signInWithGoogle() async {
    _debugLog('Google Sign-In開始');
    _isLoading = true;
    notifyListeners();

    try {
      // Google Sign-Inを実行
      final GoogleSignInAccount? googleUser =
          await GoogleSignInService.signIn();

      if (googleUser == null) {
        _debugLog('Google Sign-In キャンセル', details: 'ユーザーがサインインをキャンセルしました');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // IDトークンを取得
      final String? idToken = await GoogleSignInService.getIdToken();

      if (idToken == null) {
        _debugLog('Google IDトークン取得失敗');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // ここでサーバーにIDトークンを送信して認証を行う
      // 現在はテスト実装として、Googleアカウント情報を直接使用
      _token = idToken; // 実際の実装では、サーバーから取得したトークンを使用
      _user = {
        'id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? 'Unknown',
        'photoUrl': googleUser.photoUrl,
        'provider': 'google',
      };
      _userId = googleUser.id.hashCode; // 実際の実装では、サーバーから取得したユーザーIDを使用
      _isAuthenticated = true;

      // トークンとユーザーIDを保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setInt('user_id', _userId!);
      await prefs.setString('auth_provider', 'google');

      _isLoading = false;
      notifyListeners();
      _debugLog('Google Sign-In成功', details: 'ユーザー: ${googleUser.email}');
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _debugLog('Google Sign-Inエラー', error: e.toString());
      return false;
    }
  }

  /// サイレントGoogle Sign-Inを試行するメソッド
  ///
  /// 以前にGoogleでサインインしたことがある場合、
  /// ユーザーの操作なしで自動的にサインインを試行します。
  Future<bool> signInWithGoogleSilently() async {
    _debugLog('Google サイレントサインイン開始');

    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignInService.signInSilently();

      if (googleUser == null) {
        _debugLog('Google サイレントサインイン失敗', details: '以前のサインイン情報なし');
        return false;
      }

      // IDトークンを取得
      final String? idToken = await GoogleSignInService.getIdToken();

      if (idToken == null) {
        _debugLog('Google IDトークン取得失敗（サイレント）');
        return false;
      }

      // 認証状態を設定
      _token = idToken;
      _user = {
        'id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? 'Unknown',
        'photoUrl': googleUser.photoUrl,
        'provider': 'google',
      };
      _userId = googleUser.id.hashCode;
      _isAuthenticated = true;

      // トークンとユーザーIDを保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setInt('user_id', _userId!);
      await prefs.setString('auth_provider', 'google');

      notifyListeners();
      _debugLog('Google サイレントサインイン成功', details: 'ユーザー: ${googleUser.email}');
      return true;
    } catch (e) {
      _debugLog('Google サイレントサインインエラー', error: e.toString());
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
      // 保存された認証プロバイダーを確認
      final prefs = await SharedPreferences.getInstance();
      final String? authProvider = prefs.getString('auth_provider');

      // Google Sign-Inの場合はGoogleからもサインアウト
      if (authProvider == 'google') {
        await GoogleSignInService.signOut();
        _debugLog('Google Sign-Outも実行');
      }

      _isAuthenticated = false;
      _token = null;
      _user = null;
      _userId = null;

      // 保存されたトークンとユーザーIDを削除
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('auth_provider');

      notifyListeners();
      _debugLog('ログアウト完了', details: 'トークン、ユーザー情報、ユーザーIDを削除しました');
    } catch (e) {
      _debugLog('ログアウトエラー', error: e.toString());
      notifyListeners();
    }
  }

  /// 現在の認証プロバイダーを取得
  ///
  /// 'email' または 'google' を返します。
  Future<String?> getAuthProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_provider');
  }

  /// Google Sign-Inでサインインしているかどうかを確認
  bool get isGoogleSignedIn => GoogleSignInService.isSignedIn;
}
