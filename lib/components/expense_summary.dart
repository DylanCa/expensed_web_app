import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseSummary extends StatelessWidget {
  final double currentWeekTotal;
  final double currentMonthTotal;
  final double averageWeeklyTotal;
  final double averageMonthlyTotal;

  const ExpenseSummary({
    Key? key,
    required this.currentWeekTotal,
    required this.currentMonthTotal,
    required this.averageWeeklyTotal,
    required this.averageMonthlyTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Current Week Total',
              currentWeekTotal,
              averageWeeklyTotal,
              'Average Weekly Total',
            ),
          ),
          Container(
            width: 1,
            height: 100, // Increased height to accommodate new line
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildSummaryItem(
              'Current Month Total',
              currentMonthTotal,
              averageMonthlyTotal,
              'Average Monthly Total',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, double amount, double average, String comparisonLabel) {
    double percentChange = ((amount - average) / average) * 100;
    bool isIncrease = percentChange >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: '\$').format(amount),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${isIncrease ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 14,
            color: isIncrease ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          comparisonLabel,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: '\$').format(average),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
