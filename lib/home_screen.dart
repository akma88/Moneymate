import 'package:flutter/material.dart';
import 'registration_screen.dart';
import 'add_transaction_screen.dart';
import 'models/transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];

  String? _userName;

  double get _totalIncome {
    double total = 0;

    for (final transaction in _transactions) {
      if (transaction.isIncome) {
        total += transaction.amount;
      }
    }

    return total;
  }

  double get _totalExpenses {
    double total = 0;

    for (final transaction in _transactions) {
      if (!transaction.isIncome) {
        total += transaction.amount;
      }
    }

    return total;
  }

  double get _balance {
    return _totalIncome - _totalExpenses;
  }

  Future<void> _openRegistration() async {
    final name = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
    );

    if (name != null) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _addTransaction() async {
    final transaction = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    if (transaction != null) {
      setState(() {
        _transactions.add(transaction);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8F6),
        elevation: 0,

        title: const Text(
          'MoneyMate',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              _userName == null
                  ? 'Good morning 👋'
                  : 'Good morning, $_userName 👋',

              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 8),

            if (_userName == null)
              const Text(
                'Not registered yet?',
                style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
              ),

            if (_userName == null) const SizedBox(height: 15),

            if (_userName == null)
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed: _openRegistration,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D60),
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text(
                    'Create an account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: const Color(0xFF2E7D60),
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '\$${_balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Current balance',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _moneyCard(
                    title: 'Income',
                    amount: '\$${_totalIncome.toStringAsFixed(2)}',
                    icon: Icons.arrow_downward,
                    iconColor: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _moneyCard(
                    title: 'Expenses',
                    amount: '\$${_totalExpenses.toStringAsFixed(2)}',
                    icon: Icons.arrow_upward,
                    iconColor: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (_transactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'No transactions yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Tap + to add your first transaction',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                itemCount: _transactions.length,

                itemBuilder: (context, index) {
                  final transaction = _transactions[index];

                  return _transactionItem(transaction);
                },
              ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D60),
        foregroundColor: Colors.white,

        onPressed: _addTransaction,

        child: const Icon(Icons.add),
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
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: iconColor, size: 20),
          ),

          const SizedBox(height: 12),

          Text(title, style: const TextStyle(color: Color(0xFF6B7280))),

          const SizedBox(height: 4),

          Text(
            amount,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(Transaction transaction) {
    final bool isIncome = transaction.isIncome;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),

            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  transaction.category,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',

            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
