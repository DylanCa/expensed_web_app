import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

    // Group expenses by day and category
    Map<DateTime, Map<Category, double>> expensesByDayAndCategory = {};
    Set<Category> categories = {};

    for (var day in lastSevenDays) {
      expensesByDayAndCategory[day] = {};
    }

    double maxDailyTotal = 0;

    for (var expense in filteredExpenses) {
      DateTime date = DateTime(
          expense.dateTime.year, expense.dateTime.month, expense.dateTime.day);
      Category category = expense.category;
      double amount = expense.amount;

      if (lastSevenDays.contains(date)) {
        expensesByDayAndCategory[date]!.putIfAbsent(category, () => 0);
        expensesByDayAndCategory[date]![category] =
            (expensesByDayAndCategory[date]![category] ?? 0) + amount;
        categories.add(category);

        double dailyTotal =
            expensesByDayAndCategory[date]!.values.fold(0, (a, b) => a + b);
        if (dailyTotal > maxDailyTotal) {
          maxDailyTotal = dailyTotal;
        }
      }
    }

    List<String> sortedCategories = categories.map((c) => c.name).toList()
      ..sort();

    // Calculate maxY (maximum amount rounded to the nearest 50 above)
    double maxY = maxDailyTotal == 0 ? 100 : (maxDailyTotal / 50).ceil() * 50.0;

    // Prepare data for the stacked bar chart
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < lastSevenDays.length; i++) {
      DateTime date = lastSevenDays[i];
      List<BarChartRodStackItem> stackItems = [];
      double totalHeight = 0;

      for (Category category in categories) {
        double amount = expensesByDayAndCategory[date]![category] ?? 0;
        if (amount > 0) {
          stackItems.add(
            BarChartRodStackItem(
              totalHeight,
              totalHeight + amount,
              category.color,
            ),
          );
          totalHeight += amount;
        }
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalHeight,
              width: 32,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              rodStackItems: stackItems,
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

    // Calculate total weekly amount for each category
    Map<String, double> weeklyTotalByCategory = {};
    for (var day in lastSevenDays) {
      for (var category in sortedCategories) {
        double amount = expensesByDayAndCategory[day]![category] ?? 0;
        weeklyTotalByCategory[category] =
            (weeklyTotalByCategory[category] ?? 0) + amount;
      }
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expense Last Week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: barGroups.isEmpty
                ? Center(child: Text('No data available for the last 7 days'))
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
                              if (index >= 0 && index < lastSevenDays.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat('E d')
                                        .format(lastSevenDays[index]),
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
                            DateTime date = lastSevenDays[groupIndex];
                            Map<Category, double> dayExpenses =
                                expensesByDayAndCategory[date]!;

                            double totalAmount = dayExpenses.values
                                .fold(0, (sum, amount) => sum + amount);

                            return BarTooltipItem(
                              '\$${totalAmount.toStringAsFixed(2)}',
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
                        sortedCategories[i],
                        weeklyTotalByCategory[sortedCategories[i]] ?? 0,
                        i,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: i + 1 < sortedCategories.length
                          ? _buildLegendItem(
                              sortedCategories[i + 1],
                              weeklyTotalByCategory[sortedCategories[i + 1]] ??
                                  0,
                              i + 1,
                            )
                          : SizedBox(), // Empty SizedBox for odd number of categories
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String category, double totalAmount, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.primaries[index % Colors.primaries.length],
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            category,
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 4),
        Text(
          '\$${totalAmount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
