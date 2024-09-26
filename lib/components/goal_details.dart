import 'package:flutter/material.dart';
import 'package:expensed_web_app/models/goal.dart';
import 'package:expensed_web_app/providers/goal_provider.dart';
import 'package:expensed_web_app/components/current_month_transactions.dart';
import 'package:expensed_web_app/components/monthly_average_graph.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/utils/ui_utils.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/models/person.dart';

class GoalDetails extends StatelessWidget {
  final Goal goal;

  const GoalDetails({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final currentSpent = goalProvider.getGoalSpending(goal.category.id);
    final expenses = goalProvider.getExpensesForCategory(goal.category.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          color: Colors.white.withOpacity(0.6),
          child: MonthlyAverageGraph(expenses: expenses, goal: goal),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.category.name,
                        style: Theme.of(context).textTheme.headlineSmall),
                    SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildSummaryCard(context, currentSpent),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child:
                                _buildExpensesPerPersonCard(context, expenses),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTransactionsCard(context, expenses),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

Widget _buildSummaryCard(BuildContext context, double currentSpent) {
    final progress = (currentSpent / goal.monthlyBudget).clamp(0.0, 1.0);
    final remainingBudget = goal.monthlyBudget - currentSpent;
    final isOverBudget = currentSpent > goal.monthlyBudget;

    return buildElevatedContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${currentSpent.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('\$${goal.monthlyBudget.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 4),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOverBudget
                          ? Colors.red.withOpacity(0.7)
                          : Colors.green.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Remaining',
                  '\$${remainingBudget.abs().toStringAsFixed(2)}',
                  isOverBudget ? Colors.red : Colors.green,
                ),
                _buildSummaryItem(
                  'Days left',
                  '${_getRemainingDays()}',
                  Colors.blue,
              ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTransactionsCard(BuildContext context, List<Expense> expenses) {
    return buildElevatedContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Month Transactions',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            CurrentMonthTransactions(expenses: expenses),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesPerPersonCard(
      BuildContext context, List<Expense> expenses) {
    Map<Person, List<double>> expensesPerPerson = {};
    double totalCurrentExpenses = 0;
    double totalAverageExpenses = 0;

    for (var expense in expenses) {
      expensesPerPerson.putIfAbsent(expense.paidBy, () => [0.0, 0.0]);

      // Current month total
      if (expense.dateTime.month == DateTime.now().month &&
          expense.dateTime.year == DateTime.now().year) {
        expensesPerPerson[expense.paidBy]![0] += expense.amount;
        totalCurrentExpenses += expense.amount;
      }

      // Add to total for average calculation
      expensesPerPerson[expense.paidBy]![1] += expense.amount;
    }

    // Calculate average
    int monthsSinceFirstExpense = _getMonthsSinceFirstExpense(expenses);
    expensesPerPerson.forEach((person, amounts) {
      amounts[1] = amounts[1] / monthsSinceFirstExpense;
      totalAverageExpenses += amounts[1];
    });

    // Sort persons by current month expenses (descending)
    var sortedPersons = expensesPerPerson.entries.toList()
      ..sort((a, b) => b.value[0].compareTo(a.value[0]));

    return buildElevatedContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current vs Average per Person',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            ...sortedPersons.map((entry) => _buildPersonProgressBar(
                context,
                entry.key,
                entry.value[0],
                entry.value[1],
                totalCurrentExpenses)),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonProgressBar(BuildContext context, Person person,
      double currentTotal, double average, double totalCurrentExpenses) {
    final ratio = average > 0 ? currentTotal / average : 0.0;
    final percentage = (ratio * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: person.color.withOpacity(0.2),
                child: Text(person.name[0],
                    style: TextStyle(color: person.color, fontSize: 10)),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(person.name,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text('$percentage%',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          SizedBox(height: 4),
          Tooltip(
            message:
                'Current: \$${currentTotal.toStringAsFixed(2)}\nAverage: \$${average.toStringAsFixed(2)}',
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getProgressColor(ratio),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double ratio) {
    if (ratio <= 0.5) {
      return Colors.green.withOpacity(0.5);
    } else if (ratio <= 1.0) {
      return Colors.orange.withOpacity(0.5);
    } else {
      return Colors.red.withOpacity(0.5);
    }
  }

  int _getRemainingDays() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.difference(now).inDays + 1;
  }

  int _getMonthsSinceFirstExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return 1;

    final firstExpenseDate =
        expenses.map((e) => e.dateTime).reduce((a, b) => a.isBefore(b) ? a : b);
    final now = DateTime.now();

    return (now.year - firstExpenseDate.year) * 12 +
        now.month -
        firstExpenseDate.month +
        1;
  }
}
