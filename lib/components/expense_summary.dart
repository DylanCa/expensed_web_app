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
      height: 170,
      child: startDate != null || endDate != null
          ? _buildSelectedDateRangeSummary(context)
          : _buildDefaultSummary(context),
    );
  }

  Widget _buildSelectedDateRangeSummary(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Selected Date Range Total',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(height: 8),
        Text(
          NumberFormat.currency(symbol: '\$')
              .format(selectedDateRangeTotal ?? 0),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          _getDateRangeText(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultSummary(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            context,
            'Current Week Total',
            currentWeekTotal,
            averageWeeklyTotal,
            'Avg Weekly',
          ),
        ),
        Container(
          width: 1,
          height: 140,
          color: Colors.grey[300],
        ),
        Expanded(
          child: _buildSummaryItem(
            context,
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
      BuildContext context, String label, double amount,
      double average, String averageLabel) {
    double percentageDifference = ((amount - average) / average) * 100;
    String percentageText =
        '${percentageDifference >= 0 ? '+' : ''}${percentageDifference.toStringAsFixed(1)}%';

    // Change this line to reverse the color logic
    Color percentageColor =
        percentageDifference >= 0 ? Colors.red : Colors.green;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: '\$').format(amount),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 2),
        Text(
          percentageText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: percentageColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          averageLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2),
        Text(
          NumberFormat.currency(symbol: '\$').format(average),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

