import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'app_settings.dart';
import 'add_transaction_screen.dart';
import 'models/transaction.dart';
import 'models/transactions_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _query = TextEditingController();
  String? _category;
  DateTimeRange? _range;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _action(Transaction item, String action) async {
    final model = context.read<TransactionsModel>();
    final s = AppSettings.of(context);
    try {
      if (action == 'edit') {
        final edited = await Navigator.push<Transaction>(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(transaction: item),
          ),
        );
        if (edited != null) await model.update(item, edited);
      } else {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(s.text('Delete transaction?')),
            content: Text(item.title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(s.text('Cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(s.text('Delete')),
              ),
            ],
          ),
        );
        if (confirmed == true) await model.remove(item);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.text('Could not save. Please try again.'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    final model = context.watch<TransactionsModel>();
    final categories =
        model.transactions.map((item) => item.category).toSet().toList()
          ..sort();
    final selected = categories.contains(_category) ? _category : null;
    final items = model.search(
      query: _query.text,
      category: selected,
      from: _range?.start,
      to: _range?.end,
    );
    final dates = DateFormat.yMd(s.languageCode);
    return Scaffold(
      appBar: AppBar(title: Text(s.text('Transaction history'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
                TextField(
                  key: const ValueKey('history-search'),
                  controller: _query,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: s.text('Search by title'),
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey('history-category-$selected'),
                  initialValue: selected ?? '',
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: s.text('Category'),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(s.text('All categories')),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(s.text(category)),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _category = value == '' ? null : value),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _range == null
                            ? s.text('Date range')
                            : '${dates.format(_range!.start)} – ${dates.format(_range!.end)}',
                      ),
                      onPressed: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDateRange: _range,
                        );
                        if (mounted && range != null) {
                          setState(() => _range = range);
                        }
                      },
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _query.clear();
                        _category = null;
                        _range = null;
                      }),
                      child: Text(s.text('Reset filters')),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${s.text('Transactions')}: ${items.length}'),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text(s.text('No matching transactions')))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    item.isIncome
                                        ? Icons.south_west
                                        : Icons.north_east,
                                    color: item.isIncome
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    tooltip: s.text('Transaction actions'),
                                    onSelected: (action) =>
                                        _action(item, action),
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(s.text('Edit')),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(s.text('Delete')),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '${s.text(item.category)} · ${dates.format(item.date)} ${DateFormat.Hm(s.languageCode).format(item.date)}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${item.isIncome ? '+' : '−'}${s.formatMoney(item.amount)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: item.isIncome
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
