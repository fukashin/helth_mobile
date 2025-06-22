import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // バックエンドサーバーのベースURL
  static const String baseUrl = 'http://localhost:8000/api';

  // 認証関連
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // バックエンドは {"message": "Logged in successfully."} を返すが、
      // トークンはCookieに設定される。モバイルアプリでは別の方法でトークンを取得する必要がある
      final responseBody = jsonDecode(response.body);
      
      // 仮のトークンとユーザー情報を返す（実際の実装では適切な方法でトークンを取得する）
      return {
        'message': responseBody['message'],
        'access_token': 'dummy_token', // 実際の実装では適切なトークンを取得
        'user': {'email': email} // 実際の実装では適切なユーザー情報を取得
      };
    } else {
      throw Exception('ログインに失敗しました');
    }
  }

  Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('登録成功: ${response.body}');
      return true;
    } else {
      debugPrint('登録失敗: ${response.body}');
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userinfo/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('プロフィール取得に失敗しました');
    }
  }

  // カロリー記録関連
  Future<List<dynamic>> getCalorieRecords(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/calories/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('カロリー記録の取得に失敗しました');
    }
  }

  Future<Map<String, dynamic>> addCalorieRecord(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calories/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('カロリー記録の追加に失敗しました');
    }
  }

  // 体重記録関連
  Future<List<dynamic>> getWeightRecords(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weight/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('体重記録の取得に失敗しました');
    }
  }

  Future<Map<String, dynamic>> addWeightRecord(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/weight/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('体重記録の追加に失敗しました');
    }
  }

  // 睡眠記録関連
  Future<List<dynamic>> getSleepRecords(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sleep/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('睡眠記録の取得に失敗しました');
    }
  }

  Future<Map<String, dynamic>> addSleepRecord(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sleep/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('睡眠記録の追加に失敗しました');
    }
  }

  // 運動記録関連
  Future<List<dynamic>> getExerciseRecords(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercise/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('運動記録の取得に失敗しました');
    }
  }

  Future<Map<String, dynamic>> addExerciseRecord(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exercise/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('運動記録の追加に失敗しました');
    }
  }
}
