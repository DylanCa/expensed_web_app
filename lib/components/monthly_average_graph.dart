import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/models/goal.dart';
import 'package:intl/intl.dart';

class MonthlyAverageGraph extends StatelessWidget {
  final List<Expense> expenses;
  final Goal goal;

  const MonthlyAverageGraph({
    Key? key,
    required this.expenses,
    required this.goal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthlyTotals = _calculateMonthlyTotals();
    final theme = Theme.of(context);

    if (monthlyTotals.isEmpty) {
      return SizedBox(
        height: 240, // Increased height to accommodate top padding
        child: Center(child: Text('No data available')),
      );
    }

    final minY = 0.0;
    final maxY = [
          monthlyTotals.values.reduce((a, b) => a > b ? a : b),
          goal.monthlyBudget,
        ].reduce((a, b) => a > b ? a : b) *
        1.1;

    final sortedEntries = monthlyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Add extra data points before and after
    final firstEntry = sortedEntries.first;
    final lastEntry = sortedEntries.last;
    final extraFirstEntry =
        MapEntry(firstEntry.key.subtract(Duration(days: 32)), firstEntry.value);
    final extraLastEntry =
        MapEntry(lastEntry.key.add(Duration(days: 32)), lastEntry.value);
    sortedEntries.insert(0, extraFirstEntry);
    sortedEntries.add(extraLastEntry);

    // Calculate average monthly expense
    final averageMonthlyExpense = monthlyTotals.values.isEmpty
        ? 0.0
        : monthlyTotals.values.reduce((a, b) => a + b) / monthlyTotals.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final graphWidth = constraints.maxWidth * 1.4; // 40% wider
        final overflowAmount = (graphWidth - constraints.maxWidth) / 2;

        return OverflowBox(
          maxWidth: graphWidth,
          child: SizedBox(
            height: 240, // Increased height to accommodate top padding
            width: graphWidth,
            child: Padding(
              padding: EdgeInsets.only(
                  top: 50,
                  left: overflowAmount,
                  right: overflowAmount), // Added top padding
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(sortedEntries.length, (index) {
                        return FlSpot(
                            index.toDouble(), sortedEntries[index].value);
                      }),
                      isCurved: true,
                      color: theme.primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final isCurrentMonth =
                              index == sortedEntries.length - 2;
                          return FlDotCirclePainter(
                            radius: 6,
                            color: isCurrentMonth
                                ? Colors.green
                                : theme.primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withOpacity(0.3),
                            theme.primaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: theme.cardColor,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots
                            .map((barSpot) {
                              final index = barSpot.x.toInt();
                              if (index >= 1 &&
                                  index < sortedEntries.length - 1) {
                                final date = sortedEntries[index].key;
                                final formattedDate =
                                    DateFormat('MMM yyyy').format(date);
                                return LineTooltipItem(
                                  '$formattedDate\n\$${barSpot.y.toStringAsFixed(2)}',
                                  theme.textTheme.bodyMedium!
                                      .copyWith(color: theme.primaryColor),
                                );
                              }
                              return null;
                            })
                            .whereType<LineTooltipItem>()
                            .toList();
                      },
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: goal.monthlyBudget,
                        color: Colors.red.withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.only(right: 5, bottom: 5),
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          labelResolver: (line) =>
                              'Goal: \$${goal.monthlyBudget.toStringAsFixed(2)}',
                        ),
                      ),
                      HorizontalLine(
                        y: averageMonthlyExpense,
                        color: Colors.blue.withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.only(right: 5, bottom: 5),
                          style: TextStyle(
                            color: Colors.blue.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          labelResolver: (line) =>
                              'Avg: \$${averageMonthlyExpense.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                  clipData: FlClipData.none(),
                  baselineY: 0,
                  minX: 0.5,
                  maxX: sortedEntries.length - 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<DateTime, double> _calculateMonthlyTotals() {
    Map<DateTime, double> monthlyTotals = {};

    for (var expense in expenses) {
      DateTime monthKey =
          DateTime(expense.dateTime.year, expense.dateTime.month);
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }

    return monthlyTotals;
  }
}
