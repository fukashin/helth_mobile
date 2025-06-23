import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  // デバッグ用のログ出力メソッド
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

  AuthProvider() {
    print('AuthProvider初期化開始');
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    try {
      _debugLog('認証状態読み込み開始');
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      if (_token != null) {
        _isAuthenticated = true;
        _debugLog('保存されたトークンを発見', details: 'ユーザー情報を取得します');
        // ユーザー情報を取得
        await _loadUserInfo();
      } else {
        _debugLog('保存されたトークンなし', details: '未認証状態で開始');
      }
      notifyListeners();
      _debugLog('認証状態読み込み完了');
    } catch (e) {
      _debugLog('認証状態読み込みエラー', error: e.toString());
      notifyListeners();
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      _debugLog('ユーザー情報取得開始');
      final userInfo = await _apiService.getUserProfile(_token!);
      _user = userInfo;
      _debugLog('ユーザー情報取得成功', details: 'ユーザー: ${_user!['email'] ?? "不明"}');
    } catch (e) {
      _debugLog('ユーザー情報取得失敗', error: e.toString(), details: 'トークンが無効な可能性があります。ログアウトします。');
      // トークンが無効な場合はログアウト
      await logout();
    }
  }

  Future<bool> login(String email, String password) async {
    _debugLog('ログイン開始', details: 'ユーザー: $email');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      _token = response['access_token'];
      _user = response['user'];
      _isAuthenticated = true;

      // トークンを保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

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

  Future<bool> register(String email, String password, String name) async {
    _debugLog('ユーザー登録開始', details: 'ユーザー: $email, 名前: $name');
    _isLoading = true;
    notifyListeners();

    try {
      final bool isSuccess = await _apiService.register(email, password);

      if (isSuccess) {
        _debugLog('ユーザー登録成功', details: 'ユーザー: $email, 自動ログインを実行します');
        // 登録に成功したら、そのままログインする
        return await login(email, password);
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

  Future<void> logout() async {
    _debugLog('ログアウト開始');
    try {
      _isAuthenticated = false;
      _token = null;
      _user = null;

      // 保存されたトークンを削除
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      notifyListeners();
      _debugLog('ログアウト完了', details: 'トークンとユーザー情報を削除しました');
    } catch (e) {
      _debugLog('ログアウトエラー', error: e.toString());
      notifyListeners();
    }
  }
}
