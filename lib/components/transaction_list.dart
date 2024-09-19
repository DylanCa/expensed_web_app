import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/components/expense.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:expensed_web_app/components/filter_bottom_sheet.dart';

class TransactionList extends StatefulWidget {
  final List<Expense> expenses;
  final Function(String) onSearch;
  final Function showFilterBottomSheet;
  final Set<Category> selectedCategories;
  final Set<Person> selectedPersons;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;
  final ExpenseProvider expenseProvider;

  const TransactionList({
    Key? key,
    required this.expenses,
    required this.onSearch,
    required this.showFilterBottomSheet,
    required this.selectedCategories,
    required this.selectedPersons,
    this.startDate,
    this.endDate,
    required this.searchQuery,
    required this.expenseProvider,
  }) : super(key: key);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: widget.expenses.isEmpty
              ? Center(
                  child: Text('No expenses available',
                      style: Theme.of(context).textTheme.bodyLarge))
              : ListView.builder(
                  itemCount: widget.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = widget.expenses[index];
                    bool isNewDate = index == 0 ||
                        DateFormat('yyyy-MM-dd')
                                .format(widget.expenses[index - 1].dateTime) !=
                            DateFormat('yyyy-MM-dd').format(expense.dateTime);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isNewDate) ...[
                          SizedBox(height: 24),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Text(
                              DateFormat('MMMM d, yyyy')
                                  .format(expense.dateTime),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                        GestureDetector(
                          onTap: () =>
                              _showExpenseBottomSheet(context, expense),
                          child: ExpenseWidget(
                            backgroundColor: index % 2 == 0
                                ? Colors.white
                                : Colors.grey[100]!,
                            expense: expense,
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getHeaderText(),
                  style: Theme.of(context).textTheme.displayMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 16),
              _buildSearchBar(context),
              SizedBox(width: 16),
              _buildFilterButton(context),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _getSubHeaderText(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 36,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search,
              size: 20, color: Theme.of(context).iconTheme.color),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      size: 20, color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearch('');
                  },
                )
              : null,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        controller: _searchController,
        onChanged: (value) {
          widget.onSearch(value);
        },
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => showFilterBottomSheet(context, widget.expenseProvider),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFilterActive()
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColor.withOpacity(0.5),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        minimumSize: Size(100, 36),
      ),
      icon: Icon(Icons.filter_list, size: 20),
      label: Text(_getFilterButtonText()),
    );
  }

  String _getHeaderText() {
    if (!_isFilterActive()) {
      return 'All Expenses';
    }

    List<String> headerParts = [];
  
    if (widget.searchQuery.isNotEmpty) {
      headerParts.add('"${widget.searchQuery}"');
    }
  
    if (widget.selectedCategories.isNotEmpty) {
      headerParts
          .add(widget.selectedCategories
          .map((c) => c.name.toLowerCase())
          .join(', '));
    }
  
    headerParts.add('expenses');
  
    String header = headerParts.join(' ');
    return header.substring(0, 1).toUpperCase() + header.substring(1);
  }

  String _getSubHeaderText() {
    List<String> subHeaderParts = [];
    if (widget.selectedPersons.isNotEmpty) {
      subHeaderParts
          .add(
          'paid by ${widget.selectedPersons.map((p) => p.name).join(', ')}');
    }
    if (widget.startDate != null && widget.endDate != null) {
      subHeaderParts.add(
          'from ${DateFormat('MMM d, y').format(widget.startDate!)} to ${DateFormat('MMM d, y').format(widget.endDate!)}');
    } else if (widget.startDate != null) {
      subHeaderParts
          .add('from ${DateFormat('MMM d, y').format(widget.startDate!)}');
    } else if (widget.endDate != null) {
      subHeaderParts
          .add('until ${DateFormat('MMM d, y').format(widget.endDate!)}');
    }
    return subHeaderParts.join(' ');
  }

  String _getFilterButtonText() {
    return _isFilterActive() ? 'Filters applied' : 'Filter';
  }

  bool _isFilterActive() {
    return widget.startDate != null ||
        widget.endDate != null ||
        widget.selectedCategories.isNotEmpty ||
        widget.selectedPersons.isNotEmpty ||
        widget.searchQuery.isNotEmpty;
  }

  void _showExpenseBottomSheet(BuildContext context, Expense expense) {
    final formKey = GlobalKey<FormState>();
    String shopName = expense.shopName;
    double amount = expense.amount;
    Category category = expense.category;
    Person paidBy = expense.paidBy;
    DateTime dateTime = expense.dateTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.9,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Expense',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: shopName,
                      decoration: InputDecoration(
                        labelText: 'Shop Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a shop name';
                        }
                        return null;
                      },
                      onSaved: (value) => shopName = value!,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      initialValue: amount.toString(),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
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
                      onSaved: (value) => amount = double.parse(value!),
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<Category>(
                      value: category,
                      items:
                          Provider.of<ExpenseProvider>(context, listen: false)
                              .categories
                              .map((Category cat) {
                        return DropdownMenuItem<Category>(
                          value: cat,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (Category? newValue) {
                        setState(() {
                          category = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<Person>(
                      value: paidBy,
                      items:
                          Provider.of<ExpenseProvider>(context, listen: false)
                              .persons
                              .map((Person person) {
                        return DropdownMenuItem<Person>(
                          value: person,
                          child: Text(person.name),
                        );
                      }).toList(),
                      onChanged: (Person? newValue) {
                        setState(() {
                          paidBy = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Paid By',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      initialValue:
                          DateFormat('yyyy-MM-dd HH:mm').format(dateTime),
                      decoration: InputDecoration(
                        labelText: 'Date and Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: dateTime,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(dateTime),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              dateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              final updatedExpense = expense.copyWith(
                                shopName: shopName,
                                amount: amount,
                                category: category,
                                paidBy: paidBy,
                                dateTime: dateTime,
                              );
                              Provider.of<ExpenseProvider>(context,
                                      listen: false)
                                  .updateExpense(updatedExpense);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Expense'),
                                  content: Text(
                                      'Are you sure you want to delete this expense?'),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Delete'),
                                      onPressed: () {
                                        Provider.of<ExpenseProvider>(context,
                                                listen: false)
                                            .deleteExpense(expense.id);
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Delete Expense'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
