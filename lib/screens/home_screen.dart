import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/health_data_provider.dart';
import '../widgets/weekly_calendar.dart';
import '../widgets/daily_health_data.dart';
import '../services/api_service.dart';

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
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthDataProvider, child) {
        if (healthDataProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 挨拶
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
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
              ),

              // 週間カレンダー
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: WeeklyCalendar(
                  onDateSelected: _onDateSelected,
                  initialSelectedDate: _selectedDate,
                ),
              ),
              
              // 選択された日付のデータ表示
              DailyHealthData(selectedDate: _selectedDate),
              
              // 今日の記録サマリー
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日の記録サマリー',
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

// プロフィールタブ
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  
  // プロフィール情報
  String _name = '';
  String _nickname = '';
  double _height = 0.0;
  double _weight = 0.0;
  String _goal = '';
  
  // プロフィール読み込み中フラグ
  bool _isLoading = true;
  
  // プロフィール更新中フラグ
  bool _isUpdating = false;
  
  // エラーメッセージ
  String? _errorMessage;
  
  // 成功メッセージ
  String? _successMessage;
  
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  
  // プロフィール情報を読み込む
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token == null || authProvider.userId == null) {
        setState(() {
          _errorMessage = 'ログインが必要です';
          _isLoading = false;
        });
        return;
      }
      
      final apiService = ApiService();
      final profileData = await apiService.getUserProfileDetails(
        authProvider.token!,
        authProvider.userId!,
      );
      
      setState(() {
        _name = profileData['name'] ?? '';
        _nickname = profileData['nickname'] ?? '';
        _height = (profileData['height'] ?? 0.0).toDouble();
        _weight = (profileData['weight'] ?? 0.0).toDouble();
        _goal = profileData['goal'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'プロフィール情報の取得に失敗しました: $e';
        _isLoading = false;
      });
    }
  }
  
  // プロフィール情報を更新する
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isUpdating = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token == null || authProvider.userId == null) {
        setState(() {
          _errorMessage = 'ログインが必要です';
          _isUpdating = false;
        });
        return;
      }
      
      final apiService = ApiService();
      await apiService.updateUserProfile(
        authProvider.token!,
        authProvider.userId!,
        {
          'name': _name,
          'nickname': _nickname,
          'height': _height,
          'weight': _weight,
          'goal': _goal,
        },
      );
      
      setState(() {
        _successMessage = 'プロフィールを更新しました';
        _isUpdating = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'プロフィールの更新に失敗しました: $e';
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部分
              Center(
                child: Column(
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              
              // 読み込み中表示
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
                
              // エラーメッセージ
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
                
              // 成功メッセージ
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green.shade900),
                  ),
                ),
              
              // プロフィール編集フォーム
              if (!_isLoading)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'プロフィール編集',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // 名前
                          TextFormField(
                            initialValue: _name,
                            decoration: const InputDecoration(
                              labelText: '名前',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '名前を入力してください';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _name = value ?? '';
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // ニックネーム
                          TextFormField(
                            initialValue: _nickname,
                            decoration: const InputDecoration(
                              labelText: 'ニックネーム',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.face),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ニックネームを入力してください';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _nickname = value ?? '';
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // 身長
                          TextFormField(
                            initialValue: _height > 0 ? _height.toString() : '',
                            decoration: const InputDecoration(
                              labelText: '身長 (cm)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.height),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '身長を入力してください';
                              }
                              if (double.tryParse(value) == null) {
                                return '数値を入力してください';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _height = double.tryParse(value ?? '0') ?? 0.0;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // 体重
                          TextFormField(
                            initialValue: _weight > 0 ? _weight.toString() : '',
                            decoration: const InputDecoration(
                              labelText: '体重 (kg)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monitor_weight),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '体重を入力してください';
                              }
                              if (double.tryParse(value) == null) {
                                return '数値を入力してください';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _weight = double.tryParse(value ?? '0') ?? 0.0;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // 目標
                          TextFormField(
                            initialValue: _goal,
                            decoration: const InputDecoration(
                              labelText: '目標',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.flag),
                            ),
                            maxLines: 3,
                            onSaved: (value) {
                              _goal = value ?? '';
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // メールアドレス（変更不可）
                          TextFormField(
                            initialValue: authProvider.user?['email'] ?? '',
                            decoration: const InputDecoration(
                              labelText: 'メールアドレス（変更不可）',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                              filled: true,
                              fillColor: Color(0xFFEEEEEE),
                            ),
                            enabled: false,
                          ),
                          const SizedBox(height: 24),
                          
                          // 更新ボタン
                          Center(
                            child: ElevatedButton(
                              onPressed: _isUpdating ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                              ),
                              child: _isUpdating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('プロフィールを更新'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
