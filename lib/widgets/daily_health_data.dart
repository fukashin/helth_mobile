import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/health_record.dart';

/// 日別健康データ表示ウィジェット
///
/// 選択された日付の健康データ（カロリー、体重、睡眠、運動）を表示します。
class DailyHealthData extends StatelessWidget {
  /// 表示する日付
  final DateTime selectedDate;

  const DailyHealthData({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  /// ウィジェットの構築
  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthDataProvider, child) {
        if (healthDataProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 選択された日付のデータを取得
        final dailyData = healthDataProvider.getDailyHealthDataForDate(selectedDate);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日のデータ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // 健康データのカード
              _buildDataCard(
                title: '摂取カロリー',
                value: dailyData?.calories != null ? '${dailyData!.calories} kcal' : '記録なし',
                icon: Icons.restaurant,
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              
              _buildDataCard(
                title: '体重',
                value: dailyData?.weight != null ? '${dailyData!.weight} kg' : '記録なし',
                icon: Icons.monitor_weight,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              
              _buildDataCard(
                title: '睡眠時間',
                value: dailyData?.sleep != null ? '${dailyData!.sleep} 時間' : '記録なし',
                icon: Icons.bedtime,
                color: Colors.purple,
              ),
              const SizedBox(height: 8),
              
              _buildDataCard(
                title: '運動時間',
                value: dailyData?.exercise != null 
                  ? '${dailyData!.exercise} 分${dailyData.exerciseType != null ? " (${dailyData.exerciseType})" : ""}' 
                  : '記録なし',
                icon: Icons.fitness_center,
                color: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 健康データカードを構築するメソッド
  ///
  /// [title] カードのタイトル
  /// [value] 表示する値
  /// [icon] 表示するアイコン
  /// [color] アイコンの色
  Widget _buildDataCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          // タイトルに基づいて適切なモーダルを表示
          if (title == '摂取カロリー') {
            _showCalorieInputDialog(context, title, icon, color);
          } else if (title == '体重') {
            _showWeightInputDialog(context, title, icon, color);
          } else if (title == '睡眠時間') {
            _showSleepInputDialog(context, title, icon, color);
          } else if (title == '運動時間') {
            _showExerciseInputDialog(context, title, icon, color);
          }
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// カロリー入力ダイアログを表示するメソッド
  void _showCalorieInputDialog(BuildContext context, String title, IconData icon, Color color) {
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text('$title入力'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(
                  labelText: 'カロリー (kcal)',
                  hintText: '例: 500',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明 (任意)',
                  hintText: '例: 朝食',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (caloriesController.text.isNotEmpty) {
                try {
                  final calories = double.parse(caloriesController.text);
                  final description = descriptionController.text.isEmpty ? null : descriptionController.text;
                  
                  // ユーザーIDを取得
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('user_id');
                  
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ユーザーIDが見つかりません。再ログインしてください。')),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  
                  // 認証トークンを取得
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final token = authProvider.token;
                  
                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('認証トークンが見つかりません。再ログインしてください。')),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  
                  // カロリー記録を作成
                  final record = CalorieRecord(
                    date: selectedDate,
                    calories: calories,
                    description: description,
                  );
                  
                  // プロバイダーを通じてAPIに送信
                  final healthDataProvider = Provider.of<HealthDataProvider>(context, listen: false);
                  await healthDataProvider.addCalorieRecord(token, record);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('カロリー記録を追加しました')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('エラーが発生しました: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('カロリーを入力してください')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 体重入力ダイアログを表示するメソッド
  void _showWeightInputDialog(BuildContext context, String title, IconData icon, Color color) {
    final TextEditingController weightController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text('$title入力'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: '体重 (kg)',
                  hintText: '例: 65.5',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'メモ (任意)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (weightController.text.isNotEmpty) {
                try {
                  final weight = double.parse(weightController.text);
                  final notes = notesController.text.isEmpty ? null : notesController.text;
                  
                  // ユーザーIDを取得
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('user_id');
                  
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ユーザーIDが見つかりません。再ログインしてください。')),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  
                  // 認証トークンを取得
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final token = authProvider.token;
                  
                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('認証トークンが見つかりません。再ログインしてください。')),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  
                  // 体重記録を作成
                  final record = WeightRecord(
                    date: selectedDate,
                    weight: weight,
                    notes: notes,
                  );
                  
                  // プロバイダーを通じてAPIに送信
                  final healthDataProvider = Provider.of<HealthDataProvider>(context, listen: false);
                  await healthDataProvider.addWeightRecord(token, record);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('体重記録を追加しました')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('エラーが発生しました: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('体重を入力してください')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 睡眠時間入力ダイアログを表示するメソッド
  void _showSleepInputDialog(BuildContext context, String title, IconData icon, Color color) {
    final TextEditingController hoursController = TextEditingController();
    final TextEditingController qualityController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text('$title入力'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hoursController,
                decoration: const InputDecoration(
                  labelText: '睡眠時間 (時間)',
                  hintText: '例: 7.5',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qualityController,
                decoration: const InputDecoration(
                  labelText: '睡眠の質 (任意)',
                  hintText: '例: 良好',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'メモ (任意)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (hoursController.text.isNotEmpty) {
                try {
                  final hours = double.parse(hoursController.text);
                  final quality = qualityController.text.isEmpty ? null : qualityController.text;
                  final notes = notesController.text.isEmpty ? null : notesController.text;
                  
                  // ユーザーIDを取得
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('user_id');
                  
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ユーザーIDが見つかりません。再ログインしてください。')),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  
                  // 認証トークンを取得
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final token = authProvider.token;
                  
                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('認証トークンが見つかりません。再ログインしてください。')),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  
                  // 睡眠記録を作成
                  final record = SleepRecord(
                    date: selectedDate,
                    hours: hours,
                    quality: quality,
                    notes: notes,
                  );
                  
                  // プロバイダーを通じてAPIに送信
                  final healthDataProvider = Provider.of<HealthDataProvider>(context, listen: false);
                  await healthDataProvider.addSleepRecord(token, record);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('睡眠記録を追加しました')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('エラーが発生しました: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('睡眠時間を入力してください')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 運動時間入力ダイアログを表示するメソッド
  void _showExerciseInputDialog(BuildContext context, String title, IconData icon, Color color) {
    final TextEditingController durationController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text('$title入力'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                  labelText: '運動の種類',
                  hintText: '例: ウォーキング',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: '運動時間 (分)',
                  hintText: '例: 30',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(
                  labelText: '消費カロリー (kcal、任意)',
                  hintText: '例: 150',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'メモ (任意)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (durationController.text.isNotEmpty && typeController.text.isNotEmpty) {
                try {
                  final duration = double.parse(durationController.text);
                  final type = typeController.text;
                  final calories = caloriesController.text.isEmpty ? null : double.parse(caloriesController.text);
                  final notes = notesController.text.isEmpty ? null : notesController.text;
                  
                  // ユーザーIDを取得
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('user_id');
                  
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ユーザーIDが見つかりません。再ログインしてください。')),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  
                  // 認証トークンを取得
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final token = authProvider.token;
                  
                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('認証トークンが見つかりません。再ログインしてください。')),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  
                  // 運動記録を作成
                  final record = ExerciseRecord(
                    date: selectedDate,
                    exerciseType: type,
                    duration: duration,
                    calories: calories,
                    notes: notes,
                  );
                  
                  // プロバイダーを通じてAPIに送信
                  final healthDataProvider = Provider.of<HealthDataProvider>(context, listen: false);
                  await healthDataProvider.addExerciseRecord(token, record);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('運動記録を追加しました')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('エラーが発生しました: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('運動の種類と時間を入力してください')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
