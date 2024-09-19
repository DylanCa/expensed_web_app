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

class Transactions extends StatelessWidget {
  Widget _buildElevatedContainer(Widget child) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

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
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildElevatedContainer(
                        TransactionList(
                          expenses: filteredExpenses,
                          onSearch: expenseProvider.setSearchQuery,
                          showFilterBottomSheet: () =>
                              _showFilterBottomSheet(context, expenseProvider),
                          selectedCategories:
                              expenseProvider.selectedCategories,
                          selectedPersons: expenseProvider.selectedPersons,
                          startDate: expenseProvider.startDate,
                          endDate: expenseProvider.endDate,
                          searchQuery: expenseProvider.searchQuery,
                          // Remove this line: sectionSpacing: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: rightColumnWidth,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildElevatedContainer(
                              SizedBox(
                                height:
                                    400, // Reduced height for Spending By Person
                                child: SpendingByPerson(
                                  filteredExpenses: filteredExpenses,
                                ),
                              ),
                            ),
                            _buildElevatedContainer(
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
                );
              } else {
                // Narrow layout
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildElevatedContainer(
                                Container(
                                  constraints: BoxConstraints(minWidth: 400),
                                  width: 450,
                                  height: 450,
                                  child: SpendingByPerson(
                                    filteredExpenses: filteredExpenses,
                                  ),
                                ),
                              ),
                              _buildElevatedContainer(
                                Container(
                                  constraints: BoxConstraints(minWidth: 400),
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
                      _buildElevatedContainer(
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: TransactionList(
                            expenses: filteredExpenses,
                            onSearch: expenseProvider.setSearchQuery,
                            showFilterBottomSheet: () => _showFilterBottomSheet(
                                context, expenseProvider),
                            selectedCategories:
                                expenseProvider.selectedCategories,
                            selectedPersons: expenseProvider.selectedPersons,
                            startDate: expenseProvider.startDate,
                            endDate: expenseProvider.endDate,
                            searchQuery: expenseProvider.searchQuery,
                            // Remove this line: sectionSpacing: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(
      BuildContext context, ExpenseProvider expenseProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          expenseProvider.clearFilters();
                          Navigator.pop(context);
                        },
                        child: Text('Clear All Filters'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Filter by Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (expenseProvider.startDate != null)
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        expenseProvider.setDateRange(
                                            null, expenseProvider.endDate);
                                      });
                                    },
                                  ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: expenseProvider.startDate != null
                                ? DateFormat('MM/dd/yyyy')
                                    .format(expenseProvider.startDate!)
                                : '',
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  expenseProvider.startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                expenseProvider.setDateRange(
                                    pickedDate, expenseProvider.endDate);
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (expenseProvider.endDate != null)
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        expenseProvider.setDateRange(
                                            expenseProvider.startDate, null);
                                      });
                                    },
                                  ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: expenseProvider.endDate != null
                                ? DateFormat('MM/dd/yyyy')
                                    .format(expenseProvider.endDate!)
                                : '',
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  expenseProvider.endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                expenseProvider.setDateRange(
                                    expenseProvider.startDate, pickedDate);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Filter by Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        expenseProvider.categories.map((Category category) {
                      return FilterChip(
                        label: Text(category.name),
                        selected: expenseProvider.selectedCategories
                            .contains(category),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              expenseProvider.selectedCategories.add(category);
                            } else {
                              expenseProvider.selectedCategories
                                  .remove(category);
                            }
                            expenseProvider.setSelectedCategories(
                                expenseProvider.selectedCategories);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Filter by Person',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: expenseProvider.persons.map((Person person) {
                      return FilterChip(
                        label: Text(person.name),
                        selected:
                            expenseProvider.selectedPersons.contains(person),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              expenseProvider.selectedPersons.add(person);
                            } else {
                              expenseProvider.selectedPersons.remove(person);
                            }
                            expenseProvider.setSelectedPersons(
                                expenseProvider.selectedPersons);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
