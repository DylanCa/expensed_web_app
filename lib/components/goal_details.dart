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
import 'package:fl_chart/fl_chart.dart';

class GoalDetails extends StatelessWidget {
  final Goal goal;
  final DateTime selectedMonth;

  const GoalDetails({Key? key, required this.goal, required this.selectedMonth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final currentSpent =
        goalProvider.getGoalSpendingForMonth(goal.category.id, selectedMonth);
    final expenses = goalProvider.getExpensesForCategoryAndMonth(
        goal.category.id, selectedMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          color: Colors.white.withOpacity(0.6),
          child: MonthlyAverageGraph(
              expenses: goalProvider.getExpensesForCategory(goal.category.id),
              goal: goal),
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
                            child: _buildSummaryCard(
                                context, currentSpent, expenses),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildExpensesPerPersonCard(
                                context, expenses, goalProvider),
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

  Widget _buildSummaryCard(
      BuildContext context, double currentSpent, List<Expense> expenses) {
    final progress = (currentSpent / goal.monthlyBudget).clamp(0.0, 1.0);
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
            Text('${expenses.length} entries this month',
                style: Theme.of(context).textTheme.bodyMedium),
            Text(
                'Average: \$${expenses.isNotEmpty ? (currentSpent / expenses.length).toStringAsFixed(2) : "0.00"} per entry',
                style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 16),
            _buildTotalAmountPerPersonDonut(context, expenses),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountPerPersonDonut(
      BuildContext context, List<Expense> expenses) {
    Map<Person, double> totalPerPerson = {};
    for (var expense in expenses) {
      totalPerPerson[expense.paidBy] =
          (totalPerPerson[expense.paidBy] ?? 0) + expense.amount;
    }

    List<PieChartSectionData> sections = totalPerPerson.entries.map((entry) {
      return PieChartSectionData(
        color: entry.key.color,
        value: entry.value,
        title: '${entry.key.name}\n\$${entry.value.toStringAsFixed(0)}',
        radius: 50,
        titleStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 30,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildExpensesPerPersonCard(
      BuildContext context, List<Expense> expenses, GoalProvider goalProvider) {
    Map<Person, List<double>> expensesPerPerson = {};
    double totalCurrentExpenses = 0;

    for (var expense in expenses) {
      expensesPerPerson.putIfAbsent(expense.paidBy, () => [0.0, 0.0]);
      expensesPerPerson[expense.paidBy]![0] += expense.amount;
      totalCurrentExpenses += expense.amount;
    }

    // Calculate average for each person
    for (var person in expensesPerPerson.keys) {
      double averageExpense =
          goalProvider.getAverageExpenseForPersonAndCategory(
        person.id,
        goal.category.id,
        selectedMonth,
      );
      expensesPerPerson[person]![1] = averageExpense;
    }

    // Sort persons by current month expenses (descending)
    var sortedPersons = expensesPerPerson.entries.toList()
      ..sort((a, b) => b.value[0].compareTo(a.value[0]));

    return buildElevatedContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total vs their Average per Person',
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

  Widget _buildTransactionsCard(BuildContext context, List<Expense> expenses) {
    return buildElevatedContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Transactions for ${DateFormat('MMMM yyyy').format(selectedMonth)}',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            expenses.isEmpty
                ? Center(child: Text('No transactions for this month'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              expense.category.color.withOpacity(0.2),
                          child: Icon(expense.category.icon,
                              color: expense.category.color),
                        ),
                        title: Text(expense.shopName),
                        subtitle: Text(
                            DateFormat('MMM d, y').format(expense.dateTime)),
                        trailing: Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
