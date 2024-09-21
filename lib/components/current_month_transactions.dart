import 'package:flutter/material.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/utils/date_utils.dart';
import 'package:intl/intl.dart';

class CurrentMonthTransactions extends StatelessWidget {
  final List<Expense> expenses;

  const CurrentMonthTransactions({Key? key, required this.expenses})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonthExpenses = expenses.where((expense) {
      return expense.dateTime.year == now.year &&
          expense.dateTime.month == now.month;
    }).toList();

    currentMonthExpenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Container(
      height: 300, // Adjust the height as needed
      child: currentMonthExpenses.isEmpty
          ? Center(child: Text('No transactions this month'))
          : ListView.builder(
              itemCount: currentMonthExpenses.length,
              itemBuilder: (context, index) {
                final expense = currentMonthExpenses[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: expense.category.color.withOpacity(0.2),
                    child: Icon(expense.category.icon,
                        color: expense.category.color),
                  ),
                  title: Text(expense.shopName),
                  subtitle: Text(formatDate(expense.dateTime)),
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
    );
  }
}
