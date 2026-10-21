import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_settings.dart';
import 'models/budget_model.dart';
import 'models/transactions_model.dart';
import 'widgets/month_selector.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  final _amount = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final s = AppSettings.of(context);
    try {
      await context.read<BudgetModel>().setLimit(
        _month,
        double.parse(_amount.text.trim().replaceAll(',', '.')),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(s.text('Budget saved'))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.text('Could not save. Please try again.'))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    final limit = context.watch<BudgetModel>().limitFor(_month);
    final spent = context.watch<TransactionsModel>().expensesFor(_month);
    final remaining = (limit ?? 0) - spent;
    return Scaffold(
      appBar: AppBar(title: Text(s.text('Monthly budget'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          IgnorePointer(
            ignoring: _saving,
            child: MonthSelector(
              month: _month,
              onChanged: (month) => setState(() {
                _month = month;
                _amount.clear();
                _form.currentState?.reset();
              }),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.text('Spent this month')),
                  Text(
                    s.formatMoney(spent),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  if (limit == null)
                    Text(s.text('Set a budget for this month'))
                  else ...[
                    Text(
                      '${s.text('Spending limit')}: ${s.formatMoney(limit)}',
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (spent / limit).clamp(0.0, 1.0),
                      color: remaining < 0
                          ? Theme.of(context).colorScheme.error
                          : null,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.text(remaining < 0 ? 'Over budget' : 'Remaining'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      s.formatMoney(remaining.abs()),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: remaining < 0
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _form,
            child: TextFormField(
              key: const ValueKey('budget-limit'),
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: s.text('Spending limit'),
                hintText: limit?.toStringAsFixed(2),
                prefixText: '${s.currencySymbol} ',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final amount = double.tryParse(
                  (value ?? '').trim().replaceAll(',', '.'),
                );
                return amount == null || !amount.isFinite || amount <= 0
                    ? s.text('Enter a positive amount')
                    : null;
              },
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(s.text('Save budget')),
          ),
        ],
      ),
    );
  }
}
