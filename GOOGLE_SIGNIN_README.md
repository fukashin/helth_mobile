# Google Sign-In 実装ガイド

このドキュメントでは、健康管理アプリに実装されたGoogle Sign-In機能について説明します。

## 実装概要

Google Sign-Inを使用したSSO（Single Sign-On）認証機能を追加しました。これにより、ユーザーはGoogleアカウントを使用してアプリにサインインできます。

## 実装されたファイル

### 1. パッケージ追加
- `pubspec.yaml`: `google_sign_in: ^6.1.5` を追加

### 2. サービス層
- `lib/services/google_sign_in_service.dart`: Google Sign-In機能を提供するサービスクラス
  - サインイン/サインアウト
  - サイレントサインイン（自動ログイン）
  - IDトークン/アクセストークンの取得
  - ユーザー情報の取得

### 3. 認証プロバイダー
- `lib/providers/auth_provider.dart`: 既存の認証プロバイダーにGoogle Sign-In機能を追加
  - `signInWithGoogle()`: Google Sign-Inでのログイン
  - `signInWithGoogleSilently()`: サイレントサインイン
  - 認証プロバイダーの管理（email/google）
  - ログアウト時のGoogle Sign-Out処理

### 4. UI層
- `lib/screens/login_screen.dart`: ログイン画面にGoogle Sign-Inボタンを追加
  - 既存のメール/パスワードログインとの併用
  - Google Sign-Inボタンのデザイン
  - エラーハンドリング

### 5. Android設定
- `android/app/src/main/AndroidManifest.xml`: インターネット権限を追加

## 機能詳細

### Google Sign-In フロー

1. **初回サインイン**
   - ユーザーが「Googleでサインイン」ボタンをタップ
   - Google認証画面が表示される
   - ユーザーがGoogleアカウントを選択・認証
   - IDトークンを取得してアプリ内で認証状態を設定
   - 認証情報をローカルストレージに保存

2. **サイレントサインイン（自動ログイン）**
   - アプリ起動時に自動実行
   - 以前にサインインしたことがある場合、ユーザー操作なしでサインイン
   - 失敗した場合は通常のログイン画面を表示

3. **ログアウト**
   - アプリ内の認証状態をクリア
   - Googleからもサインアウト
   - ローカルストレージの認証情報を削除

### 認証プロバイダー管理

アプリは以下の認証プロバイダーをサポートします：
- `email`: 従来のメール/パスワード認証
- `google`: Google Sign-In認証

認証プロバイダー情報はローカルストレージに保存され、ログアウト時の処理分岐に使用されます。

## テスト実装について

現在の実装はテスト用であり、以下の点にご注意ください：

### 1. サーバー連携
現在はクライアント側のみの実装です。本格運用時は以下が必要です：
- サーバー側でのIDトークン検証
- サーバー側でのユーザー情報管理
- サーバー発行のアクセストークンの使用

### 2. Google Cloud Console設定
実際のアプリで使用する場合は、Google Cloud Consoleでの設定が必要です：
- OAuth 2.0クライアントIDの作成
- Android/iOS用の設定
- SHA-1フィンガープリントの登録（Android）

### 3. セキュリティ考慮事項
- IDトークンの適切な検証
- トークンの安全な保存
- 適切なスコープの設定

## 使用方法

### 基本的な使用方法

```dart
// Google Sign-Inでログイン
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.signInWithGoogle();

if (success) {
  // ログイン成功
  print('ログイン成功: ${authProvider.user?['email']}');
} else {
  // ログイン失敗
  print('ログインに失敗しました');
}
```

### 認証状態の確認

```dart
// 認証状態を確認
if (authProvider.isAuthenticated) {
  // 認証済み
  final user = authProvider.user;
  final provider = await authProvider.getAuthProvider();
  print('認証済み: ${user?['email']} (プロバイダー: $provider)');
}
```

### ログアウト

```dart
// ログアウト（認証プロバイダーに応じて適切に処理される）
await authProvider.logout();
```

## デバッグ情報

AuthProviderには詳細なデバッグログが実装されています。開発時は以下の情報が出力されます：
- 認証状態の変更
- トークンの取得/保存
- エラー情報
- Google Sign-Inの各ステップ

## 今後の拡張予定

1. **他のSSOプロバイダー対応**
   - Apple Sign-In
   - Facebook Login
   - Twitter Login

2. **セキュリティ強化**
   - トークンの暗号化保存
   - 生体認証との連携
   - セッション管理の改善

3. **ユーザビリティ向上**
   - プロフィール画像の表示
   - アカウント切り替え機能
   - 連携アカウントの管理

## トラブルシューティング

### よくある問題

1. **Google Sign-Inが動作しない**
   - インターネット接続を確認
   - Google Play Servicesが最新か確認
   - SHA-1フィンガープリントが正しく設定されているか確認

2. **サイレントサインインが失敗する**
   - 以前のサインイン情報がない場合は正常な動作
   - Googleアカウントの認証が期限切れの可能性

3. **トークン取得に失敗する**
   - ネットワーク接続を確認
   - Google Sign-Inの設定を確認

### ログの確認方法

デバッグログを確認することで問題を特定できます：

```
=== AuthProvider Debug Log ===
アクション: Google Sign-In開始
認証状態: false
トークン有無: なし
ユーザー情報: なし
ローディング状態: true
=============================
```

## まとめ

Google Sign-In機能により、ユーザーはより簡単にアプリにアクセスできるようになりました。現在はテスト実装ですが、本格運用時はサーバー側の実装とセキュリティ対策を追加することで、安全で使いやすい認証システムを提供できます。
