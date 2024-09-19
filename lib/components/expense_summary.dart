import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseSummary extends StatelessWidget {
  final double currentWeekTotal;
  final double currentMonthTotal;
  final double? selectedDateRangeTotal;
  final DateTime? startDate;
  final DateTime? endDate;
  final double averageWeeklyTotal;
  final double averageMonthlyTotal;

  const ExpenseSummary({
    Key? key,
    required this.currentWeekTotal,
    required this.currentMonthTotal,
    this.selectedDateRangeTotal,
    this.startDate,
    this.endDate,
    required this.averageWeeklyTotal,
    required this.averageMonthlyTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height:
          170, // Slightly increased height to accommodate additional spacing
      child: startDate != null || endDate != null
          ? _buildSelectedDateRangeSummary()
          : _buildDefaultSummary(),
    );
  }

  Widget _buildSelectedDateRangeSummary() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Selected Date Range Total',
          style: TextStyle(
            fontSize: 18, // Increased font size
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          NumberFormat.currency(symbol: '\$')
              .format(selectedDateRangeTotal ?? 0),
          style: TextStyle(
            fontSize: 28, // Increased font size
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 8),
        Text(
          _getDateRangeText(),
          style: TextStyle(
            fontSize: 16, // Increased font size
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            'Current Week Total',
            currentWeekTotal,
            averageWeeklyTotal,
            'Avg Weekly',
          ),
        ),
        Container(
          width: 1,
          height: 140, // Increased divider height
          color: Colors.grey[300],
        ),
        Expanded(
          child: _buildSummaryItem(
            'Current Month Total',
            currentMonthTotal,
            averageMonthlyTotal,
            'Avg Monthly',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
      String label, double amount, double average, String averageLabel) {
    double percentageDifference = ((amount - average) / average) * 100;
    String percentageText =
        '${percentageDifference >= 0 ? '+' : '-'}${percentageDifference.abs().toStringAsFixed(1)}%';
    Color percentageColor =
        percentageDifference >= 0 ? Colors.green : Colors.red;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16, // Increased font size
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: '\$').format(amount),
          style: TextStyle(
            fontSize: 24, // Increased font size
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 2),
        Text(
          percentageText,
          style: TextStyle(
            fontSize: 14, // Increased font size
            fontWeight: FontWeight.bold,
            color: percentageColor,
          ),
        ),
        SizedBox(height: 8), // Increased spacing here
        Text(
          averageLabel,
          style: TextStyle(
            fontSize: 12, // Increased font size
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2), // Added a small space between label and value
        Text(
          NumberFormat.currency(symbol: '\$').format(average),
          style: TextStyle(
            fontSize: 12, // Increased font size
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String _getDateRangeText() {
    if (startDate != null && endDate != null) {
      return '${DateFormat('MMM d, y').format(startDate!)} - ${DateFormat('MMM d, y').format(endDate!)}';
    } else if (startDate != null) {
      return 'From ${DateFormat('MMM d, y').format(startDate!)}';
    } else if (endDate != null) {
      return 'Until ${DateFormat('MMM d, y').format(endDate!)}';
    }
    return '';
  }
}

