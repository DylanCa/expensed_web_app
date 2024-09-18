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
    this.startDate,
    this.endDate,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrowLayout =
            constraints.maxWidth < 600; // Adjust this threshold as needed

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getHeaderText(),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (_getSubHeaderText().isNotEmpty)
                              Text(
                                _getSubHeaderText(),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                      if (!isNarrowLayout) ...[
                        SizedBox(width: 16),
                        _buildSearchBar(),
                      ],
                      SizedBox(width: 16),
                      _buildFilterButton(context),
                    ],
                  ),
                  if (isNarrowLayout) ...[
                    SizedBox(height: 16),
                    _buildSearchBar(),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  bool isNewDate = index == 0 ||
                      DateFormat('yyyy-MM-dd')
                              .format(expenses[index - 1].dateTime) !=
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
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 200,
      height: 36,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, size: 20),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onChanged: onSearch,
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => showFilterBottomSheet(),
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
      return 'All expenses';
    }
    List<String> headerParts = [];
    if (selectedCategories.isNotEmpty) {
      headerParts.add(selectedCategories.join(', '));
    }
    headerParts.add('expenses');
    return headerParts.join(' ');
  }

  String _getSubHeaderText() {
    List<String> subHeaderParts = [];
    if (selectedPersons.isNotEmpty) {
      subHeaderParts.add('paid by ${selectedPersons.join(', ')}');
    }
    if (startDate != null && endDate != null) {
      subHeaderParts.add(
          'from ${DateFormat('MMM d, y').format(startDate!)} to ${DateFormat('MMM d, y').format(endDate!)}');
    } else if (startDate != null) {
      subHeaderParts.add('from ${DateFormat('MMM d, y').format(startDate!)}');
    } else if (endDate != null) {
      subHeaderParts.add('until ${DateFormat('MMM d, y').format(endDate!)}');
    }
    return subHeaderParts.join(' ');
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
