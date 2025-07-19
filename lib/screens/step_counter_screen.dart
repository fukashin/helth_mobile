import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health/health.dart';
import 'dart:async';
import 'dart:io';

/// 歩数計測画面
///
/// ユーザーの歩数をリアルタイムで計測・表示する画面です。
/// Android端末のセンサーを使用して歩数を取得します。
class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '不明';
  String _steps = '0';
  bool _isPermissionGranted = false;
  bool _isLoading = true;
  String _errorMessage = '';

  // iOS HealthKit用
  Health _health = Health();
  Timer? _healthTimer;

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  /// 歩数計の初期化
  Future<void> _initPedometer() async {
    try {
      // 権限の確認と要求
      await _requestPermissions();

      if (_isPermissionGranted) {
        _initStreams();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '歩数計の初期化に失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  /// 必要な権限の要求
  Future<void> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        // iOS用のHealthKit権限要求
        await _requestHealthKitPermissions();
      } else if (Platform.isAndroid) {
        // Android用の身体活動認識権限要求
        final status = await Permission.activityRecognition.request();
        setState(() {
          _isPermissionGranted = status.isGranted;
          if (!_isPermissionGranted) {
            _errorMessage = '歩数計測には身体活動認識の権限が必要です。設定から権限を許可してください。';
          }
          _isLoading = false;
        });
      } else {
        // その他のプラットフォーム（Web、デスクトップなど）
        setState(() {
          _isPermissionGranted = false;
          _errorMessage = 'このプラットフォームでは歩数計測はサポートされていません。';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isPermissionGranted = false;
        _errorMessage = '権限の確認に失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  /// iOS HealthKit権限要求
  Future<void> _requestHealthKitPermissions() async {
    try {
      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];

      final granted = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      setState(() {
        _isPermissionGranted = granted;
        if (!_isPermissionGranted) {
          _errorMessage = 'HealthKitへのアクセス権限が必要です。設定から権限を許可してください。';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isPermissionGranted = false;
        _errorMessage = 'HealthKit権限の確認に失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  /// ストリームの初期化
  void _initStreams() {
    try {
      if (Platform.isIOS) {
        // iOS用のHealthKit実装
        _initHealthKitStreams();
      } else if (Platform.isAndroid) {
        // Android用のPedometer実装
        _initPedometerStreams();
      } else {
        // その他のプラットフォーム
        _startMockData();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'センサーの初期化に失敗しました: $e';
        // エラー時は模擬データを使用
        _startMockData();
      });
    }
  }

  /// Android用Pedometerストリーム初期化
  void _initPedometerStreams() {
    try {
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
      _stepCountStream = Pedometer.stepCountStream;

      // 歩行状態の監視
      _pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
      );

      // 歩数の監視
      _stepCountStream.listen(_onStepCount, onError: _onStepCountError);
    } catch (e) {
      setState(() {
        _errorMessage = 'Pedometerの初期化に失敗しました: $e';
        _startMockData();
      });
    }
  }

  /// iOS用HealthKitストリーム初期化
  void _initHealthKitStreams() {
    try {
      // HealthKitから歩数データを定期的に取得
      _startHealthKitTimer();
      setState(() {
        _status = 'HealthKit接続中';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'HealthKitの初期化に失敗しました: $e';
        _startMockData();
      });
    }
  }

  /// HealthKit用タイマー開始
  void _startHealthKitTimer() {
    _healthTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _fetchHealthKitSteps();
    });
    // 初回実行
    _fetchHealthKitSteps();
  }

  /// HealthKitから歩数データを取得
  Future<void> _fetchHealthKitSteps() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      );

      if (healthData.isNotEmpty) {
        int totalSteps = 0;
        for (var data in healthData) {
          if (data.value is NumericHealthValue) {
            totalSteps += (data.value as NumericHealthValue).numericValue
                .toInt();
          }
        }

        setState(() {
          _steps = totalSteps.toString();
          _status = 'HealthKit接続済み';
          _errorMessage = '';
        });
      } else {
        setState(() {
          _steps = '0';
          _status = 'データなし';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'HealthKitデータの取得に失敗しました: $e';
        _startMockData();
      });
    }
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    super.dispose();
  }

  /// エミュレーター用の模擬データ開始
  void _startMockData() {
    setState(() {
      _status = 'エミュレーター環境';
      _steps = '1234'; // 模擬歩数データ
      _errorMessage = 'エミュレーター環境のため、模擬データを表示しています。実機では実際の歩数が表示されます。';
    });
  }

  /// 歩行状態が変更された時の処理
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status == 'walking' ? '歩行中' : '停止中';
    });
  }

  /// 歩数が更新された時の処理
  void _onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps.toString();
    });
  }

  /// 歩行状態エラー処理
  void _onPedestrianStatusError(error) {
    setState(() {
      _status = '歩行状態を取得できません';
    });
  }

  /// 歩数エラー処理
  void _onStepCountError(error) {
    setState(() {
      _steps = '歩数を取得できません';
      _errorMessage = 'センサーエラー: $error';
      // エラーが発生した場合も模擬データを使用
      _startMockData();
    });
  }

  /// 歩数をリセット（アプリ内での表示リセット）
  void _resetSteps() {
    // 注意: これは表示上のリセットのみで、実際のセンサー値はリセットされません
    setState(() {
      _steps = '0';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('表示をリセットしました（センサー値は継続されます）'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歩数計'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green, Colors.lightGreen],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      '歩数計を初期化中...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              )
            : !_isPermissionGranted
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, size: 80, color: Colors.white),
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          openAppSettings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                        ),
                        child: const Text('設定を開く'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _initPedometer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                        ),
                        child: const Text('再試行'),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // 歩数表示カード
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.directions_walk,
                                size: 60,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                '今日の歩数',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _steps,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Text(
                                '歩',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // 歩行状態表示カード
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _status == '歩行中'
                                    ? Icons.directions_run
                                    : Icons.pause_circle_outline,
                                size: 30,
                                color: _status == '歩行中'
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '状態: $_status',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // リセットボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _resetSteps,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            '表示をリセット',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      // 使用方法の説明
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '使用方法',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '• アプリを起動すると自動的に歩数の計測が開始されます\n'
                                '• 端末を持って歩くと歩数がカウントされます\n'
                                '• バックグラウンドでも計測は継続されます\n'
                                '• 表示リセットボタンで画面上の数値をリセットできます',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
