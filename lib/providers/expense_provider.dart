import 'package:flutter/foundation.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/models/category.dart' as app_category;
import 'package:expensed_web_app/models/person.dart';
import 'package:expensed_web_app/models/alert.dart';
import 'package:expensed_web_app/repositories/expense_repository.dart';
import 'package:expensed_web_app/data/test_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  List<Expense> _expenses = []; // Initialize with an empty list
  List<app_category.Category> _categories = [];
  List<Person> _persons = [];
  bool _isLoading = false;
  String? _error;
  Set<app_category.Category> _selectedCategories = {};
  Set<Person> _selectedPersons = {};
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  List<Alert> _alerts = [];

  List<Expense> get expenses => _expenses;
  List<Alert> get alerts => _alerts;

  final _searchSubject = BehaviorSubject<String>();

  ExpenseProvider() {
    _searchSubject
        .debounceTime(Duration(milliseconds: 300))
        .listen((query) => setSearchQuery(query));

    loadExpenses();
    loadCategoriesAndPersons();
    _createTestAlerts();
  }

  void _createTestAlerts() {
    Person testUser = TestData.persons[0];
    Expense testExpense = Expense(
      id: '1',
      shopName: 'Test Shop',
      amount: 50.0,
      category: TestData.categories[0],
      paidBy: testUser,
      dateTime: DateTime.now().subtract(Duration(hours: 2)),
    );

    _alerts = [
      Alert(
        id: Uuid().v4(),
        user: testUser,
        action: AlertAction.added,
        expense: testExpense,
        dateTime: DateTime.now().subtract(Duration(hours: 2)),
      ),
      Alert(
        id: Uuid().v4(),
        user: testUser,
        action: AlertAction.updated,
        expense: testExpense,
        dateTime: DateTime.now().subtract(Duration(days: 1)),
      ),
      Alert(
        id: Uuid().v4(),
        user: testUser,
        action: AlertAction.deleted,
        expense: testExpense,
        dateTime: DateTime.now().subtract(Duration(days: 2)),
      ),
    ];
  }

  void loadCategoriesAndPersons() {
    _categories = TestData.categories;
    _persons = TestData.persons;
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.loadExpenses();
      _expenses = await _repository.getExpenses();
      _isLoading = false;
    } catch (e) {
      _error = "Failed to load expenses: $e";
      _expenses = []; // Set expenses to an empty list on error
      _isLoading = false;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategories(Set<app_category.Category> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  void setSelectedPersons(Set<Person> persons) {
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
    _searchQuery = ''; // This line ensures the search query is cleared
    notifyListeners();
  }

  List<Expense> getFilteredExpenses() {
    if (_expenses.isEmpty) {
      return []; // Return an empty list if there are no expenses
    }
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
          expense.category.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          expense.paidBy.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

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
      
      // Find the correct position to insert the new expense
      int insertIndex =
          _expenses.indexWhere((e) => e.dateTime.isBefore(expense.dateTime));
      if (insertIndex == -1) {
        // If no earlier date is found, add to the end of the list
        _expenses.add(expense);
      } else {
        // Insert the new expense at the correct position
        _expenses.insert(insertIndex, expense);
      }
      
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

  void deleteAlert(String id) {
    _alerts.removeWhere((alert) => alert.id == id);
    notifyListeners();
  }

  void addAlert(Alert alert) {
    _alerts.insert(0, alert);
    notifyListeners();
  }

  @override
  void dispose() {
    _searchSubject.close();
    super.dispose();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<app_category.Category> get categories => _categories;
  List<Person> get persons => _persons;
  Set<app_category.Category> get selectedCategories => _selectedCategories;
  Set<Person> get selectedPersons => _selectedPersons;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;
}
