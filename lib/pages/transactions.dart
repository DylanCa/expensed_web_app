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
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildElevatedContainer(
                        TransactionList(
                          expenses: filteredExpenses,
                          onSearch: expenseProvider.setSearchQuery,
                          showFilterBottomSheet: () =>
                              showFilterBottomSheet(context, expenseProvider),
                          selectedCategories:
                              expenseProvider.selectedCategories,
                          selectedPersons: expenseProvider.selectedPersons,
                          startDate: expenseProvider.startDate,
                          endDate: expenseProvider.endDate,
                          searchQuery: expenseProvider.searchQuery,
                          expenseProvider: expenseProvider, // Add this line
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
                              buildElevatedContainer(
                                Container(
                                  constraints: BoxConstraints(minWidth: 400),
                                  width: 450,
                                  height: 450,
                                  child: SpendingByPerson(
                                    filteredExpenses: filteredExpenses,
                                  ),
                                ),
                              ),
                              buildElevatedContainer(
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
                      buildElevatedContainer(
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: TransactionList(
                            expenses: filteredExpenses,
                            onSearch: expenseProvider.setSearchQuery,
                            showFilterBottomSheet: () =>
                                showFilterBottomSheet(context, expenseProvider),
                            selectedCategories:
                                expenseProvider.selectedCategories,
                            selectedPersons: expenseProvider.selectedPersons,
                            startDate: expenseProvider.startDate,
                            endDate: expenseProvider.endDate,
                            searchQuery: expenseProvider.searchQuery,
                            expenseProvider: expenseProvider, // Add this line
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
}
