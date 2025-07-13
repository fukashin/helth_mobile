import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
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
    return Card(
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
          ],
        ),
      ),
    );
  }

  // 個別のデータ取得メソッドは不要になったため削除
}
