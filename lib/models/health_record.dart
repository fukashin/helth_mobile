/// カロリー記録モデル
///
/// ユーザーの摂取カロリーを記録するためのモデルクラスです。
class CalorieRecord {
  /// 記録ID（APIから取得した場合に設定される）
  final int? id;
  
  /// 記録日
  final DateTime date;
  
  /// 摂取カロリー（kcal）
  final double calories;
  
  /// 説明（任意）
  final String? description;

  CalorieRecord({
    this.id,
    required this.date,
    required this.calories,
    this.description,
  });

  /// JSONからオブジェクトを生成するファクトリメソッド
  ///
  /// [json] APIから取得したJSONデータ
  factory CalorieRecord.fromJson(Map<String, dynamic> json) {
    return CalorieRecord(
      id: json['id'],
      date: DateTime.parse(json['recorded_at'] ?? json['date'] ?? DateTime.now().toIso8601String()),
      calories: (json['calorie'] ?? json['calories'] ?? 0).toDouble(),
      description: json['category'] ?? json['description'],
    );
  }

  /// オブジェクトをJSON形式に変換するメソッド
  ///
  /// APIリクエスト用のJSONデータを返します。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'calories': calories,
      'description': description,
    };
  }
}

/// 体重記録モデル
///
/// ユーザーの体重を記録するためのモデルクラスです。
class WeightRecord {
  /// 記録ID（APIから取得した場合に設定される）
  final int? id;
  
  /// 記録日
  final DateTime date;
  
  /// 体重（kg）
  final double weight;
  
  /// メモ（任意）
  final String? notes;

  WeightRecord({
    this.id,
    required this.date,
    required this.weight,
    this.notes,
  });

  /// JSONからオブジェクトを生成するファクトリメソッド
  ///
  /// [json] APIから取得したJSONデータ
  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'],
      date: DateTime.parse(json['recorded_at'] ?? json['date'] ?? DateTime.now().toIso8601String()),
      weight: (json['weight'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }

  /// オブジェクトをJSON形式に変換するメソッド
  ///
  /// APIリクエスト用のJSONデータを返します。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'weight': weight,
      'notes': notes,
    };
  }
}

/// 睡眠記録モデル
///
/// ユーザーの睡眠時間を記録するためのモデルクラスです。
class SleepRecord {
  /// 記録ID（APIから取得した場合に設定される）
  final int? id;
  
  /// 記録日
  final DateTime date;
  
  /// 睡眠時間（時間）
  final double hours;
  
  /// 睡眠の質（任意）
  final String? quality;
  
  /// メモ（任意）
  final String? notes;

  SleepRecord({
    this.id,
    required this.date,
    required this.hours,
    this.quality,
    this.notes,
  });

  /// JSONからオブジェクトを生成するファクトリメソッド
  ///
  /// [json] APIから取得したJSONデータ
  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    return SleepRecord(
      id: json['id'],
      date: DateTime.parse(json['recorded_at'] ?? json['date'] ?? DateTime.now().toIso8601String()),
      hours: (json['sleep_time'] ?? json['hours'] ?? 0).toDouble(),
      quality: json['quality'],
      notes: json['notes'],
    );
  }

  /// オブジェクトをJSON形式に変換するメソッド
  ///
  /// APIリクエスト用のJSONデータを返します。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'hours': hours,
      'quality': quality,
      'notes': notes,
    };
  }
}

/// 運動記録モデル
///
/// ユーザーの運動を記録するためのモデルクラスです。
class ExerciseRecord {
  /// 記録ID（APIから取得した場合に設定される）
  final int? id;
  
  /// 記録日
  final DateTime date;
  
  /// 運動の種類
  final String exerciseType;
  
  /// 運動時間（分）
  final double duration;
  
  /// 消費カロリー（kcal、任意）
  final double? calories;
  
  /// メモ（任意）
  final String? notes;

  ExerciseRecord({
    this.id,
    required this.date,
    required this.exerciseType,
    required this.duration,
    this.calories,
    this.notes,
  });

  /// JSONからオブジェクトを生成するファクトリメソッド
  ///
  /// [json] APIから取得したJSONデータ
  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      exerciseType: json['exercise_type'],
      duration: json['duration'].toDouble(),
      calories: json['calories']?.toDouble(),
      notes: json['notes'],
    );
  }

  /// オブジェクトをJSON形式に変換するメソッド
  ///
  /// APIリクエスト用のJSONデータを返します。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'exercise_type': exerciseType,
      'duration': duration,
      'calories': calories,
      'notes': notes,
    };
  }
}

/// 日別健康データモデル
///
/// 特定の日付の健康データ（体重、カロリー、睡眠、運動）をまとめて管理するクラスです。
class DailyHealthData {
  /// 記録日
  final DateTime date;
  
  /// 体重（kg、任意）
  final double? weight;
  
  /// 摂取カロリー（kcal、任意）
  final double? calories;
  
  /// 睡眠時間（時間、任意）
  final double? sleep;
  
  /// 運動時間（分、任意）
  final double? exercise;
  
  /// 運動の種類（任意）
  final String? exerciseType;

  DailyHealthData({
    required this.date,
    this.weight,
    this.calories,
    this.sleep,
    this.exercise,
    this.exerciseType,
  });
}
