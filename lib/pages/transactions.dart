import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/components/transaction_list.dart';
import 'package:expensed_web_app/components/spending_by_person.dart';
import 'package:expensed_web_app/components/spending_per_category.dart';
import 'package:expensed_web_app/components/expense_summary.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';
import 'package:expensed_web_app/utils/ui_utils.dart';
import 'package:expensed_web_app/components/filter_bottom_sheet.dart';

class Transactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor));
        }

        if (expenseProvider.error != null) {
          return Center(
              child: Text(expenseProvider.error!,
                  style: Theme.of(context).textTheme.bodyLarge));
        }

        List<Expense> filteredExpenses = expenseProvider.getFilteredExpenses();
        List<Expense> allFilteredExpenses =
            expenseProvider.getAllFilteredExpenses();

        double currentWeekTotal = _calculateCurrentWeekTotal(filteredExpenses);
        double currentMonthTotal =
            _calculateCurrentMonthTotal(filteredExpenses);
        double averageWeeklyTotal =
            _calculateAverageWeeklyTotal(allFilteredExpenses);
        double averageMonthlyTotal =
            _calculateAverageMonthlyTotal(allFilteredExpenses);
        double selectedDateRangeTotal =
            _calculateSelectedDateRangeTotal(filteredExpenses);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildElevatedContainer(
                  child: TransactionList(
                    expenses: filteredExpenses,
                    onSearch: expenseProvider.setSearchQuery,
                    showFilterBottomSheet: () =>
                        showFilterBottomSheet(context, expenseProvider),
                    selectedCategories: expenseProvider.selectedCategories,
                    selectedPersons: expenseProvider.selectedPersons,
                    startDate: expenseProvider.startDate,
                    endDate: expenseProvider.endDate,
                    searchQuery: expenseProvider.searchQuery,
                    expenseProvider: expenseProvider,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Container(
                width: 350, // Set a fixed width for the right column
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildElevatedContainer(
                        child: ExpenseSummary(
                          currentWeekTotal: currentWeekTotal,
                          currentMonthTotal: currentMonthTotal,
                          selectedDateRangeTotal: selectedDateRangeTotal,
                          startDate: expenseProvider.startDate,
                          endDate: expenseProvider.endDate,
                          averageWeeklyTotal: averageWeeklyTotal,
                          averageMonthlyTotal: averageMonthlyTotal,
                        ),
                      ),
                      SizedBox(height: 16),
                      buildElevatedContainer(
                        child: SpendingByPerson(
                          filteredExpenses: filteredExpenses,
                        ),
                      ),
                      SizedBox(height: 16),
                      buildElevatedContainer(
                        child: SpendingPerCategory(
                          filteredExpenses: filteredExpenses,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                _showAddExpenseBottomSheet(context, expenseProvider),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  double _calculateCurrentWeekTotal(List<Expense> expenses) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return expenses
        .where((expense) =>
            expense.dateTime.isAfter(weekStart.subtract(Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateCurrentMonthTotal(List<Expense> expenses) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return expenses
        .where((expense) =>
            expense.dateTime.isAfter(monthStart.subtract(Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateSelectedDateRangeTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateAverageWeeklyTotal(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    final oldestExpense =
        expenses.reduce((a, b) => a.dateTime.isBefore(b.dateTime) ? a : b);
    final totalWeeks =
        DateTime.now().difference(oldestExpense.dateTime).inDays / 7;
    final totalAmount =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    return totalAmount / totalWeeks;
  }

  double _calculateAverageMonthlyTotal(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    final oldestExpense =
        expenses.reduce((a, b) => a.dateTime.isBefore(b.dateTime) ? a : b);
    final totalMonths =
        (DateTime.now().year - oldestExpense.dateTime.year) * 12 +
            (DateTime.now().month - oldestExpense.dateTime.month) +
            1;
    final totalAmount =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    return totalAmount / totalMonths;
  }

  void _showAddExpenseBottomSheet(
      BuildContext context, ExpenseProvider expenseProvider) {
    final formKey = GlobalKey<FormState>();
    String shopName = '';
    double amount = 0.0;
    Category? category;
    Person? paidBy;
    DateTime dateTime = DateTime.now();

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
                      'Add New Expense',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
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
                      items: expenseProvider.categories.map((Category cat) {
                        return DropdownMenuItem<Category>(
                          value: cat,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (Category? newValue) {
                        setState(() {
                          category = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<Person>(
                      value: paidBy,
                      items: expenseProvider.persons.map((Person person) {
                        return DropdownMenuItem<Person>(
                          value: person,
                          child: Text(person.name),
                        );
                      }).toList(),
                      onChanged: (Person? newValue) {
                        setState(() {
                          paidBy = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Paid By',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a person';
                        }
                        return null;
                      },
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
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            final newExpense = Expense(
                              shopName: shopName,
                              amount: amount,
                              category: category!,
                              paidBy: paidBy!,
                              dateTime: dateTime,
                            );
                            expenseProvider.addExpense(newExpense);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: Text('Add Expense'),
                      ),
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
