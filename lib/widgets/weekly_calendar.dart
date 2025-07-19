import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 週間カレンダーウィジェット
///
/// 現在の週の日付を表示し、日付の選択機能を提供します。
/// 前の週・次の週への移動機能も備えています。
/// アニメーション付きで左右にスライドし、選択された日付もアニメーションします。
class WeeklyCalendar extends StatefulWidget {
  /// 日付が選択されたときに呼び出されるコールバック関数
  final Function(DateTime) onDateSelected;

  /// 初期選択日（指定がない場合は現在の日付が使用される）
  final DateTime? initialSelectedDate;

  const WeeklyCalendar({
    Key? key,
    required this.onDateSelected,
    this.initialSelectedDate,
  }) : super(key: key);

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar>
    with TickerProviderStateMixin {
  /// 現在表示中の日付
  late DateTime _currentDate;

  /// 選択されている日付
  late DateTime _selectedDate;

  /// 表示する週の7日間（月曜日から日曜日）のリスト
  late List<List<DateTime>> _weeksList;

  /// PageViewコントローラー
  late PageController _pageController;

  /// 週切り替えアニメーションコントローラー
  late AnimationController _weekAnimationController;

  /// 日付選択アニメーションコントローラー
  late AnimationController _dateSelectionController;

  /// 選択位置のアニメーション
  late Animation<double> _selectionPositionAnimation;

  /// 現在のページインデックス
  int _currentPageIndex = 1; // 中央のページから開始

  /// アニメーション中かどうか
  bool _isAnimating = false;

  /// 選択された日付のインデックス（0-6）
  int _selectedDateIndex = 0;

  /// ウィジェットの初期化
  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = widget.initialSelectedDate ?? _currentDate;

    // PageViewコントローラーを初期化
    _pageController = PageController(initialPage: _currentPageIndex);

    // 週切り替えアニメーションコントローラーを初期化
    _weekAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 日付選択アニメーションコントローラーを初期化
    _dateSelectionController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _generateWeeksList();
    _updateSelectedDateIndex();

    // 選択位置のアニメーションを初期化
    _selectionPositionAnimation =
        Tween<double>(
          begin: _selectedDateIndex.toDouble(),
          end: _selectedDateIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _dateSelectionController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _weekAnimationController.dispose();
    _dateSelectionController.dispose();
    super.dispose();
  }

  /// 3週間分の週データを生成するメソッド
  ///
  /// 前週、今週、次週の3つの週を生成します。
  void _generateWeeksList() {
    _weeksList = [];

    // 前週
    final previousWeek = _generateWeekDays(
      _currentDate.subtract(const Duration(days: 7)),
    );
    _weeksList.add(previousWeek);

    // 今週
    final currentWeek = _generateWeekDays(_currentDate);
    _weeksList.add(currentWeek);

    // 次週
    final nextWeek = _generateWeekDays(
      _currentDate.add(const Duration(days: 7)),
    );
    _weeksList.add(nextWeek);
  }

  /// 指定された日付から週の日付を生成するメソッド
  ///
  /// [date] 基準となる日付
  ///
  /// 月曜日から日曜日までの7日間のリストを返します。
  List<DateTime> _generateWeekDays(DateTime date) {
    final int weekday = date.weekday;
    final DateTime monday = date.subtract(Duration(days: weekday - 1));

    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  /// 選択された日付のインデックスを更新するメソッド
  void _updateSelectedDateIndex() {
    final currentWeek = _weeksList[1]; // 現在表示中の週
    for (int i = 0; i < currentWeek.length; i++) {
      final date = currentWeek[i];
      if (date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day) {
        _selectedDateIndex = i;
        break;
      }
    }
  }

  /// 日付を選択するメソッド
  ///
  /// 選択された日付を更新し、親ウィジェットに通知します。
  /// アニメーション付きで選択位置を移動します。
  ///
  /// [date] 選択された日付
  /// [index] 選択された日付のインデックス
  void _selectDate(DateTime date, int index) {
    if (_isAnimating || _dateSelectionController.isAnimating) return;

    final oldIndex = _selectedDateIndex;

    if (oldIndex != index) {
      setState(() {
        _selectedDate = date;
        _selectedDateIndex = index;

        // アニメーションの更新をsetState内で行う
        _selectionPositionAnimation =
            Tween<double>(
              begin: oldIndex.toDouble(),
              end: index.toDouble(),
            ).animate(
              CurvedAnimation(
                parent: _dateSelectionController,
                curve: Curves.easeInOut,
              ),
            );
      });

      _dateSelectionController.forward(from: 0.0);
    } else {
      setState(() {
        _selectedDate = date;
      });
    }

    widget.onDateSelected(date);
  }

  /// 前の週に移動するメソッド
  ///
  /// アニメーション付きで前の週に移動します。
  void _previousWeek() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    _weekAnimationController.forward().then((_) {
      setState(() {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
        _generateWeeksList();
        _updateSelectedDateIndex();
        _isAnimating = false;
      });
      _weekAnimationController.reset();

      // 選択位置のアニメーションをリセット
      _selectionPositionAnimation = Tween<double>(
        begin: _selectedDateIndex.toDouble(),
        end: _selectedDateIndex.toDouble(),
      ).animate(_dateSelectionController);

      // PageViewを前のページに移動
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  /// 次の週に移動するメソッド
  ///
  /// アニメーション付きで次の週に移動します。
  void _nextWeek() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    _weekAnimationController.forward().then((_) {
      setState(() {
        _currentDate = _currentDate.add(const Duration(days: 7));
        _generateWeeksList();
        _updateSelectedDateIndex();
        _isAnimating = false;
      });
      _weekAnimationController.reset();

      // 選択位置のアニメーションをリセット
      _selectionPositionAnimation = Tween<double>(
        begin: _selectedDateIndex.toDouble(),
        end: _selectedDateIndex.toDouble(),
      ).animate(_dateSelectionController);

      // PageViewを次のページに移動
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  /// 表示している週の月と年を取得するメソッド
  ///
  /// 「yyyy年M月」形式で月と年を返します。
  String _getMonthYear() {
    final DateFormat formatter = DateFormat('yyyy年M月');
    return formatter.format(_currentDate);
  }

  /// 週の日付表示部分を構築するメソッド
  ///
  /// [weekDays] 表示する週の日付リスト
  ///
  /// カレンダーを7等分し、各セクションの中心に日付を配置します。
  /// これにより、どのデバイスサイズでも正確な位置にアニメーションします。
  Widget _buildWeekDays(List<DateTime> weekDays) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final itemWidth = availableWidth / 7; // 7等分
        final selectorWidth = 40.0;

        return Stack(
          children: [
            // 選択された日付の背景（アニメーション）
            AnimatedBuilder(
              animation: _selectionPositionAnimation,
              builder: (context, child) {
                // 各セクションの中心位置を計算
                final centerX =
                    (_selectionPositionAnimation.value * itemWidth) +
                    (itemWidth / 2);
                final left = centerX - (selectorWidth / 2);

                return Positioned(
                  left: left,
                  top: 0,
                  child: Container(
                    width: selectorWidth,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
            // 日付を7等分のセクションに配置
            Row(
              children: List.generate(7, (index) {
                final date = weekDays[index];
                final isToday =
                    date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
                final isSelected =
                    date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;

                // 曜日の日本語表記（月曜日から日曜日）
                final weekdayJp = ['月', '火', '水', '木', '金', '土', '日'][index];

                return SizedBox(
                  width: itemWidth, // 各セクションの幅を7等分
                  height: 60,
                  child: GestureDetector(
                    onTap: () => _selectDate(date, index),
                    child: Container(
                      width: itemWidth,
                      height: 60,
                      color: Colors.transparent,
                      child: Center(
                        // 各セクションの中心に配置
                        child: Container(
                          width: selectorWidth,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                weekdayJp,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              if (isToday && !isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 24,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '今日',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  /// ウィジェットの構築
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 月表示と前後の週に移動するボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: _isAnimating ? null : _previousWeek,
                ),
                AnimatedBuilder(
                  animation: _weekAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 - (_weekAnimationController.value * 0.1),
                      child: Opacity(
                        opacity: 1.0 - (_weekAnimationController.value * 0.3),
                        child: Text(
                          _getMonthYear(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: _isAnimating ? null : _nextWeek,
                ),
              ],
            ),
          ),
          // 曜日と日付の表示（PageView使用）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SizedBox(
              height: 60,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  // ページが変更されたときの処理
                  if (index == 0) {
                    // 前のページに移動した場合、データを更新
                    setState(() {
                      _currentDate = _currentDate.subtract(
                        const Duration(days: 7),
                      );
                      _generateWeeksList();
                      _updateSelectedDateIndex();
                      _currentPageIndex = 1;
                    });
                    _pageController.jumpToPage(1);
                  } else if (index == 2) {
                    // 次のページに移動した場合、データを更新
                    setState(() {
                      _currentDate = _currentDate.add(const Duration(days: 7));
                      _generateWeeksList();
                      _updateSelectedDateIndex();
                      _currentPageIndex = 1;
                    });
                    _pageController.jumpToPage(1);
                  }
                },
                itemCount: _weeksList.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _weekAnimationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _weekAnimationController.value * 10),
                        child: Opacity(
                          opacity: 1.0 - (_weekAnimationController.value * 0.2),
                          child: _buildWeekDays(_weeksList[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // アドバイスボタン
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wb_sunny, color: Colors.white),
                const SizedBox(width: 8),
                const Icon(Icons.wb_sunny_outlined, color: Colors.white),
                const SizedBox(width: 8),
                const Icon(Icons.nightlight, color: Colors.white),
                const SizedBox(width: 16),
                const Text(
                  'アドバイス',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
