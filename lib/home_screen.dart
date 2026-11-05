import 'app_theme.dart';
import 'widgets/spending_overview.dart';
import 'widgets/coin_mascot.dart';
import 'history_screen.dart';
import 'statistics_screen.dart';
import 'budget_screen.dart';
import 'profile_screen.dart';
import 'models/budget_model.dart';
import 'package:flutter/material.dart';
import 'registration_screen.dart';
import 'add_transaction_screen.dart';
import 'models/transaction.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'app_settings.dart';
import 'models/transactions_model.dart';
import 'models/user_model.dart';
import 'models/settings_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _savingVisibility = false;

  Future<void> _toggleAmounts() async {
    if (_savingVisibility) return;
    setState(() => _savingVisibility = true);
    final preferences = context.read<SettingsModel>();
    try {
      await preferences.setHideAmounts(!preferences.hideAmounts);
    } catch (_) {
      _showSaveError();
    } finally {
      if (mounted) setState(() => _savingVisibility = false);
    }
  }

  int _selectedIndex = 0;
  final _visitedTabs = <int>{0};

  void _selectTab(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _selectedIndex = index;
      _visitedTabs.add(index);
    });
  }

  Future<void> _openRegistration() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
    );
  }

  Future<void> _addTransaction() async {
    final transaction = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    if (!mounted) return;
    if (transaction != null) {
      try {
        await context.read<TransactionsModel>().add(transaction);
      } catch (_) {
        _showSaveError();
      }
    }
  }

  void _showSaveError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppSettings.of(context).text('Could not save. Please try again.'),
        ),
      ),
    );
  }

  Future<void> _editTransaction(Transaction original) async {
    final replacement = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(transaction: original),
      ),
    );
    if (!mounted || replacement == null) return;
    try {
      await context.read<TransactionsModel>().update(original, replacement);
    } catch (_) {
      _showSaveError();
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final settings = AppSettings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.text('Delete transaction?')),
        content: Text(transaction.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(settings.text('Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(settings.text('Delete')),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      await context.read<TransactionsModel>().remove(transaction);
    } catch (_) {
      _showSaveError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final finances = context.watch<TransactionsModel>();
    final transactions = finances.transactions.take(5).toList();
    final settings = AppSettings.of(context);
    final colors = Theme.of(context).colorScheme;
    final userName = ScopedModel.of<UserModel>(
      context,
      rebuildOnChange: true,
    ).name;
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final limit = context.watch<BudgetModel>().limitFor(month);
    final spent = finances.expensesFor(month);

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) _selectTab(0);
      },
      child: Scaffold(
        appBar: _selectedIndex != 0
            ? null
            : AppBar(
                toolbarHeight: 64,
                title: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: colors.onPrimary,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('MoneyMate'),
                      ),
                    ),
                  ],
                ),
              ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.greeting(userName),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        settings.text('Your money, at a glance'),
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF241742),
                              AppTheme.violet,
                              Color(0xFF8B5CEB),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.violet.withValues(alpha: 0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    settings.text('Total Balance'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                IconButton.filledTonal(
                                  key: const ValueKey(
                                    'toggle-amount-visibility',
                                  ),
                                  tooltip: settings.text(
                                    settings.hideAmounts
                                        ? 'Show amounts'
                                        : 'Hide amounts',
                                  ),
                                  onPressed: _savingVisibility
                                      ? null
                                      : _toggleAmounts,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.12,
                                    ),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(48, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: Icon(
                                    settings.hideAmounts
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                settings.formatMoney(finances.balance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 7,
                                  color: AppTheme.coral,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    settings.text('Current balance'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'MONEY / MATE',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _moneyCard(
                              title: settings.text('Income'),
                              amount: settings.formatMoney(
                                finances.totalIncome,
                              ),
                              icon: Icons.south_west_rounded,
                              color: AppTheme.income(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _moneyCard(
                              title: settings.text('Expenses'),
                              amount: settings.formatMoney(
                                finances.totalExpenses,
                              ),
                              icon: Icons.north_east_rounded,
                              color: AppTheme.expense(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => _selectTab(3),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.savings_outlined,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        settings.text('Monthly budget'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  limit == null
                                      ? settings.text(
                                          'Set a budget for this month',
                                        )
                                      : '${settings.text(spent > limit ? 'Over budget' : 'Remaining')}: ${settings.formatMoney((limit - spent).abs())}',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                if (limit != null) ...[
                                  const SizedBox(height: 14),
                                  LinearProgressIndicator(
                                    value: (spent / limit).clamp(0.0, 1.0),
                                    minHeight: 7,
                                    borderRadius: BorderRadius.circular(8),
                                    color: spent > limit
                                        ? colors.error
                                        : colors.primary,
                                    backgroundColor:
                                        colors.surfaceContainerHighest,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SpendingOverview(onTap: () => _selectTab(2)),
                      const SizedBox(height: 26),
                      Text(
                        settings.text('Recent Transactions'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => _selectTab(1),
                          child: Text(settings.text('View all transactions')),
                        ),
                      ),
                      if (transactions.isEmpty)
                        Card(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                const CoinMascot(size: 72),
                                const SizedBox(height: 16),
                                Text(
                                  settings.text('No transactions yet'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  settings.text(
                                    'Tap + to add your first transaction',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        for (final transaction in transactions)
                          _transactionItem(transaction),
                      if (userName == null) ...[
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: _openRegistration,
                          icon: const Icon(Icons.person_add_outlined),
                          label: Text(settings.text('Create a profile')),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _visitedTabs.contains(1)
                ? const HistoryScreen()
                : const SizedBox.shrink(),
            _visitedTabs.contains(2)
                ? const StatisticsScreen()
                : const SizedBox.shrink(),
            _visitedTabs.contains(3)
                ? const BudgetScreen()
                : const SizedBox.shrink(),
            _visitedTabs.contains(4)
                ? const ProfileScreen()
                : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: settings.text('Home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              label: settings.text('History'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.pie_chart_outline),
              label: settings.text('Statistics'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.savings_outlined),
              label: settings.text('Budget'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              label: settings.text('Profile'),
            ),
          ],
        ),
        floatingActionButton: _selectedIndex > 1
            ? null
            : FloatingActionButton.extended(
                onPressed: _addTransaction,
                icon: const Icon(Icons.add),
                label: Text(settings.text('Add Transaction')),
              ),
      ),
    );
  }

  Widget _moneyCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: Color.alphaBlend(
        color.withValues(alpha: 0.08),
        Theme.of(context).cardTheme.color!,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem(Transaction transaction) {
    final settings = AppSettings.of(context);
    final color = transaction.isIncome
        ? AppTheme.income(context)
        : AppTheme.expense(context);
    final date = transaction.date;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(
                transaction.isIncome
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${settings.text(transaction.category)} · ${date.day}.${date.month}.${date.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${transaction.isIncome ? '+' : '-'}${settings.formatMoney(transaction.amount)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: settings.text('Transaction actions'),
              onSelected: (value) {
                if (value == 'edit') {
                  _editTransaction(transaction);
                } else {
                  _deleteTransaction(transaction);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(settings.text('Edit')),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(settings.text('Delete')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
