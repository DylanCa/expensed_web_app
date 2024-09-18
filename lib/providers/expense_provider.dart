import 'package:flutter/foundation.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/repositories/expense_repository.dart';
import 'package:rxdart/rxdart.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  Set<String> _selectedCategories = {};
  Set<String> _selectedPersons = {};
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get selectedCategories => _selectedCategories;
  Set<String> get selectedPersons => _selectedPersons;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;

  final _searchSubject = BehaviorSubject<String>();

  ExpenseProvider() {
    _searchSubject
        .debounceTime(Duration(milliseconds: 300))
        .listen((query) => setSearchQuery(query));

    loadExpenses();
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.loadExpenses();
      _expenses = await _repository.getExpenses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = "Failed to load expenses: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategories(Set<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  void setSelectedPersons(Set<String> persons) {
    _selectedPersons = persons;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategories.clear();
    _selectedPersons.clear();
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    notifyListeners();
  }

  List<Expense> getFilteredExpenses() {
    return _expenses.where((expense) {
      bool dateInRange = true;
      if (_startDate != null && _endDate != null) {
        dateInRange = expense.dateTime.isAtSameMomentAs(_startDate!) ||
            expense.dateTime.isAtSameMomentAs(_endDate!) ||
            (expense.dateTime.isAfter(_startDate!) &&
                expense.dateTime.isBefore(_endDate!));
      } else if (_startDate != null) {
        dateInRange = expense.dateTime.isAtSameMomentAs(_startDate!) ||
            expense.dateTime.isAfter(_startDate!);
      } else if (_endDate != null) {
        dateInRange = expense.dateTime.isAtSameMomentAs(_endDate!) ||
            expense.dateTime.isBefore(_endDate!);
      }

      bool matchesSearch = _searchQuery.isEmpty ||
          expense.shopName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expense.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expense.paidBy.toLowerCase().contains(_searchQuery.toLowerCase());

      return dateInRange &&
          matchesSearch &&
          (_selectedCategories.isEmpty ||
              _selectedCategories.contains(expense.category)) &&
          (_selectedPersons.isEmpty ||
              _selectedPersons.contains(expense.paidBy));
    }).toList();
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _repository.addExpense(expense);
      _expenses.add(expense);
      notifyListeners();
    } catch (e) {
      _error = "Failed to add expense: $e";
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _repository.updateExpense(expense);
      int index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to update expense: $e";
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _error = "Failed to delete expense: $e";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchSubject.close();
    super.dispose();
  }
}
