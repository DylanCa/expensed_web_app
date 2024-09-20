import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/models/category.dart';

class ExpenseLastWeek extends StatelessWidget {
  final List<Expense> filteredExpenses;

  const ExpenseLastWeek({super.key, required this.filteredExpenses});

  @override
  Widget build(BuildContext context) {
    // Get the last 7 days
    final now = DateTime.now();
    final lastSevenDays = List.generate(
        7,
        (index) => DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 6 - index)));

    // Group expenses by category
    Map<Category, double> expensesByCategory = {};
    Set<Category> categories = {};

    for (var expense in filteredExpenses) {
      if (lastSevenDays.contains(DateTime(expense.dateTime.year,
          expense.dateTime.month, expense.dateTime.day))) {
        Category category = expense.category;
        double amount = expense.amount;

        expensesByCategory[category] =
            (expensesByCategory[category] ?? 0) + amount;
        categories.add(category);
      }
    }

    List<Category> sortedCategories = categories.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // Calculate maxY (maximum amount rounded to the nearest 50 above)
    double maxY = expensesByCategory.values.isEmpty
        ? 100
        : (expensesByCategory.values.reduce((a, b) => a > b ? a : b) / 50)
                .ceil() *
            50.0;

    // Prepare data for the bar chart
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < sortedCategories.length; i++) {
      Category category = sortedCategories[i];
      double amount = expensesByCategory[category] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: amount,
              width: 32,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              color: category.color,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expense Last Week',
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: barGroups.isEmpty
                ? Center(
                    child: Text('No data available for the last 7 days',
                        style: Theme.of(context).textTheme.bodyMedium))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${value.toInt()}',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey[600]),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 &&
                                  index < sortedCategories.length) {
                                String categoryName =
                                    sortedCategories[index].name;
                                if (categoryName.length > 6) {
                                  categoryName =
                                      '${categoryName.substring(0, 6)}...';
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    categoryName,
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey[600]),
                                  ),
                                );
                              }
                              return Text('');
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            Category category = sortedCategories[groupIndex];
                            double categoryAmount = rod.toY;

                            return BarTooltipItem(
                              '${category.name}: \$${categoryAmount.toStringAsFixed(2)}',
                              TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            );
                          },
                        ),
                      ),
                      groupsSpace: 12,
                    ),
                  ),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (int i = 0; i < sortedCategories.length; i += 2)
                Row(
                  children: [
                    Expanded(
                      child: _buildLegendItem(
                        context,
                        sortedCategories[i],
                        expensesByCategory[sortedCategories[i]] ?? 0,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: i + 1 < sortedCategories.length
                          ? _buildLegendItem(
                              context,
                              sortedCategories[i + 1],
                              expensesByCategory[sortedCategories[i + 1]] ?? 0,
                            )
                          : SizedBox(),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildLegendItem(
      BuildContext context, Category category, double totalAmount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: category.color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            category.name,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 4),
        Text(
          '\$${totalAmount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
