import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Google Sign-Inサービス
///
/// Googleアカウントを使用したSSO認証機能を提供します。
/// サインイン、サインアウト、現在のユーザー情報取得などの機能があります。
class GoogleSignInService {
  /// Google Sign-Inのインスタンス
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // 必要に応じてスコープを追加
    scopes: ['email', 'profile'],
  );

  /// 現在のGoogleアカウントユーザーを取得
  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Googleアカウントでサインインを実行
  ///
  /// 成功時は[GoogleSignInAccount]を返し、失敗時はnullを返します。
  /// キャンセルされた場合もnullを返します。
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      debugPrint('Google Sign-In開始');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        debugPrint('Google Sign-In成功: ${account.email}');
        return account;
      } else {
        debugPrint('Google Sign-Inがキャンセルされました');
        return null;
      }
    } catch (error) {
      debugPrint('Google Sign-Inエラー: $error');
      return null;
    }
  }

  /// Googleアカウントからサインアウト
  ///
  /// ローカルの認証状態をクリアします。
  static Future<void> signOut() async {
    try {
      debugPrint('Google Sign-Out開始');
      await _googleSignIn.signOut();
      debugPrint('Google Sign-Out完了');
    } catch (error) {
      debugPrint('Google Sign-Outエラー: $error');
    }
  }

  /// Googleアカウントとの接続を完全に切断
  ///
  /// アプリとGoogleアカウントの連携を完全に解除します。
  static Future<void> disconnect() async {
    try {
      debugPrint('Google接続切断開始');
      await _googleSignIn.disconnect();
      debugPrint('Google接続切断完了');
    } catch (error) {
      debugPrint('Google接続切断エラー: $error');
    }
  }

  /// 現在のユーザーのIDトークンを取得
  ///
  /// サーバー側での認証に使用するIDトークンを取得します。
  /// ユーザーがサインインしていない場合はnullを返します。
  static Future<String?> getIdToken() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) {
        debugPrint('Google Sign-In: ユーザーがサインインしていません');
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      debugPrint('Google IDトークン取得成功');
      return auth.idToken;
    } catch (error) {
      debugPrint('Google IDトークン取得エラー: $error');
      return null;
    }
  }

  /// 現在のユーザーのアクセストークンを取得
  ///
  /// Google APIへのアクセスに使用するアクセストークンを取得します。
  /// ユーザーがサインインしていない場合はnullを返します。
  static Future<String?> getAccessToken() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) {
        debugPrint('Google Sign-In: ユーザーがサインインしていません');
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      debugPrint('Google アクセストークン取得成功');
      return auth.accessToken;
    } catch (error) {
      debugPrint('Google アクセストークン取得エラー: $error');
      return null;
    }
  }

  /// サイレントサインイン（自動サインイン）を試行
  ///
  /// 以前にサインインしたことがある場合、ユーザーの操作なしで
  /// 自動的にサインインを試行します。
  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      debugPrint('Google サイレントサインイン開始');
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account != null) {
        debugPrint('Google サイレントサインイン成功: ${account.email}');
        return account;
      } else {
        debugPrint('Google サイレントサインイン: 以前のサインイン情報なし');
        return null;
      }
    } catch (error) {
      debugPrint('Google サイレントサインインエラー: $error');
      return null;
    }
  }

  /// 現在のサインイン状態を確認
  ///
  /// ユーザーがGoogleアカウントでサインインしているかどうかを返します。
  static bool get isSignedIn => _googleSignIn.currentUser != null;

  /// ユーザー情報を取得
  ///
  /// 現在サインインしているGoogleアカウントのユーザー情報を
  /// Map形式で返します。サインインしていない場合はnullを返します。
  static Map<String, dynamic>? getUserInfo() {
    final GoogleSignInAccount? account = _googleSignIn.currentUser;
    if (account == null) {
      return null;
    }

    return {
      'id': account.id,
      'email': account.email,
      'displayName': account.displayName,
      'photoUrl': account.photoUrl,
    };
  }
}
