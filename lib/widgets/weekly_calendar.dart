import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 週間カレンダーウィジェット
///
/// 現在の週の日付を表示し、日付の選択機能を提供します。
/// 前の週・次の週への移動機能も備えています。
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

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  /// 現在表示中の日付
  late DateTime _currentDate;

  /// 選択されている日付
  late DateTime _selectedDate;

  /// 表示する週の7日間（月曜日から日曜日）
  late List<DateTime> _weekDays;

  /// ウィジェットの初期化
  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = widget.initialSelectedDate ?? _currentDate;
    _generateWeekDays();
  }

  /// 表示する週の日付を生成するメソッド
  ///
  /// 現在の日付から週の初め（月曜日）を計算し、
  /// 月曜日から日曜日までの7日間のリストを生成します。
  void _generateWeekDays() {
    // 現在の日付から週の初め（月曜日）を計算
    final now = _currentDate;
    final int weekday = now.weekday;
    final DateTime monday = now.subtract(Duration(days: weekday - 1));

    // 月曜日から日曜日までの7日間を生成
    _weekDays = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  /// 日付を選択するメソッド
  ///
  /// 選択された日付を更新し、親ウィジェットに通知します。
  ///
  /// [date] 選択された日付
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected(date);
  }

  /// 前の週に移動するメソッド
  ///
  /// 現在の日付を7日前に移動し、週の日付を再生成します。
  void _previousWeek() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 7));
      _generateWeekDays();
    });
  }

  /// 次の週に移動するメソッド
  ///
  /// 現在の日付を7日後に移動し、週の日付を再生成します。
  void _nextWeek() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 7));
      _generateWeekDays();
    });
  }

  /// 表示している週の月と年を取得するメソッド
  ///
  /// 「yyyy年M月」形式で月と年を返します。
  String _getMonthYear() {
    // 表示している週の月と年を取得
    final DateFormat formatter = DateFormat('yyyy年M月');
    return formatter.format(_currentDate);
  }

  /// ウィジェットの構築
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 月表示と前後の週に移動するボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _previousWeek,
                  tooltip: '前の週',
                ),
                Text(
                  _getMonthYear(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _nextWeek,
                  tooltip: '次の週',
                ),
              ],
            ),
          ),
          // 曜日と日付の表示
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final date = _weekDays[index];
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

                // 土日の色分け
                final isWeekend = index == 5 || index == 6; // 土曜日または日曜日
                final weekdayColor = isWeekend
                    ? Colors.red.shade300
                    : Colors.white;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(date),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      height: 70,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.green
                                  : isToday
                                  ? Colors.white
                                  : Colors.white,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weekdayJp,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.green
                                  : isToday
                                  ? Colors.white
                                  : weekdayColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isToday && !isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // アドバイスボタン
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wb_sunny, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.nightlight, color: Colors.white, size: 20),
                const SizedBox(width: 16),
                const Text(
                  'アドバイス',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
