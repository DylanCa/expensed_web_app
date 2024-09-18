import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/components/expense.dart';

class TransactionList extends StatelessWidget {
  final List<Expense> expenses;
  final Function(String) onSearch;
  final Function showFilterBottomSheet;
  final Set<String> selectedCategories;
  final Set<String> selectedPersons;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;

  const TransactionList({
    Key? key,
    required this.expenses,
    required this.onSearch,
    required this.showFilterBottomSheet,
    required this.selectedCategories,
    required this.selectedPersons,
    required this.startDate,
    required this.endDate,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group expenses by date
    Map<String, List<Expense>> groupedExpenses = {};
    for (var expense in expenses) {
      String date = DateFormat('yyyy-MM-dd').format(expense.dateTime);
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    // Sort dates in descending order
    List<String> sortedDates = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Flatten the grouped expenses while maintaining the date order
    List<Expense> flattenedExpenses = [];
    for (var date in sortedDates) {
      flattenedExpenses.addAll(groupedExpenses[date]!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(width: 16),
              Container(
                height: 36,
                width: 150,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onChanged: onSearch,
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => showFilterBottomSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFilterActive()
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withAlpha(25),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  minimumSize: Size(100, 42),
                ),
                icon: Icon(Icons.filter_list_outlined,
                    size: 20, color: Colors.white),
                label: Text(_getFilterButtonText()),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: flattenedExpenses.length,
            itemBuilder: (context, index) {
              Expense expense = flattenedExpenses[index];
              bool isNewDate = index == 0 ||
                  DateFormat('yyyy-MM-dd')
                          .format(flattenedExpenses[index - 1].dateTime) !=
                      DateFormat('yyyy-MM-dd').format(expense.dateTime);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNewDate)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Text(
                        DateFormat('MMMM d, yyyy').format(expense.dateTime),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ExpenseWidget(
                    backgroundColor:
                        index % 2 == 0 ? Colors.white : Colors.grey[100]!,
                    expense: expense,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _getFilterButtonText() {
    return _isFilterActive() ? 'Filters applied' : 'Filter';
  }

  bool _isFilterActive() {
    return startDate != null ||
        endDate != null ||
        selectedCategories.isNotEmpty ||
        selectedPersons.isNotEmpty ||
        searchQuery.isNotEmpty;
  }
}
