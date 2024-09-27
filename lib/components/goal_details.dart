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
  final Function(DateTime) onMonthSelected;

  const GoalDetails({
    Key? key,
    required this.goal,
    required this.selectedMonth,
    required this.onMonthSelected,
  }) : super(key: key);

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
            goal: goal,
            onMonthSelected: onMonthSelected,
            selectedMonth: selectedMonth,
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildSummaryCard(
                              context, currentSpent, expenses),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: _buildTotalAmountPerPersonBarChart(
                              context, expenses),
                        ),
                      ],
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
                    color: Colors.grey.shade300,
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
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountPerPersonBarChart(
      BuildContext context, List<Expense> expenses) {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    Map<Person, List<double>> dataPerPerson = {};
    
    for (var expense in expenses) {
      if (!dataPerPerson.containsKey(expense.paidBy)) {
        dataPerPerson[expense.paidBy] = [0.0, 0.0];
      }
      dataPerPerson[expense.paidBy]![0] += expense.amount;
    }

    // Calculate average for each person
    for (var person in dataPerPerson.keys) {
      double averageExpense =
          goalProvider.getAverageExpenseForPersonAndCategory(
        person.id,
        goal.category.id,
        selectedMonth,
      );
      dataPerPerson[person]![1] = averageExpense;
    }

    // Sort entries by person name
    List<MapEntry<Person, List<double>>> sortedEntries = dataPerPerson.entries
        .toList()
      ..sort((a, b) => a.key.name.compareTo(b.key.name));

    double maxAmount = sortedEntries.isNotEmpty
        ? sortedEntries
            .map((e) => e.value.reduce((a, b) => a > b ? a : b))
            .reduce((a, b) => a > b ? a : b)
        : 0;

    return buildElevatedContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending by Person',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Container(
              height: 200, // Fixed height for the chart
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxAmount,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label = rodIndex == 0 ? 'Current' : 'Average';
                        return BarTooltipItem(
                          '${sortedEntries[groupIndex].key.name} ($label): \$${rod.toY.toStringAsFixed(2)}',
                          TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < sortedEntries.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                sortedEntries[value.toInt()].key.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            );
                          }
                          return Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('\$${value.toInt()}',
                              style: TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(sortedEntries.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: sortedEntries[index].value[0],
                          color: sortedEntries[index].key.color,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: sortedEntries[index].value[1],
                          color:
                              sortedEntries[index].key.color.withOpacity(0.5),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                    Theme.of(context).primaryColor, 'Current Month'),
                SizedBox(width: 16),
                _buildLegendItem(
                    Theme.of(context).primaryColor.withOpacity(0.5), 'Average'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 4),
        Text(label),
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
