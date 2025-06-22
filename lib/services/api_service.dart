import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // バックエンドサーバーのベースURL
  static const String baseUrl = 'http://localhost:8000/api';

  // 認証関連
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('ログインに失敗しました');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('登録に失敗しました');
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
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
