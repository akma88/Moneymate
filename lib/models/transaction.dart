class Transaction {
  final String title;
  final double amount;
  final String category;
  final bool isIncome;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'category': category,
    'isIncome': isIncome,
    'date': date.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num).toDouble();
    if (!amount.isFinite || amount <= 0) {
      throw const FormatException('Invalid transaction amount');
    }
    return Transaction(
      title: json['title'] as String,
      amount: amount,
      category: json['category'] as String,
      isIncome: json['isIncome'] as bool,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Transaction({
    required this.title,
    required this.amount,
    required this.category,
    required this.isIncome,
    required this.date,
  });
}
