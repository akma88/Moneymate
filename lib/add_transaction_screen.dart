import 'package:flutter/material.dart';
import 'models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isIncome = false;

  String _selectedCategory = 'Food';

  final List<String> _categories = [
    'Food',
    'Shopping',
    'Transport',
    'Entertainment',
    'Bills',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        isIncome: _isIncome,
        date: DateTime.now(),
      );

      Navigator.pop(context, transaction);
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
          'Add Transaction',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a new transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Enter the details of your transaction',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),

              const SizedBox(height: 25),

              const Text(
                'Transaction Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Expense'),
                      selected: !_isIncome,
                      onSelected: (value) {
                        setState(() {
                          _isIncome = false;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Income'),
                      selected: _isIncome,
                      onSelected: (value) {
                        setState(() {
                          _isIncome = true;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                'Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Example: Lunch',
                  prefixIcon: const Icon(Icons.edit_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }

                  if (value.trim().length < 2) {
                    return 'Title must contain at least 2 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Example: 25.50',
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }

                  final amount = double.tryParse(value);

                  if (amount == null) {
                    return 'Please enter a valid number';
                  }

                  if (amount <= 0) {
                    return 'Amount must be greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedCategory,

                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),

                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
