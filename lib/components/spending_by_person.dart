import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/models/person.dart';

class SpendingByPerson extends StatelessWidget {
  final List<Expense> filteredExpenses;

  const SpendingByPerson({super.key, required this.filteredExpenses});

  @override
  Widget build(BuildContext context) {
    // Calculate total amount paid by each person
    Map<Person, double> amountByPerson = {};
    for (var expense in filteredExpenses) {
      Person person = expense.paidBy;
      double amount = expense.amount;
      amountByPerson[person] = (amountByPerson[person] ?? 0) + amount;
    }

    // Calculate total amount
    double totalAmount = amountByPerson.values.fold(0, (a, b) => a + b);

    // Prepare data for the pie chart
    List<PieChartSectionData> sections = amountByPerson.entries.map((entry) {
      Person person = entry.key;
      double amount = entry.value;
      double percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0;
      Color color = person.color;

      return PieChartSectionData(
        color: color,
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending by Person',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: totalAmount > 0
                      ? PieChart(
                          PieChartData(
                            sections: sections,
                            centerSpaceRadius: 40,
                            sectionsSpace: 0,
                          ),
                        )
                      : Center(child: Text('No data available')),
                ),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: amountByPerson.entries.map((entry) {
                        Person person = entry.key;
                        double amount = entry.value;
                        Color color = person.color;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$person (\$${amount.toStringAsFixed(2)})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
}
