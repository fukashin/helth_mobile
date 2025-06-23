import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/environment.dart';

class ApiService {
  // バックエンドサーバーのベースURL（環境設定から取得）
  static String get baseUrl => Environment.baseUrl;

  // デバッグ用のログ出力メソッド
  static void _debugLog(String method, String endpoint, {Map<String, dynamic>? requestData, int? statusCode, String? responseBody, String? error}) {
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
    print('==================');
  }

  // 認証関連
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
        // バックエンドは {"message": "Logged in successfully."} を返すが、
        // トークンはCookieに設定される。モバイルアプリでは別の方法でトークンを取得する必要がある
        final responseBody = jsonDecode(response.body);
        
        // 仮のトークンとユーザー情報を返す（実際の実装では適切な方法でトークンを取得する）
        final result = {
          'message': responseBody['message'],
          'access_token': 'dummy_token', // 実際の実装では適切なトークンを取得
          'user': {'email': email} // 実際の実装では適切なユーザー情報を取得
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

  Future<bool> register(String email, String password) async {
    final endpoint = '$baseUrl/register/';
    final requestData = {'email': email, 'password': password};
    
    try {
      _debugLog('POST', endpoint, requestData: requestData);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      _debugLog('POST', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 201) {
        print('登録成功: $email');
        return true;
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

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final endpoint = '$baseUrl/userinfo/';
    
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

  // カロリー記録関連
  Future<List<dynamic>> getCalorieRecords(String token) async {
    final endpoint = '$baseUrl/calories/';
    
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

  Future<Map<String, dynamic>> addCalorieRecord(String token, Map<String, dynamic> data) async {
    final endpoint = '$baseUrl/calories/';
    
    try {
      _debugLog('POST', endpoint, requestData: data);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
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

  // 体重記録関連
  Future<List<dynamic>> getWeightRecords(String token) async {
    final endpoint = '$baseUrl/weight/';
    
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

  Future<Map<String, dynamic>> addWeightRecord(String token, Map<String, dynamic> data) async {
    final endpoint = '$baseUrl/weight/';
    
    try {
      _debugLog('POST', endpoint, requestData: data);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
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

  // 睡眠記録関連
  Future<List<dynamic>> getSleepRecords(String token) async {
    final endpoint = '$baseUrl/sleep/';
    
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

  Future<Map<String, dynamic>> addSleepRecord(String token, Map<String, dynamic> data) async {
    final endpoint = '$baseUrl/sleep/';
    
    try {
      _debugLog('POST', endpoint, requestData: data);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
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

  // 運動記録関連
  Future<List<dynamic>> getExerciseRecords(String token) async {
    final endpoint = '$baseUrl/exercise/';
    
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
        print('運動記録取得成功: ${result.length}件');
        return result;
      } else {
        final errorMessage = '運動記録の取得に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('GET', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = '運動記録取得処理でエラーが発生しました: $e';
      _debugLog('GET', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> addExerciseRecord(String token, Map<String, dynamic> data) async {
    final endpoint = '$baseUrl/exercise/';
    
    try {
      _debugLog('POST', endpoint, requestData: data);
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      _debugLog('POST', endpoint, statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        print('運動記録追加成功');
        return result;
      } else {
        final errorMessage = '運動記録の追加に失敗しました (ステータス: ${response.statusCode})';
        _debugLog('POST', endpoint, error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = '運動記録追加処理でエラーが発生しました: $e';
      _debugLog('POST', endpoint, error: errorMessage);
      throw Exception(errorMessage);
    }
  }
}
