import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/health_record.dart';

class HealthDataProvider with ChangeNotifier {
  List<CalorieRecord> _calorieRecords = [];
  List<WeightRecord> _weightRecords = [];
  List<SleepRecord> _sleepRecords = [];
  List<ExerciseRecord> _exerciseRecords = [];
  bool _isLoading = false;

  List<CalorieRecord> get calorieRecords => _calorieRecords;
  List<WeightRecord> get weightRecords => _weightRecords;
  List<SleepRecord> get sleepRecords => _sleepRecords;
  List<ExerciseRecord> get exerciseRecords => _exerciseRecords;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  // デバッグ用のログ出力メソッド
  void _debugLog(String action, {String? details, String? error}) {
    print('=== HealthDataProvider Debug Log ===');
    print('アクション: $action');
    print('カロリー記録数: ${_calorieRecords.length}');
    print('体重記録数: ${_weightRecords.length}');
    print('睡眠記録数: ${_sleepRecords.length}');
    print('運動記録数: ${_exerciseRecords.length}');
    print('ローディング状態: $_isLoading');
    if (details != null) {
      print('詳細: $details');
    }
    if (error != null) {
      print('エラー: $error');
    }
    print('===================================');
  }

  Future<void> loadHealthData(String token) async {
    _debugLog('健康データ読み込み開始');
    _isLoading = true;
    notifyListeners();

    try {
      // 各種健康データを並行して取得
      final results = await Future.wait([
        _apiService.getCalorieRecords(token),
        _apiService.getWeightRecords(token),
        _apiService.getSleepRecords(token),
        _apiService.getExerciseRecords(token),
      ]);

      _calorieRecords = (results[0] as List)
          .map((json) => CalorieRecord.fromJson(json))
          .toList();
      _weightRecords = (results[1] as List)
          .map((json) => WeightRecord.fromJson(json))
          .toList();
      _sleepRecords = (results[2] as List)
          .map((json) => SleepRecord.fromJson(json))
          .toList();
      _exerciseRecords = (results[3] as List)
          .map((json) => ExerciseRecord.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
      _debugLog('健康データ読み込み成功', 
        details: 'カロリー: ${_calorieRecords.length}件, 体重: ${_weightRecords.length}件, 睡眠: ${_sleepRecords.length}件, 運動: ${_exerciseRecords.length}件');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _debugLog('健康データ読み込み失敗', error: e.toString());
      rethrow;
    }
  }

  Future<void> addCalorieRecord(String token, CalorieRecord record) async {
    _debugLog('カロリー記録追加開始', details: 'カロリー: ${record.calories}kcal');
    try {
      final response = await _apiService.addCalorieRecord(token, record.toJson());
      final newRecord = CalorieRecord.fromJson(response);
      _calorieRecords.add(newRecord);
      notifyListeners();
      _debugLog('カロリー記録追加成功', details: 'カロリー: ${newRecord.calories}kcal, 総記録数: ${_calorieRecords.length}件');
    } catch (e) {
      _debugLog('カロリー記録追加失敗', error: e.toString());
      rethrow;
    }
  }

  Future<void> addWeightRecord(String token, WeightRecord record) async {
    _debugLog('体重記録追加開始', details: '体重: ${record.weight}kg');
    try {
      final response = await _apiService.addWeightRecord(token, record.toJson());
      final newRecord = WeightRecord.fromJson(response);
      _weightRecords.add(newRecord);
      notifyListeners();
      _debugLog('体重記録追加成功', details: '体重: ${newRecord.weight}kg, 総記録数: ${_weightRecords.length}件');
    } catch (e) {
      _debugLog('体重記録追加失敗', error: e.toString());
      rethrow;
    }
  }

  Future<void> addSleepRecord(String token, SleepRecord record) async {
    _debugLog('睡眠記録追加開始', details: '睡眠時間: ${record.hours}時間');
    try {
      final response = await _apiService.addSleepRecord(token, record.toJson());
      final newRecord = SleepRecord.fromJson(response);
      _sleepRecords.add(newRecord);
      notifyListeners();
      _debugLog('睡眠記録追加成功', details: '睡眠時間: ${newRecord.hours}時間, 総記録数: ${_sleepRecords.length}件');
    } catch (e) {
      _debugLog('睡眠記録追加失敗', error: e.toString());
      rethrow;
    }
  }

  Future<void> addExerciseRecord(String token, ExerciseRecord record) async {
    _debugLog('運動記録追加開始', details: '運動: ${record.exerciseType}, 時間: ${record.duration}分');
    try {
      final response = await _apiService.addExerciseRecord(token, record.toJson());
      final newRecord = ExerciseRecord.fromJson(response);
      _exerciseRecords.add(newRecord);
      notifyListeners();
      _debugLog('運動記録追加成功', details: '運動: ${newRecord.exerciseType}, 時間: ${newRecord.duration}分, 総記録数: ${_exerciseRecords.length}件');
    } catch (e) {
      _debugLog('運動記録追加失敗', error: e.toString());
      rethrow;
    }
  }
}
