import 'settings_screen.dart';
import 'package:flutter/material.dart';
import 'registration_screen.dart';
import 'add_transaction_screen.dart';
import 'models/transaction.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'app_settings.dart';
import 'models/transactions_model.dart';
import 'models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openRegistration() async {
    final name = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
    );

    if (!mounted) return;
    if (name != null) {
      ScopedModel.of<UserModel>(context).register(name);
    }
  }

  Future<void> _addTransaction() async {
    final transaction = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    if (!mounted) return;
    if (transaction != null) {
      context.read<TransactionsModel>().add(transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finances = context.watch<TransactionsModel>();
    final transactions = finances.transactions;
    final userName = ScopedModel.of<UserModel>(
      context,
      rebuildOnChange: true,
    ).name;
    final settings = AppSettings.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,

        title: Text(
          'MoneyMate',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        actions: [
          IconButton(
            tooltip: settings.text('Settings'),
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              settings.greeting(userName),

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 8),

            if (userName == null)
              Text(
                AppSettings.of(context).text('Not registered yet?'),
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

            if (userName == null) SizedBox(height: 15),

            if (userName == null)
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed: _openRegistration,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D60),
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: Text(
                    AppSettings.of(context).text('Create an account'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Color(0xFF2E7D60),
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    AppSettings.of(context).text('Total Balance'),
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  SizedBox(height: 8),

                  Text(
                    settings.formatMoney(finances.balance),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    AppSettings.of(context).text('Current balance'),
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _moneyCard(
                    title: AppSettings.of(context).text('Income'),
                    amount: settings.formatMoney(finances.totalIncome),
                    icon: Icons.arrow_downward,
                    iconColor: Colors.green,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: _moneyCard(
                    title: AppSettings.of(context).text('Expenses'),
                    amount: settings.formatMoney(finances.totalExpenses),
                    icon: Icons.arrow_upward,
                    iconColor: Colors.red,
                  ),
                ),
              ],
            ),

            SizedBox(height: 28),

            Text(
              AppSettings.of(context).text('Recent Transactions'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 12),

            if (transactions.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 12),

                    Text(
                      AppSettings.of(context).text('No transactions yet'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      AppSettings.of(
                        context,
                      ).text('Tap + to add your first transaction'),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),

                itemCount: transactions.length,

                itemBuilder: (context, index) {
                  final transaction = transactions[index];

                  return _transactionItem(transaction);
                },
              ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2E7D60),
        foregroundColor: Colors.white,

        onPressed: _addTransaction,

        child: Icon(Icons.add),
      ),
    );
  }

  Widget _moneyCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: EdgeInsets.all(8),

            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: iconColor, size: 20),
          ),

          SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: 4),

          Text(
            amount,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(Transaction transaction) {
    final bool isIncome = transaction.isIncome;

    final date = transaction.date;
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';

    final formattedTime =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  AppSettings.of(context).text(transaction.category),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 5),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _transactionDateTime(Icons.calendar_today, formattedDate),
                    _transactionDateTime(Icons.access_time, formattedTime),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 5),
          Text(
            '${isIncome ? '+' : '-'}'
            '${AppSettings.of(context).formatMoney(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionDateTime(IconData icon, String value) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
