import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/health_data_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthDataProvider = Provider.of<HealthDataProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      try {
        await healthDataProvider.loadHealthData(authProvider.token!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('データの読み込みに失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康管理アプリ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await authProvider.logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('ログアウト'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DashboardTab(),
          RecordsTab(),
          StatisticsTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'ダッシュボード',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '記録',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '統計',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
}

// ダッシュボードタブ
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthDataProvider, child) {
        if (healthDataProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 挨拶
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.health_and_safety,
                        size: 40,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return Text(
                                  'こんにちは、${authProvider.user?['name'] ?? 'ユーザー'}さん',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const Text(
                              '今日も健康管理を頑張りましょう！',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 今日の記録サマリー
              const Text(
                '今日の記録',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildSummaryCard(
                    '摂取カロリー',
                    '${_getTodayCalories(healthDataProvider.calorieRecords)} kcal',
                    Icons.restaurant,
                    Colors.orange,
                  ),
                  _buildSummaryCard(
                    '体重',
                    '${_getLatestWeight(healthDataProvider.weightRecords)} kg',
                    Icons.monitor_weight,
                    Colors.green,
                  ),
                  _buildSummaryCard(
                    '睡眠時間',
                    '${_getTodaySleep(healthDataProvider.sleepRecords)} 時間',
                    Icons.bedtime,
                    Colors.purple,
                  ),
                  _buildSummaryCard(
                    '運動時間',
                    '${_getTodayExercise(healthDataProvider.exerciseRecords)} 分',
                    Icons.fitness_center,
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double _getTodayCalories(List calorieRecords) {
    final today = DateTime.now();
    final todayRecords = calorieRecords.where((record) {
      return record.date.year == today.year &&
             record.date.month == today.month &&
             record.date.day == today.day;
    });
    return todayRecords.fold(0.0, (sum, record) => sum + record.calories);
  }

  double _getLatestWeight(List weightRecords) {
    if (weightRecords.isEmpty) return 0.0;
    weightRecords.sort((a, b) => b.date.compareTo(a.date));
    return weightRecords.first.weight;
  }

  double _getTodaySleep(List sleepRecords) {
    final today = DateTime.now();
    final todayRecord = sleepRecords.where((record) {
      return record.date.year == today.year &&
             record.date.month == today.month &&
             record.date.day == today.day;
    });
    return todayRecord.isNotEmpty ? todayRecord.first.hours : 0.0;
  }

  double _getTodayExercise(List exerciseRecords) {
    final today = DateTime.now();
    final todayRecords = exerciseRecords.where((record) {
      return record.date.year == today.year &&
             record.date.month == today.month &&
             record.date.day == today.day;
    });
    return todayRecords.fold(0.0, (sum, record) => sum + record.duration);
  }
}

// 記録タブ（プレースホルダー）
class RecordsTab extends StatelessWidget {
  const RecordsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '記録機能は今後実装予定です',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

// 統計タブ（プレースホルダー）
class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '統計機能は今後実装予定です',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

// プロフィールタブ（プレースホルダー）
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                authProvider.user?['name'] ?? 'ユーザー',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                authProvider.user?['email'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'プロフィール編集機能は今後実装予定です',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
