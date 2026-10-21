import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_settings.dart';
import 'models/transactions_model.dart';
import 'widgets/month_selector.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  static const colors = [
    Color(0xFF2E7D60),
    Color(0xFF407FC1),
    Color(0xFFE8A838),
    Color(0xFFC75665),
    Color(0xFF8462B6),
    Color(0xFF298B94),
    Color(0xFFB76F3B),
    Color(0xFF697687),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    final entries =
        context
            .watch<TransactionsModel>()
            .expensesByCategory(_month)
            .entries
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (sum, item) => sum + item.value);
    return Scaffold(
      appBar: AppBar(title: Text(s.text('Expense statistics'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          MonthSelector(
            month: _month,
            onChanged: (month) => setState(() => _month = month),
          ),
          const SizedBox(height: 24),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(s.text('No expenses this month'))),
            )
          else ...[
            Semantics(
              label: '${s.text('Expenses')}: ${s.formatMoney(total)}',
              child: Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: CustomPaint(
                    painter: _PiePainter(
                      entries.map((e) => e.value).toList(),
                      colors,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(52),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(s.text('Expenses')),
                            FittedBox(
                              child: Text(
                                s.formatMoney(total),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...entries.asMap().entries.map((entry) {
              final item = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colors[entry.key % colors.length],
                  radius: 8,
                ),
                title: Text(s.text(item.key)),
                subtitle: Text(s.formatMoney(item.value)),
                trailing: Text(
                  '${(item.value / total * 100).toStringAsFixed(1)}%',
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.values, this.colors);
  final List<double> values;
  final List<Color> colors;
  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return;
    final rect = (Offset.zero & size).deflate(18);
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 32,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => true;
}
