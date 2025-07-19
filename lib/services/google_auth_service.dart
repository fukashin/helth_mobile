import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Google認証サービスクラス
///
/// Google Sign-Inを使用したSSO認証機能を提供します。
/// Googleアカウントでのサインイン、サインアウト、認証状態の管理を行います。
class GoogleAuthService {
  /// Google Sign-Inのインスタンス
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// デバッグ用のログ出力メソッド
  ///
  /// [action] 実行中のアクション名
  /// [details] 詳細情報（任意）
  /// [error] エラー情報（任意）
  void _debugLog(String action, {String? details, String? error}) {
    print('=== GoogleAuthService Debug Log ===');
    print('アクション: $action');
    if (details != null) {
      print('詳細: $details');
    }
    if (error != null) {
      print('エラー: $error');
    }
    print('==================================');
  }

  /// Googleアカウントでサインインを行うメソッド
  ///
  /// 成功時はGoogleSignInAccountを返します。
  /// 失敗時はnullを返します。
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      _debugLog('Googleサインイン開始');

      // 既存のサインイン状態をクリア
      await _googleSignIn.signOut();

      // Googleサインインを実行
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        _debugLog('Googleサインイン成功', details: 'ユーザー: ${account.email}');
        return account;
      } else {
        _debugLog('Googleサインインキャンセル', details: 'ユーザーがサインインをキャンセルしました');
        return null;
      }
    } catch (error) {
      _debugLog('Googleサインインエラー', error: error.toString());
      return null;
    }
  }

  /// Googleアカウントからサインアウトを行うメソッド
  ///
  /// 成功時はtrueを返します。
  /// 失敗時はfalseを返します。
  Future<bool> signOut() async {
    try {
      _debugLog('Googleサインアウト開始');

      await _googleSignIn.signOut();

      _debugLog('Googleサインアウト成功');
      return true;
    } catch (error) {
      _debugLog('Googleサインアウトエラー', error: error.toString());
      return false;
    }
  }

  /// 現在のGoogleサインイン状態を取得するメソッド
  ///
  /// サインイン済みの場合はGoogleSignInAccountを返します。
  /// サインインしていない場合はnullを返します。
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      _debugLog('現在のGoogleユーザー取得開始');

      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account != null) {
        _debugLog('現在のGoogleユーザー取得成功', details: 'ユーザー: ${account.email}');
      } else {
        _debugLog('現在のGoogleユーザーなし');
      }

      return account;
    } catch (error) {
      _debugLog('現在のGoogleユーザー取得エラー', error: error.toString());
      return null;
    }
  }

  /// GoogleアカウントのIDトークンを取得するメソッド
  ///
  /// [account] GoogleSignInAccount
  ///
  /// 成功時はIDトークンを返します。
  /// 失敗時はnullを返します。
  Future<String?> getIdToken(GoogleSignInAccount account) async {
    try {
      _debugLog('GoogleIDトークン取得開始', details: 'ユーザー: ${account.email}');

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken != null) {
        _debugLog('GoogleIDトークン取得成功');
        return idToken;
      } else {
        _debugLog('GoogleIDトークン取得失敗', details: 'IDトークンがnullです');
        return null;
      }
    } catch (error) {
      _debugLog('GoogleIDトークン取得エラー', error: error.toString());
      return null;
    }
  }

  /// Googleアカウントのアクセストークンを取得するメソッド
  ///
  /// [account] GoogleSignInAccount
  ///
  /// 成功時はアクセストークンを返します。
  /// 失敗時はnullを返します。
  Future<String?> getAccessToken(GoogleSignInAccount account) async {
    try {
      _debugLog('Googleアクセストークン取得開始', details: 'ユーザー: ${account.email}');

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? accessToken = auth.accessToken;

      if (accessToken != null) {
        _debugLog('Googleアクセストークン取得成功');
        return accessToken;
      } else {
        _debugLog('Googleアクセストークン取得失敗', details: 'アクセストークンがnullです');
        return null;
      }
    } catch (error) {
      _debugLog('Googleアクセストークン取得エラー', error: error.toString());
      return null;
    }
  }

  /// Googleアカウントの基本情報を取得するメソッド
  ///
  /// [account] GoogleSignInAccount
  ///
  /// ユーザーの基本情報を含むMapを返します。
  Map<String, dynamic> getUserInfo(GoogleSignInAccount account) {
    _debugLog('Googleユーザー情報取得', details: 'ユーザー: ${account.email}');

    return {
      'id': account.id,
      'email': account.email,
      'displayName': account.displayName,
      'photoUrl': account.photoUrl,
    };
  }
}
