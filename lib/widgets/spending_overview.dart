import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../app_settings.dart';
import '../models/transactions_model.dart';

/// A monthly summary derived entirely from the user's saved transactions.
class SpendingOverview extends StatelessWidget {
  const SpendingOverview({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final entries =
        context
            .watch<TransactionsModel>()
            .expensesByCategory(DateTime(now.year, now.month))
            .entries
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (sum, entry) => sum + entry.value);
    final palette = [
      colors.primary,
      const Color(0xFFFFA88D),
      const Color(0xFF77C9B2),
      const Color(0xFFB8A2E3),
    ];
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      s.text('Spending overview'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: colors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat.yMMMM(s.languageCode).format(now),
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 20),
              if (entries.isEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.donut_large_rounded,
                      color: colors.primary,
                      size: 36,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        s.text('No expenses this month'),
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ],
                )
              else ...[
                Text(
                  s.formatMoney(total),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 12,
                    child: Row(
                      children: [
                        for (var i = 0; i < entries.length; i++)
                          Expanded(
                            flex: ((entries[i].value / total) * 10000)
                                .round()
                                .clamp(1, 10000),
                            child: ColoredBox(
                              color: palette[i % palette.length],
                              child: const SizedBox.expand(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                for (var i = 0; i < entries.length && i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: palette[i],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(child: Text(s.text(entries[i].key))),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            s.formatMoney(entries[i].value),
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
