class Transaction {
  final String title;
  final double amount;
  final String category;
  final bool isIncome;
  final DateTime date;

  Transaction({
    required this.title,
    required this.amount,
    required this.category,
    required this.isIncome,
    required this.date,
  });
}
