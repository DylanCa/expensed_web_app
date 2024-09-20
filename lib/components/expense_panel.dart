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
    Key? key,
    required this.expenseProvider,
    required this.onClose,
    this.expenseToEdit,
    this.isFilterMode = false,
  }) : super(key: key);

  @override
  _ExpensePanelState createState() => _ExpensePanelState();
}

class _ExpensePanelState extends State<ExpensePanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _amountController;
  Category? _category;
  Person? _paidBy;
  late DateTime _dateTime;
  Set<Category> _selectedCategories = {};
  Set<Person> _selectedPersons = {};
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.isFilterMode) {
      _selectedCategories = Set.from(widget.expenseProvider.selectedCategories);
      _selectedPersons = Set.from(widget.expenseProvider.selectedPersons);
      _startDate = widget.expenseProvider.startDate;
      _endDate = widget.expenseProvider.endDate;
    } else {
      _shopNameController =
          TextEditingController(text: widget.expenseToEdit?.shopName ?? '');
      _amountController = TextEditingController(
          text: widget.expenseToEdit?.amount.toString() ?? '');
      _category = widget.expenseToEdit?.category;
      _paidBy = widget.expenseToEdit?.paidBy;
      _dateTime = widget.expenseToEdit?.dateTime ?? DateTime.now();
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
        _startDate = null;
        _endDate = null;
      });
    } else {
      _shopNameController.clear();
      _amountController.clear();
      setState(() {
        _category = null;
        _paidBy = null;
        _dateTime = DateTime.now();
      });
    }
  }

  void _updateFilters() {
    widget.expenseProvider.setSelectedCategories(_selectedCategories);
    widget.expenseProvider.setSelectedPersons(_selectedPersons);
    widget.expenseProvider.setDateRange(_startDate, _endDate);
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
              widget.isFilterMode
                  ? 'Filter Expenses'
                  : (widget.expenseToEdit == null
                      ? 'Add New Expense'
                      : 'Edit Expense'),
              style: Theme.of(context).textTheme.headlineSmall,
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
                                _updateFilters(); // Update filters immediately
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
                                _updateFilters(); // Update filters immediately
                              } else {
                                _paidBy = selected ? person : null;
                              }
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
                    Text('Date Range',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(isStartDate: true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Start Date',
                              ),
                              child: Text(
                                widget.isFilterMode && _startDate != null
                                    ? DateFormat('MMM d, y').format(_startDate!)
                                    : (!widget.isFilterMode
                                        ? DateFormat('MMM d, y')
                                            .format(_dateTime)
                                        : 'Select'),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(isStartDate: false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'End Date',
                              ),
                              child: Text(
                                widget.isFilterMode && _endDate != null
                                    ? DateFormat('MMM d, y').format(_endDate!)
                                    : (!widget.isFilterMode
                                        ? DateFormat('h:mm a').format(_dateTime)
                                        : 'Select'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            if (widget.isFilterMode)
              Center(
                child: ElevatedButton(
                  onPressed: _resetFilters,
                  child: Text('Reset Filters'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              )
            else
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
                  if (widget.expenseToEdit != null)
                    TextButton(
                      onPressed: _showDeleteConfirmation,
                      child: Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(widget.expenseToEdit == null
                        ? 'Add Expense'
                        : 'Update Expense'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
        _updateFilters(); // Update filters immediately after date selection
      });
    }
  }

  void _submitForm() {
    if (widget.isFilterMode) {
      widget.expenseProvider.setSelectedCategories(_selectedCategories);
      widget.expenseProvider.setSelectedPersons(_selectedPersons);
      widget.expenseProvider.setDateRange(_startDate, _endDate);
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
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExpense();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
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
      _startDate = null;
      _endDate = null;
    });
    widget.expenseProvider.clearFilters();
    widget.onClose();
  }
}
