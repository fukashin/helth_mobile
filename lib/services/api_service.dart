import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// APIサービスクラス
///
/// バックエンドサーバーとの通信を担当し、認証や健康データの取得・追加などの
/// API呼び出しを提供します。環境設定に基づいて適切なエンドポイントに接続します。
class ApiService {
  /// バックエンドサーバーのベースURL（環境設定から取得）
  static String get baseUrl => Environment.baseUrl;

  /// デバッグ用のログ出力メソッド
  ///
  /// API呼び出しの詳細情報をコンソールに出力します。
  ///
  /// [method] HTTPメソッド（GET, POST, PUT, DELETEなど）
  /// [endpoint] APIエンドポイント
  /// [requestData] リクエストデータ（任意）
  /// [statusCode] レスポンスのステータスコード（任意）
  /// [responseBody] レスポンスのボディ（任意）
  /// [error] エラー情報（任意）
  /// [details] 詳細情報（任意）
  static void _debugLog(String method, String endpoint, {Map<String, dynamic>? requestData, int? statusCode, String? responseBody, String? error, String? details}) {
    print('=== API Debug Log ===');
    print('環境: ${Environment.currentEnvironment}');
    print('メソッド: $method');
    print('エンドポイント: $endpoint');
    if (requestData != null) {
      print('リクエストデータ: ${jsonEncode(requestData)}');
    }
    if (statusCode != null) {
      print('ステータスコード: $statusCode');
    }
    if (responseBody != null) {
      print('レスポンス: $responseBody');
    }
    if (error != null) {
      print('エラー: $error');
    }
    if (details != null) {
      print('詳細: $details');
    }
    print('==================');
  }

  /// ログイン処理を行うメソッド
  ///
  /// [email] ユーザーのメールアドレス
  /// [password] ユーザーのパスワード
  ///
  /// 成功時はトークンとユーザー情報を含むMapを返します。
  /// 失敗時は例外をスローします。
  Future<Map<String, dynamic>> login(String email, String password) async {
    final endpoint = '$baseUrl/token/';
    final requestData = {'email': email, 'password': password};
    
    try {
      _debugLog('POST', endpoint, requestData: requestData);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      _debugLog('POST', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        // レスポンスボディからトークンとユーザー情報を取得
        final responseBody = jsonDecode(response.body);
        
        // APIレスポンスから直接トークンとユーザー情報を取得
        final result = {
          'message': responseBody['message'],
          'access_token': responseBody['access_token'],
          'refresh_token': responseBody['refresh_token'],
          'user': responseBody['user']
        };
        
        print('ログイン成功: $email');
        return result;
      } else {
        final errorMessage = 'ログインに失敗しました (ステータス: ${response.statusCode})';
        _debugLog('POST', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'ログイン処理でエラーが発生しました: $e';
      _debugLog('POST', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  /// ユーザー登録処理を行うメソッド
  ///
  /// [email] ユーザーのメールアドレス
  /// [password] ユーザーのパスワード
  /// [name] ユーザーの名前（オプション）
  ///
  /// 成功時はトークンとユーザー情報を含むMapを返します。
  /// 失敗時はfalseを返します。
  Future<dynamic> register(String email, String password, {String? name}) async {
    final endpoint = '$baseUrl/register/';
    final requestData = {
      'email': email, 
      'password': password,
      if (name != null) 'name': name
    };
    
    try {
      _debugLog('POST', endpoint, requestData: requestData);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      _debugLog('POST', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 201) {
        // レスポンスボディからトークンとユーザー情報を取得
        final responseBody = jsonDecode(response.body);
        
        // APIレスポンスから直接トークンとユーザー情報を取得
        final result = {
          'message': responseBody['message'],
          'access_token': responseBody['access_token'],
          'refresh_token': responseBody['refresh_token'],
          'user': responseBody['user']
        };
        
        print('登録成功: $email');
        return result;
      } else {
        print('登録失敗: $email (ステータス: ${response.statusCode})');
        return false;
      }
    } catch (e) {
      final errorMessage = '登録処理でエラーが発生しました: $e';
      _debugLog('POST', endpoint, error: errorMessage);
      print(errorMessage);
      return false;
    }
  }

  /// ユーザープロファイル情報を取得するメソッド
  ///
  /// [token] 認証トークン
  ///
  /// 成功時はユーザー情報を含むMapを返します。
  /// 失敗時は例外をスローします。
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final endpoint = '$baseUrl/userinfo-standard/';
    
    try {
      _debugLog('GET', endpoint);
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _debugLog('GET', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('プロフィール取得成功');
        return result;
      } else {
        final errorMessage = 'プロフィール取得に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('GET', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'プロフィール取得処理でエラーが発生しました: $e';
      _debugLog('GET', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  /// ユーザープロファイル詳細情報を取得するメソッド
  ///
  /// [token] 認証トークン
  /// [userId] ユーザーID
  ///
  /// 成功時はユーザープロファイル情報を含むMapを返します。
  /// 失敗時は例外をスローします。
  Future<Map<String, dynamic>> getUserProfileDetails(String token, int userId) async {
    final endpoint = '$baseUrl/user-profiles/$userId/';
    
    try {
      _debugLog('GET', endpoint);
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _debugLog('GET', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('プロフィール詳細取得成功');
        return result;
      } else {
        final errorMessage = 'プロフィール詳細取得に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('GET', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'プロフィール詳細取得処理でエラーが発生しました: $e';
      _debugLog('GET', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  /// ユーザープロファイルを更新するメソッド
  ///
  /// [token] 認証トークン
  /// [userId] ユーザーID
  /// [data] 更新するプロファイルデータ
  ///
  /// 成功時は更新されたプロファイル情報を返します。
  /// 失敗時は例外をスローします。
  Future<Map<String, dynamic>> updateUserProfile(String token, int userId, Map<String, dynamic> data) async {
    final endpoint = '$baseUrl/user-profiles/$userId/';
    
    try {
      _debugLog('PATCH', endpoint, requestData: data);
      
      final response = await http.patch(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      _debugLog('PATCH', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('プロフィール更新成功');
        return result;
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final errorMessage = errorBody['detail'] ?? 'プロフィール更新に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('PATCH', endpoint, error: errorMessage, responseBody: response.body);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'プロフィール更新処理でエラーが発生しました: $e';
      _debugLog('PATCH', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  /// カロリー記録を取得するメソッド
  ///
  /// [token] 認証トークン
  ///
  /// 成功時はカロリー記録のリストを返します。
  /// 失敗時は例外をスローします。
  Future<List<dynamic>> getCalorieRecords(String token) async {
    final endpoint = '$baseUrl/calorie-records/';
    
    try {
      _debugLog('GET', endpoint);
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _debugLog('GET', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('カロリー記録取得成功: ${result.length}件');
        return result;
      } else {
        final errorMessage = 'カロリー記録の取得に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('GET', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'カロリー記録取得処理でエラーが発生しました: $e';
      _debugLog('GET', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  /// カロリー記録を追加するメソッド
  ///
  /// [token] 認証トークン
  /// [data] 追加するカロリー記録データ
  ///
  /// 成功時は追加されたカロリー記録を返します。
  /// 失敗時は例外をスローします。
  Future<Map<String, dynamic>> addCalorieRecord(String token, Map<String, dynamic> data) async {
    // ユーザー情報を取得
    final userInfo = await getUserProfile(token);
    final userId = userInfo['user_id'];
    
    // バックエンドのフィールド名に合わせてデータを変換
    final requestData = {
      'user': userId,
      'recorded_at': data['date'], // date → recorded_at
      'calorie': data['calories'], // calories → calorie
      if (data['description'] != null) 'category': data['description'], // description → category
    };
    
    final endpoint = '$baseUrl/calorie-records/';
    
    try {
      _debugLog('POST', endpoint, requestData: requestData);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      );

      _debugLog('POST', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        print('カロリー記録追加成功');
        return result;
      } else {
        final errorMessage = 'カロリー記録の追加に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('POST', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'カロリー記録追加処理でエラーが発生しました: $e';
      _debugLog('POST', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  /// 体重記録を取得するメソッド
  ///
  /// [token] 認証トークン
  ///
  /// 成功時は体重記録のリストを返します。
  /// 失敗時は例外をスローします。
  Future<List<dynamic>> getWeightRecords(String token) async {
    final endpoint = '$baseUrl/weight-records/';
    
    try {
      _debugLog('GET', endpoint);
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _debugLog('GET', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('体重記録取得成功: ${result.length}件');
        return result;
      } else {
        final errorMessage = '体重記録の取得に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('GET', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = '体重記録取得処理でエラーが発生しました: $e';
      _debugLog('GET', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  /// 体重記録を追加するメソッド
  ///
  /// [token] 認証トークン
  /// [data] 追加する体重記録データ
  ///
  /// 成功時は追加された体重記録を返します。
  /// 失敗時は例外をスローします。
  Future<Map<String, dynamic>> addWeightRecord(String token, Map<String, dynamic> data) async {
    // ユーザー情報を取得
    final userInfo = await getUserProfile(token);
    final userId = userInfo['user_id'];
    
    // バックエンドのフィールド名に合わせてデータを変換
    final requestData = {
      'user': userId,
      'recorded_at': data['date'], // date → recorded_at
      'weight': data['weight'],
      if (data['notes'] != null) 'notes': data['notes'],
    };
    
    final endpoint = '$baseUrl/weight-records/';
    
    try {
      _debugLog('POST', endpoint, requestData: requestData);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      );

      _debugLog('POST', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        print('体重記録追加成功');
        return result;
      } else {
        final errorMessage = '体重記録の追加に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('POST', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = '体重記録追加処理でエラーが発生しました: $e';
      _debugLog('POST', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  /// 睡眠記録を取得するメソッド
  ///
  /// [token] 認証トークン
  ///
  /// 成功時は睡眠記録のリストを返します。
  /// 失敗時は例外をスローします。
  Future<List<dynamic>> getSleepRecords(String token) async {
    final endpoint = '$baseUrl/sleep-records/';
    
    try {
      _debugLog('GET', endpoint);
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _debugLog('GET', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('睡眠記録取得成功: ${result.length}件');
        return result;
      } else {
        final errorMessage = '睡眠記録の取得に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('GET', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = '睡眠記録取得処理でエラーが発生しました: $e';
      _debugLog('GET', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  /// 睡眠記録を追加するメソッド
  ///
  /// [token] 認証トークン
  /// [data] 追加する睡眠記録データ
  ///
  /// 成功時は追加された睡眠記録を返します。
  /// 失敗時は例外をスローします。
  Future<Map<String, dynamic>> addSleepRecord(String token, Map<String, dynamic> data) async {
    // ユーザー情報を取得
    final userInfo = await getUserProfile(token);
    final userId = userInfo['user_id'];
    
    // バックエンドのフィールド名に合わせてデータを変換
    final requestData = {
      'user': userId,
      'recorded_at': data['date'], // date → recorded_at
      'sleep_time': data['hours'], // hours → sleep_time
      if (data['quality'] != null) 'quality': data['quality'],
      if (data['notes'] != null) 'notes': data['notes'],
    };
    
    final endpoint = '$baseUrl/sleep-records/';
    
    try {
      _debugLog('POST', endpoint, requestData: requestData);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      );

      _debugLog('POST', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        print('睡眠記録追加成功');
        return result;
      } else {
        final errorMessage = '睡眠記録の追加に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('POST', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = '睡眠記録追加処理でエラーが発生しました: $e';
      _debugLog('POST', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  /// 運動記録を取得するメソッド（現在は空のリストを返す）
  ///
  /// [token] 認証トークン
  ///
  /// 運動記録機能は未実装のため、空のリストを返します。
  Future<List<dynamic>> getExerciseRecords(String token) async {
    _debugLog('GET', 'exercise-records (未実装)', details: '空のリストを返します');
    return [];
  }

  /// 運動記録を追加するメソッド（現在は未実装）
  ///
  /// [token] 認証トークン
  /// [data] 追加する運動記録データ
  ///
  /// 運動記録機能は未実装のため、例外をスローします。
  Future<Map<String, dynamic>> addExerciseRecord(String token, Map<String, dynamic> data) async {
    _debugLog('POST', 'exercise-records (未実装)', error: '運動記録機能は未実装です');
    throw Exception('運動記録機能は未実装です');
  }
}
