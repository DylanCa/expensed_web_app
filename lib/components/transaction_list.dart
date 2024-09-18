import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/components/expense.dart';

class TransactionList extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> groupedExpenses;
  final List<String> sortedDates;
  final bool isNarrowLayout;
  final Set<String> selectedCategories;
  final Set<String> selectedPersons;
  final Function(BuildContext) showFilterBottomSheet;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String) onSearch;
  final String searchQuery;

  const TransactionList({
    Key? key,
    required this.groupedExpenses,
    required this.sortedDates,
    required this.isNarrowLayout,
    required this.selectedCategories,
    required this.selectedPersons,
    required this.showFilterBottomSheet,
    required this.onSearch,
    required this.searchQuery,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getHeaderText(),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (_getSubHeaderText().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _getSubHeaderText(),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Container(
                height: 36, // Match the height of the ElevatedButton
                width:
                    120, // Adjust this value to match the filter button width
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
              ElevatedButton(
                onPressed: () => showFilterBottomSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  minimumSize: Size(120, 36), // Set a fixed size for the button
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getFilterButtonText(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.filter_list, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        Flexible(
          fit: isNarrowLayout ? FlexFit.loose : FlexFit.tight,
          child: ListView.builder(
            shrinkWrap: isNarrowLayout,
            physics: isNarrowLayout ? NeverScrollableScrollPhysics() : null,
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              String date = sortedDates[index];
              List<Map<String, dynamic>> expenses = groupedExpenses[date]!;

              // Filter expenses based on selected categories, persons, and search query
              expenses = expenses
                  .where((e) =>
                      (selectedCategories.isEmpty ||
                          selectedCategories.contains(e['category'])) &&
                      (selectedPersons.isEmpty ||
                          selectedPersons.contains(e['paidBy'])) &&
                      (searchQuery.isEmpty ||
                          e['shopName']
                              .toString()
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          e['category']
                              .toString()
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          e['paidBy']
                              .toString()
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase())))
                  .toList();

              if (expenses.isEmpty) {
                return SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      DateFormat('MMMM d, yyyy').format(DateTime.parse(date)),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...expenses.map((expense) {
                    return Expense(
                      backgroundColor: Colors.white,
                      dateTime: expense['dateTime'],
                      shopName: expense['shopName'],
                      category: expense['category'],
                      amount: expense['amount'],
                      paidBy: expense['paidBy'],
                    );
                  }).toList(),
                  SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _getHeaderText() {
    if (startDate != null && endDate != null) {
      return 'Transactions from ${DateFormat('MMMM d').format(startDate!)} to ${DateFormat('MMMM d').format(endDate!)}';
    } else if (startDate != null) {
      return 'Transactions from ${DateFormat('MMMM d').format(startDate!)}';
    } else if (endDate != null) {
      return 'Transactions until ${DateFormat('MMMM d').format(endDate!)}';
    } else {
      return 'All Transactions';
    }
  }

  String _getSubHeaderText() {
    List<String> filters = [];
    if (selectedCategories.isNotEmpty) {
      filters.addAll(selectedCategories);
    }
    if (selectedPersons.isNotEmpty) {
      filters.addAll(selectedPersons);
    }
    return filters.join(', ');
  }

  String _getFilterButtonText() {
    if (selectedCategories.isEmpty &&
        selectedPersons.isEmpty &&
        startDate == null &&
        endDate == null &&
        searchQuery.isEmpty) {
      return 'Filter';
    } else if (searchQuery.isNotEmpty) {
      return 'Search applied';
    } else if (selectedCategories.isEmpty &&
        selectedPersons.isEmpty &&
        (startDate != null || endDate != null)) {
      return 'Date filter applied';
    } else {
      return 'Filters applied';
    }
  }
}
