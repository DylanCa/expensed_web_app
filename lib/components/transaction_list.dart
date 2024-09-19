import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/components/expense.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:provider/provider.dart';

class TransactionList extends StatelessWidget {
  final List<Expense> expenses;
  final Function(String) onSearch;
  final Function showFilterBottomSheet;
  final Set<Category> selectedCategories;
  final Set<Person> selectedPersons;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;
  final double sectionSpacing;

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
    this.sectionSpacing = 8, // Default value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: expenses.isEmpty
              ? Center(child: Text('No expenses available'))
              : ListView.builder(
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
                        if (isNewDate) ...[
                          SizedBox(
                              height:
                                  24), // Increased space before new date section
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Text(
                              DateFormat('MMMM d, yyyy')
                                  .format(expense.dateTime),
                              style: TextStyle(
                                fontSize: 14, // Smaller font size
                                fontWeight:
                                    FontWeight.w500, // Slightly less bold
                                color: Colors.grey[600], // Lighter color
                              ),
                            ),
                          ),
                          SizedBox(height: 8), // Space after date header
                        ],
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    return SizedBox(
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
        controller: TextEditingController(text: searchQuery),
        onChanged: onSearch,
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => showFilterBottomSheet(),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFilterActive()
            ? Colors.blue : Colors.blue.withOpacity(0.5),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        minimumSize: Size(100, 36),
      ),
      icon: Icon(Icons.filter_list, size: 20),
      label: Text(_getFilterButtonText()),
    );
  }

  String _getHeaderText() {
    List<String> headerParts = [];
  
    if (searchQuery.isNotEmpty) {
      headerParts.add('"${searchQuery}"');
    }
  
    if (selectedCategories.isNotEmpty) {
      headerParts
          .add(selectedCategories.map((c) => c.name.toLowerCase()).join(', '));
    }
  
    headerParts.add('expenses');
  
    String header = headerParts.join(' ');
    return header.substring(0, 1).toUpperCase() + header.substring(1);
  }

  String _getSubHeaderText() {
    List<String> subHeaderParts = [];
    if (selectedPersons.isNotEmpty) {
      subHeaderParts
          .add('paid by ${selectedPersons.map((p) => p.name).join(', ')}');
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
