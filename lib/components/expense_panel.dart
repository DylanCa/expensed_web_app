import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:uuid/uuid.dart';

class ExpensePanel extends StatefulWidget {
  final ExpenseProvider expenseProvider;
  final VoidCallback onClose;
  final Expense? expenseToEdit;
  final bool isFilterMode;

  const ExpensePanel({
    super.key,
    required this.expenseProvider,
    required this.onClose,
    this.expenseToEdit,
    this.isFilterMode = false,
  });

  @override
  _ExpensePanelState createState() => _ExpensePanelState();
}

class _ExpensePanelState extends State<ExpensePanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _amountController;
  Category? _category;
  Person? _paidBy;
  late DateTime _expenseDateTime;
  Set<Category> _selectedCategories = {};
  Set<Person> _selectedPersons = {};
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.isFilterMode) {
      _selectedCategories = Set.from(widget.expenseProvider.selectedCategories);
      _selectedPersons = Set.from(widget.expenseProvider.selectedPersons);
      _filterStartDate = widget.expenseProvider.startDate;
      _filterEndDate = widget.expenseProvider.endDate;
    } else {
      _shopNameController =
          TextEditingController(text: widget.expenseToEdit?.shopName ?? '');
      _amountController = TextEditingController(
          text: widget.expenseToEdit?.amount.toString() ?? '');
      _category = widget.expenseToEdit?.category;
      _paidBy = widget.expenseToEdit?.paidBy;
      _expenseDateTime = widget.expenseToEdit?.dateTime ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    if (!widget.isFilterMode) {
      _shopNameController.dispose();
      _amountController.dispose();
    }
    super.dispose();
  }

  void _resetForm() {
    if (widget.isFilterMode) {
      setState(() {
        _selectedCategories.clear();
        _selectedPersons.clear();
        _filterStartDate = null;
        _filterEndDate = null;
      });
    } else {
      _shopNameController.clear();
      _amountController.clear();
      setState(() {
        _category = null;
        _paidBy = null;
        _expenseDateTime = DateTime.now();
      });
    }
  }

  void _updateFilters() {
    widget.expenseProvider.setSelectedCategories(_selectedCategories);
    widget.expenseProvider.setSelectedPersons(_selectedPersons);
    widget.expenseProvider.setDateRange(_filterStartDate, _filterEndDate);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isFilterMode
                      ? 'Filter Expenses'
                      : (widget.expenseToEdit == null
                          ? 'Add New Expense'
                          : 'Edit Expense'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.isFilterMode) ...[
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
                    ],
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
                          selected: widget.isFilterMode
                              ? _selectedCategories.contains(cat)
                              : _category == cat,
                          onSelected: (bool selected) {
                            setState(() {
                              if (widget.isFilterMode) {
                                if (selected) {
                                  _selectedCategories.add(cat);
                                } else {
                                  _selectedCategories.remove(cat);
                                }
                                _updateFilters();
                              } else {
                                _category = selected ? cat : null;
                              }
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
                          selected: widget.isFilterMode
                              ? _selectedPersons.contains(person)
                              : _paidBy == person,
                          onSelected: (bool selected) {
                            setState(() {
                              if (widget.isFilterMode) {
                                if (selected) {
                                  _selectedPersons.add(person);
                                } else {
                                  _selectedPersons.remove(person);
                                }
                                _updateFilters();
                              } else {
                                _paidBy = selected ? person : null;
                              }
                            });
                          },
                          avatar: CircleAvatar(
                            radius: 12,
                            child: Text(person.name[0]),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),
                    if (widget.isFilterMode) ...[
                      _buildFilterDateRange(),
                    ] else ...[
                      _buildExpenseDateTimePicker(),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            if (widget.isFilterMode)
              Center(
                child: ElevatedButton(
                  onPressed: _resetFilters,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text('Reset Filters'),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.expenseToEdit != null)
                    TextButton(
                      onPressed: _showDeleteConfirmation,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text('Delete'),
                    ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(widget.expenseToEdit == null
                        ? 'Add Expense'
                        : 'Update Expense'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // New method for building the filter date range
  Widget _buildFilterDateRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date Range', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectFilterStartDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Start Date',
                  ),
                  child: Text(
                    _filterStartDate != null
                        ? DateFormat('MMM d, y').format(_filterStartDate!)
                        : 'Select',
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: _selectFilterEndDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'End Date',
                  ),
                  child: Text(
                    _filterEndDate != null
                        ? DateFormat('MMM d, y').format(_filterEndDate!)
                        : 'Select',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // New method for building the expense date and time picker
  Widget _buildExpenseDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expense Date and Time',
            style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        InkWell(
          onTap: _selectExpenseDateTime,
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Date and Time',
            ),
            child:
                Text(DateFormat('MMM d, y - h:mm a').format(_expenseDateTime)),
          ),
        ),
      ],
    );
  }

  // Separate methods for filter date selection
  Future<void> _selectFilterStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _filterStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _filterStartDate = pickedDate;
        _updateFilters();
      });
    }
  }

  Future<void> _selectFilterEndDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _filterEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _filterEndDate = pickedDate;
        _updateFilters();
      });
    }
  }

  // Separate method for expense date and time selection
  Future<void> _selectExpenseDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _expenseDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_expenseDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _expenseDateTime = DateTime(
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
    if (widget.isFilterMode) {
      widget.expenseProvider.setSelectedCategories(_selectedCategories);
      widget.expenseProvider.setSelectedPersons(_selectedPersons);
      widget.expenseProvider.setDateRange(_filterStartDate, _filterEndDate);
      widget.onClose();
    } else {
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
          dateTime: _expenseDateTime,
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExpense();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense() {
    if (widget.expenseToEdit != null) {
      widget.expenseProvider.deleteExpense(widget.expenseToEdit!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense deleted successfully')),
      );
      widget.onClose();
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedPersons.clear();
      _filterStartDate = null;
      _filterEndDate = null;
    });
    widget.expenseProvider.clearFilters();
    widget.onClose();
  }
}
