import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:uuid/uuid.dart';

class AddExpensePanel extends StatefulWidget {
  final ExpenseProvider expenseProvider;
  final VoidCallback onClose;
  final Expense? expenseToEdit;

  const AddExpensePanel({
    Key? key,
    required this.expenseProvider,
    required this.onClose,
    this.expenseToEdit,
  }) : super(key: key);

  @override
  _AddExpensePanelState createState() => _AddExpensePanelState();
}

class _AddExpensePanelState extends State<AddExpensePanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _amountController;
  Category? _category;
  Person? _paidBy;
  late DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _shopNameController =
        TextEditingController(text: widget.expenseToEdit?.shopName ?? '');
    _amountController = TextEditingController(
        text: widget.expenseToEdit?.amount.toString() ?? '');
    _category = widget.expenseToEdit?.category;
    _paidBy = widget.expenseToEdit?.paidBy;
    _dateTime = widget.expenseToEdit?.dateTime ?? DateTime.now();
  }

  @override
  void didUpdateWidget(AddExpensePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expenseToEdit != oldWidget.expenseToEdit) {
      _initializeFields();
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _shopNameController.clear();
    _amountController.clear();
    setState(() {
      _category = null;
      _paidBy = null;
      _dateTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(66, 16, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.expenseToEdit == null ? 'Add New Expense' : 'Edit Expense',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _shopNameController,
                      decoration: InputDecoration(
                        labelText: 'Shop Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a shop name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    Text('Category',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          widget.expenseProvider.categories.map((Category cat) {
                        return ChoiceChip(
                          label: Text(cat.name),
                          selected: _category == cat,
                          onSelected: (bool selected) {
                            setState(() {
                              _category = selected ? cat : null;
                            });
                          },
                          avatar: Icon(cat.icon, size: 18),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),
                    Text('Paid By',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          widget.expenseProvider.persons.map((Person person) {
                        return ChoiceChip(
                          label: Text(person.name),
                          selected: _paidBy == person,
                          onSelected: (bool selected) {
                            setState(() {
                              _paidBy = selected ? person : null;
                            });
                          },
                          avatar: CircleAvatar(
                            child: Text(person.name[0]),
                            radius: 12,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),
                    Text('Date and Time',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateTime,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('MMMM d, y - h:mm a').format(_dateTime),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _resetForm();
                    widget.onClose();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.expenseToEdit == null
                      ? 'Add Expense'
                      : 'Update Expense'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _dateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _category != null &&
        _paidBy != null) {
      _formKey.currentState!.save();
      final expense = Expense(
        id: widget.expenseToEdit?.id ?? Uuid().v4(),
        shopName: _shopNameController.text,
        amount: double.parse(_amountController.text),
        category: _category!,
        paidBy: _paidBy!,
        dateTime: _dateTime,
      );
      
      if (widget.expenseToEdit == null) {
        widget.expenseProvider.addExpense(expense);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense added successfully')),
        );
      } else {
        widget.expenseProvider.updateExpense(expense);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense updated successfully')),
        );
      }

      _resetForm();
      widget.onClose();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }
}
