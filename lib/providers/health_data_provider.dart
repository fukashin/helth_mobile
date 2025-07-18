import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/health_record.dart';

/// 健康データ管理プロバイダー
///
/// ユーザーの健康データ（カロリー、体重、睡眠、運動）を管理します。
/// APIからデータの取得と追加を行い、UIに変更を通知します。
class HealthDataProvider with ChangeNotifier {
  /// カロリー記録のリスト
  List<CalorieRecord> _calorieRecords = [];
  
  /// 体重記録のリスト
  List<WeightRecord> _weightRecords = [];
  
  /// 睡眠記録のリスト
  List<SleepRecord> _sleepRecords = [];
  
  /// 運動記録のリスト
  List<ExerciseRecord> _exerciseRecords = [];
  
  /// データ読み込み中かどうか
  bool _isLoading = false;

  /// カロリー記録のリストを取得
  List<CalorieRecord> get calorieRecords => _calorieRecords;
  
  /// 体重記録のリストを取得
  List<WeightRecord> get weightRecords => _weightRecords;
  
  /// 睡眠記録のリストを取得
  List<SleepRecord> get sleepRecords => _sleepRecords;
  
  /// 運動記録のリストを取得
  List<ExerciseRecord> get exerciseRecords => _exerciseRecords;
  
  /// データ読み込み中かどうかを取得
  bool get isLoading => _isLoading;
  
  /// 日付ごとの健康データを取得
  /// 
  /// 全ての健康データを日付ごとにまとめて返します。
  Map<String, DailyHealthData> get dailyHealthData => _getDailyHealthData();

  /// APIサービスのインスタンス
  final ApiService _apiService = ApiService();

  /// デバッグ用のログ出力メソッド
  ///
  /// [action] 実行中のアクション名
  /// [details] 詳細情報（任意）
  /// [error] エラー情報（任意）
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

  /// 健康データを読み込むメソッド
  ///
  /// [token] 認証トークン
  ///
  /// APIから各種健康データ（カロリー、体重、睡眠）を並行して取得します。
  Future<void> loadHealthData(String token) async {
    _debugLog('健康データ読み込み開始');
    _isLoading = true;
    notifyListeners();

    try {
      // 各種健康データを並行して取得（運動記録は除外）
      final results = await Future.wait([
        _apiService.getCalorieRecords(token),
        _apiService.getWeightRecords(token),
        _apiService.getSleepRecords(token),
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
      
      // 運動記録は空のリストで初期化
      _exerciseRecords = [];

      _isLoading = false;
      notifyListeners();
      _debugLog('健康データ読み込み成功', 
        details: 'カロリー: ${_calorieRecords.length}件, 体重: ${_weightRecords.length}件, 睡眠: ${_sleepRecords.length}件');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _debugLog('健康データ読み込み失敗', error: e.toString());
      rethrow;
    }
  }
  
  /// 日付ごとの健康データを取得するメソッド
  /// 
  /// 全ての健康データ（カロリー、体重、睡眠、運動）を日付ごとにまとめます。
  Map<String, DailyHealthData> _getDailyHealthData() {
    final Map<String, DailyHealthData> dailyData = {};
    
    // 日付のフォーマット（YYYY-MM-DD）を取得する関数
    String getDateKey(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
    
    // 体重記録を処理
    for (final record in _weightRecords) {
      final dateKey = getDateKey(record.date);
      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = DailyHealthData(date: record.date);
      }
      dailyData[dateKey] = DailyHealthData(
        date: record.date,
        weight: record.weight,
        calories: dailyData[dateKey]?.calories,
        sleep: dailyData[dateKey]?.sleep,
        exercise: dailyData[dateKey]?.exercise,
        exerciseType: dailyData[dateKey]?.exerciseType,
      );
    }
    
    // カロリー記録を処理
    for (final record in _calorieRecords) {
      final dateKey = getDateKey(record.date);
      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = DailyHealthData(date: record.date);
      }
      
      // 既存のカロリー値があれば加算、なければ新規設定
      final existingCalories = dailyData[dateKey]?.calories ?? 0;
      
      dailyData[dateKey] = DailyHealthData(
        date: record.date,
        weight: dailyData[dateKey]?.weight,
        calories: existingCalories + record.calories,
        sleep: dailyData[dateKey]?.sleep,
        exercise: dailyData[dateKey]?.exercise,
        exerciseType: dailyData[dateKey]?.exerciseType,
      );
    }
    
    // 睡眠記録を処理
    for (final record in _sleepRecords) {
      final dateKey = getDateKey(record.date);
      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = DailyHealthData(date: record.date);
      }
      dailyData[dateKey] = DailyHealthData(
        date: record.date,
        weight: dailyData[dateKey]?.weight,
        calories: dailyData[dateKey]?.calories,
        sleep: record.hours,
        exercise: dailyData[dateKey]?.exercise,
        exerciseType: dailyData[dateKey]?.exerciseType,
      );
    }
    
    // 運動記録を処理
    for (final record in _exerciseRecords) {
      final dateKey = getDateKey(record.date);
      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = DailyHealthData(date: record.date);
      }
      
      // 既存の運動時間があれば加算、なければ新規設定
      final existingExercise = dailyData[dateKey]?.exercise ?? 0;
      
      dailyData[dateKey] = DailyHealthData(
        date: record.date,
        weight: dailyData[dateKey]?.weight,
        calories: dailyData[dateKey]?.calories,
        sleep: dailyData[dateKey]?.sleep,
        exercise: existingExercise + record.duration,
        exerciseType: record.exerciseType, // 最後の運動タイプを使用
      );
    }
    
    return dailyData;
  }
  
  /// 特定の日付の健康データを取得するメソッド
  /// 
  /// [date] 取得する日付
  /// 
  /// 指定された日付の健康データを返します。データがない場合はnullを返します。
  DailyHealthData? getDailyHealthDataForDate(DateTime date) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return dailyHealthData[dateKey];
  }

  /// カロリー記録を追加するメソッド
  ///
  /// [token] 認証トークン
  /// [record] 追加するカロリー記録
  ///
  /// APIにカロリー記録を送信し、成功した場合はローカルのリストに追加します。
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

  /// 体重記録を追加するメソッド
  ///
  /// [token] 認証トークン
  /// [record] 追加する体重記録
  ///
  /// APIに体重記録を送信し、成功した場合はローカルのリストに追加します。
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

  /// 睡眠記録を追加するメソッド
  ///
  /// [token] 認証トークン
  /// [record] 追加する睡眠記録
  ///
  /// APIに睡眠記録を送信し、成功した場合はローカルのリストに追加します。
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

  /// 運動記録を追加するメソッド
  ///
  /// [token] 認証トークン
  /// [record] 追加する運動記録
  ///
  /// APIに運動記録を送信し、成功した場合はローカルのリストに追加します。
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
