import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.transaction});

  final Transaction? transaction;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isIncome = false;
  String _selectedCategory = 'Food';

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

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
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _isIncome = transaction.isIncome;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
      _selectedTime = TimeOfDay.fromDateTime(transaction.date);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (!mounted) return;
    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (!mounted) return;
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        title: _titleController.text.trim(),
        amount: double.parse(
          _amountController.text.trim().replaceAll(',', '.'),
        ),
        category: _selectedCategory,
        isIncome: _isIncome,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
      );

      Navigator.pop(context, transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          AppSettings.of(context).text(
            widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
          ),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppSettings.of(context).text('Add a new transaction'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 6),
              Text(
                AppSettings.of(
                  context,
                ).text('Enter the details of your transaction'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 25),

              Text(
                AppSettings.of(context).text('Transaction Type'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text(AppSettings.of(context).text('Expense')),
                      selected: !_isIncome,
                      onSelected: (value) {
                        setState(() {
                          _isIncome = false;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: Text(AppSettings.of(context).text('Income')),
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

              SizedBox(height: 25),
              Text(
                AppSettings.of(context).text('Title'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: AppSettings.of(context).text('Example: Lunch'),
                  prefixIcon: Icon(Icons.edit_outlined),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppSettings.of(context).text('Please enter a title');
                  }
                  if (value.trim().length < 2) {
                    return AppSettings.of(
                      context,
                    ).text('Title must contain at least 2 characters');
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),
              Text(
                AppSettings.of(context).text('Amount'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: AppSettings.of(context).text('Example: 25.50'),
                  prefixText: '${AppSettings.of(context).currencySymbol} ',
                  prefixIcon: Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppSettings.of(
                      context,
                    ).text('Please enter an amount');
                  }
                  final amount = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );
                  if (amount == null || !amount.isFinite) {
                    return AppSettings.of(
                      context,
                    ).text('Please enter a valid number');
                  }
                  if (amount <= 0) {
                    return AppSettings.of(
                      context,
                    ).text('Amount must be greater than 0');
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),
              Text(
                AppSettings.of(context).text('Category'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(AppSettings.of(context).text(category)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              SizedBox(height: 20),
              Text(
                AppSettings.of(context).text('Date'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _dateTimeField(
                icon: Icons.calendar_month,
                value:
                    '${_selectedDate.day.toString().padLeft(2, '0')}.'
                    '${_selectedDate.month.toString().padLeft(2, '0')}.'
                    '${_selectedDate.year}',
                onTap: _pickDate,
              ),

              SizedBox(height: 20),
              Text(
                AppSettings.of(context).text('Time'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _dateTimeField(
                icon: Icons.access_time,
                value: _selectedTime.format(context),
                onTap: _pickTime,
              ),

              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    AppSettings.of(context).text('Save Transaction'),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateTimeField({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 17),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Spacer(),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
