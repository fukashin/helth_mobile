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

  Future<void> loadHealthData(String token) async {
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
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addCalorieRecord(String token, CalorieRecord record) async {
    try {
      final response = await _apiService.addCalorieRecord(token, record.toJson());
      final newRecord = CalorieRecord.fromJson(response);
      _calorieRecords.add(newRecord);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addWeightRecord(String token, WeightRecord record) async {
    try {
      final response = await _apiService.addWeightRecord(token, record.toJson());
      final newRecord = WeightRecord.fromJson(response);
      _weightRecords.add(newRecord);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSleepRecord(String token, SleepRecord record) async {
    try {
      final response = await _apiService.addSleepRecord(token, record.toJson());
      final newRecord = SleepRecord.fromJson(response);
      _sleepRecords.add(newRecord);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addExerciseRecord(String token, ExerciseRecord record) async {
    try {
      final response = await _apiService.addExerciseRecord(token, record.toJson());
      final newRecord = ExerciseRecord.fromJson(response);
      _exerciseRecords.add(newRecord);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
