import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/components/transaction_list.dart';
import 'package:expensed_web_app/components/spending_by_person.dart';
import 'package:expensed_web_app/components/expense_last_week.dart';
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
          return Center(child: CircularProgressIndicator());
        }

        if (expenseProvider.error != null) {
          return Center(child: Text(expenseProvider.error!));
        }

        List<Expense> filteredExpenses = expenseProvider.getFilteredExpenses();

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              const rightColumnWidth = 400.0;
              const minLeftColumnWidth = 600.0;
              final isWideLayout =
                  totalWidth >= minLeftColumnWidth + rightColumnWidth;

              if (isWideLayout) {
                // Wide layout
                return Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildElevatedContainer(
                            TransactionList(
                              expenses: filteredExpenses,
                              onSearch: expenseProvider.setSearchQuery,
                              showFilterBottomSheet: () =>
                                  showFilterBottomSheet(
                                      context, expenseProvider),
                              selectedCategories:
                                  expenseProvider.selectedCategories,
                              selectedPersons: expenseProvider.selectedPersons,
                              startDate: expenseProvider.startDate,
                              endDate: expenseProvider.endDate,
                              searchQuery: expenseProvider.searchQuery,
                              expenseProvider: expenseProvider,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: rightColumnWidth,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                buildElevatedContainer(
                                  SizedBox(
                                    height: 400,
                                    child: SpendingByPerson(
                                      filteredExpenses: filteredExpenses,
                                    ),
                                  ),
                                ),
                                buildElevatedContainer(
                                  SizedBox(
                                    height: 450,
                                    child: ExpenseLastWeek(
                                      filteredExpenses: filteredExpenses,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: rightColumnWidth + 32, // Increased from 16
                      bottom: 32, // Increased from 16
                      child: FloatingActionButton(
                        onPressed: () => _showAddExpenseBottomSheet(
                            context, expenseProvider),
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                );
              } else {
                // Narrow layout
                return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  buildElevatedContainer(
                                    Container(
                                      constraints:
                                          BoxConstraints(minWidth: 400),
                                      width: 450,
                                      height: 450,
                                      child: SpendingByPerson(
                                        filteredExpenses: filteredExpenses,
                                      ),
                                    ),
                                  ),
                                  buildElevatedContainer(
                                    Container(
                                      constraints:
                                          BoxConstraints(minWidth: 400),
                                      width: 450,
                                      height: 450,
                                      child: ExpenseLastWeek(
                                        filteredExpenses: filteredExpenses,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          buildElevatedContainer(
                            SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: TransactionList(
                                expenses: filteredExpenses,
                                onSearch: expenseProvider.setSearchQuery,
                                showFilterBottomSheet: () =>
                                    showFilterBottomSheet(
                                        context, expenseProvider),
                                selectedCategories:
                                    expenseProvider.selectedCategories,
                                selectedPersons:
                                    expenseProvider.selectedPersons,
                                startDate: expenseProvider.startDate,
                                endDate: expenseProvider.endDate,
                                searchQuery: expenseProvider.searchQuery,
                                expenseProvider: expenseProvider,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 32, // Increased from 16
                      bottom: 32, // Increased from 16
                      child: FloatingActionButton(
                        onPressed: () => _showAddExpenseBottomSheet(
                            context, expenseProvider),
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        );
      },
    );
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                        child: Text('Add Expense'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
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
