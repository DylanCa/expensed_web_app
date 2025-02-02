import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';

class TransactionList extends StatefulWidget {
  final List<Expense> expenses;
  final Function(String) onSearch;
  final VoidCallback showFilterPanel;
  final Set<Category> selectedCategories;
  final Set<Person> selectedPersons;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;
  final ExpenseProvider expenseProvider;
  final Function(Expense) onExpenseSelected;
  final Expense? selectedExpense;

  const TransactionList({
    super.key,
    required this.expenses,
    required this.onSearch,
    required this.showFilterPanel,
    required this.selectedCategories,
    required this.selectedPersons,
    this.startDate,
    this.endDate,
    required this.searchQuery,
    required this.expenseProvider,
    required this.onExpenseSelected,
    this.selectedExpense,
  });

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

  void _setCurrentMonthFilter() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    widget.expenseProvider.setDateRange(startOfMonth, endOfMonth);
  }

  void _setCurrentWeekFilter() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    widget.expenseProvider.setDateRange(startOfWeek, endOfWeek);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, thickness: 1),
        ),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: RoundedExpenseWidget(
                            expense: expense,
                            onTap: () => widget.onExpenseSelected(expense),
                            isSelected: expense == widget.selectedExpense,
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
          SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: _setCurrentMonthFilter,
                child: Text('Current Month'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _setCurrentWeekFilter,
                child: Text('Current Week'),
              ),
            ],
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
      onPressed: widget.showFilterPanel,
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
      List<String> categoryNames =
          widget.selectedCategories
          .map((c) => c.name.toLowerCase())
          .toList();

      if (categoryNames.length <= 2) {
        headerParts.add(categoryNames.join(', '));
      } else {
        headerParts.add(
            '${categoryNames[0]}, ${categoryNames[1]} and ${categoryNames.length - 2} more categories');
      }
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
}

class RoundedExpenseWidget extends StatefulWidget {
  final Expense expense;
  final VoidCallback onTap;
  final bool isSelected;

  const RoundedExpenseWidget({
    super.key,
    required this.expense,
    required this.onTap,
    required this.isSelected,
  });

  @override
  _RoundedExpenseWidgetState createState() => _RoundedExpenseWidgetState();
}

class _RoundedExpenseWidgetState extends State<RoundedExpenseWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.grey
                  .withOpacity(widget.isSelected || _isHovered ? 0.3 : 0.1),
              spreadRadius: widget.isSelected || _isHovered ? 2 : 1,
              blurRadius: widget.isSelected || _isHovered ? 6 : 3,
              offset: Offset(0, widget.isSelected || _isHovered ? 3 : 1),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.expense.category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.expense.category.icon,
                    color: widget.expense.category.color,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.expense.shopName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.expense.category.name,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${widget.expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.expense.paidBy.name,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
