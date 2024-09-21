import 'package:flutter_test/flutter_test.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';

void main() {
  group('ExpenseProvider Tests', () {
    late ExpenseProvider provider;

    setUp(() {
      provider = ExpenseProvider();
    });

    test('Initial state', () {
      expect(provider.expenses, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('Load expenses', () async {
      await provider.loadExpenses();
      // The list might be empty, but it should not cause an error
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    // ... (rest of the tests remain the same)
  });
}
