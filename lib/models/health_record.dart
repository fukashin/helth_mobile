class CalorieRecord {
  final int? id;
  final DateTime date;
  final double calories;
  final String? description;

  CalorieRecord({
    this.id,
    required this.date,
    required this.calories,
    this.description,
  });

  factory CalorieRecord.fromJson(Map<String, dynamic> json) {
    return CalorieRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      calories: json['calories'].toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'calories': calories,
      'description': description,
    };
  }
}

class WeightRecord {
  final int? id;
  final DateTime date;
  final double weight;
  final String? notes;

  WeightRecord({
    this.id,
    required this.date,
    required this.weight,
    this.notes,
  });

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      weight: json['weight'].toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'weight': weight,
      'notes': notes,
    };
  }
}

class SleepRecord {
  final int? id;
  final DateTime date;
  final double hours;
  final String? quality;
  final String? notes;

  SleepRecord({
    this.id,
    required this.date,
    required this.hours,
    this.quality,
    this.notes,
  });

  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    return SleepRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      hours: json['hours'].toDouble(),
      quality: json['quality'],
      notes: json['notes'],
    );
  }

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

class ExerciseRecord {
  final int? id;
  final DateTime date;
  final String exerciseType;
  final double duration;
  final double? calories;
  final String? notes;

  ExerciseRecord({
    this.id,
    required this.date,
    required this.exerciseType,
    required this.duration,
    this.calories,
    this.notes,
  });

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
